require "spec"
require "../src/sidekiq_relay"

require "benchmark"
require "sidekiq/api"

def docker_redis_config
  Redis.new host: "the-master", password: "abc", sentinels: [{:host => "172.22.0.15", :port => 26379}, {:host => "172.22.0.20", :port => 26380}]
end

def configure_remote_relay
  Sidekiq::Relay.configure_redis(4) do
    docker_redis_config
  end
  Sidekiq::Relay::Client.default_context
end

def clear_remote_queue(remote_ctx, remote_queue_name)
  # have to override local context to remote Redis briefly in order to clear queue
  Sidekiq::Client.default_context = remote_ctx
  Sidekiq::Queue.new(remote_queue_name).clear
end

def set_local_sk_context
  ctx = Sidekiq::Client.default_context = Sidekiq::Client::Context.new

  # clear local queue
  Sidekiq::Queue.new(Sidekiq::Relay.relay_queue).clear
  ctx
end

def generate_random_jobs(remote_queue_name : String, quantity = rand 4..8)  
  # TODO use a random generator shard like Ruby's Faker gem
  quantity.times.each_with_object([] of Sidekiq::Job) do |_, jobs|
    job = Sidekiq::Job.new
    job.klass = "SomeWorker"
    job.queue = remote_queue_name
    
    # floats cause precision problems, see pending test case
    # h = (rand 2..15).times.each_with_object({} of String => String | Float64 | Float32 | UInt32) { |_, o| o[r.hex] = [r.hex, Random.rand, Random.rand.to_f32, r.next_u].shuffle.first }
    
    r = Random.new
    h = (rand 2..15).times.each_with_object({} of String => String | UInt32) { |_, o| o[r.hex] = [r.hex, r.next_u].shuffle.first }
    job.args = [h].to_json
    
    jobs << job
  end
end