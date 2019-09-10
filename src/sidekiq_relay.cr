# for Alpine compilation
{% if flag?(:static) %}
  require "llvm/lib_llvm"
  require "llvm/enums"
{% end %}

require "sidekiq/cli"
require "redis-sentinel"

module Sidekiq::Relay
  VERSION = "0.1.0"

  class_property remote : Sidekiq::Client?
  
  DEFAULT_RELAY_QUEUE = "relay_to_remote"
  class_property relay_queue = DEFAULT_RELAY_QUEUE

  class InvalidRedisConfig < Exception; end

  class RedisConfig < Sidekiq::RedisConfig
    # NB: pool size is taken from default concurrency + 2
    def initialize(@pool_size = 27, @pool_timeout = 5.0, &block : -> Redis)
      @cfg = block
    end

    def new_client
      @cfg.call || raise InvalidRedisConfig.new("Please pass a valid block to initialize Redis e.g. Redis.new")
    end
  end

  class Client < Sidekiq::Client; end

  def self.configure_redis(pool_size, &block : -> Redis)
    cfg = Sidekiq::Relay::RedisConfig.new(pool_size: pool_size) do  
      block.call      
    end
    
    Sidekiq::Relay::Client.default_context = Sidekiq::Client::Context.new cfg
    @@remote ||= Client.new
  end

  # converts normal job to relayed job (via client methods), although this should be a Ruby gem too
  def self.enqueue(job : Sidekiq::Job, local_sidekiq = Sidekiq::Client.new)
    relay = Sidekiq::Job.new

    # TODO configurable (at least queue?) ARGV due to -q etc?
    relay.klass = "Sidekiq::Relay::Worker"
    relay.queue = relay_queue
    relay.args = [job.klass, job.queue, JSON.parse(job.args)].to_json
    
    local_sidekiq.push relay
  end

  class Worker
    include Sidekiq::Worker
  
    def perform(klass : String, queue : String, args : JSON::Any)
      logger.info args.inspect
      
      job = Sidekiq::Job.new
      job.klass = klass
      job.queue = queue
      job.args = args.to_json

      if Sidekiq::Relay.remote.nil?
        raise InvalidRedisConfig.new("Please pass a valid block to Sidekiq::Relay.configure_redis to initialize Redis e.g. Redis.new")        
      else
        Sidekiq::Relay.remote.not_nil!.push job
      end
    end
  end

  class CLI < Sidekiq::CLI
    def initialize(args = ARGV)
      super

      unless @queues.includes? Relay.relay_queue
        # disable default, prevent interference
        @queues = [Relay.relay_queue]
      end
    end
  end
end
