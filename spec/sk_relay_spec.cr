require "./spec_helper"


remote_ctx = configure_remote_relay
clear_remote_queue(remote_ctx, remote_queue_name = "relay_to_remote")

# NB: always have to set Sidekiq::Client.default_context or Client will generate "Sidekiq client has not been configured yet" runtime exception
ctx = set_local_sk_context

jobs = generate_random_jobs remote_queue_name


describe Sidekiq::Relay do
  # TODO: Write tests
  
  it "passes jobs into a local Sidekiq queue" do
    jobs.each do |job|
      time_to_queue = Benchmark.realtime do
        jid = Sidekiq::Relay.enqueue job
      end

      puts "\nTime to queue locally: #{time_to_queue}".colorize(:magenta)
    end

    true
  end

  pending "rounds Float32/Float64 on initial enqueuing due to JSON/Redis, causing loss of precision" do
    # inverted failing case - test for failure where float precision is reduced
    # Expected: "[{\"6da8dbb988932ac5a90b43207fe0484f\":0.8201576011057596,\"23f867ce7ffd4f4f959dca137e0b63bf\":\"594de079e5e42cd4a704ec49a1707df5\",\"5e8c435567befd08941c636a3fa88520\":0.32701246644052157,\"4a26f98c1da7d7cc5fb29e9d01ffaa1c\":0.6369039996464686,\"18be0f02606e089b2062c203d397b7fa\":0.4292140717889754,\"f0a542a11d034c888819cb2f703d34f3\":\"a2317f0883489a7adfb0ba01081288bf\",\"7ba893d63fb7bd8473b67ff03632a3df\":\"cedee7c9f441eef7ce6b6349d44ff1cd\",\"1dd23a92bb723b0fc9a0b6f4ff5b5768\":\"8f010708ea0e771e7d9943e0b42449af\",\"09230631ae414de22ac2b557708b1ca5\":\"2c408798dc9250de82c062293668f83b\",\"d8a2e714642dfa539256c7e5b4f44c48\":0.8127518675266004}]"
    # got: "[{\"6da8dbb988932ac5a90b43207fe0484f\":0.8201576011057596,\"23f867ce7ffd4f4f959dca137e0b63bf\":\"594de079e5e42cd4a704ec49a1707df5\",\"5e8c435567befd08941c636a3fa88520\":0.32701246644052157,\"4a26f98c1da7d7cc5fb29e9d01ffaa1c\":0.6369039996464686,\"18be0f02606e089b2062c203d397b7fa\":0.42921407178897547,\"f0a542a11d034c888819cb2f703d34f3\":\"a2317f0883489a7adfb0ba01081288bf\",\"7ba893d63fb7bd8473b67ff03632a3df\":\"cedee7c9f441eef7ce6b6349d44ff1cd\",\"1dd23a92bb723b0fc9a0b6f4ff5b5768\":\"8f010708ea0e771e7d9943e0b42449af\",\"09230631ae414de22ac2b557708b1ca5\":\"2c408798dc9250de82c062293668f83b\",\"d8a2e714642dfa539256c7e5b4f44c48\":0.8127518675266004}]"

    # non-inverted
    # Expected: "[{\"18267ba132bcc3a2a99b4a4240bc3123\":\"0d723499fd0adba7090643a611da10ca\",\"24d1b919140eb8efaf8163e42a1ea802\":0.4222304048031967,\"aa694b7cd99a5fdb1b9a4ebfb1b5cb96\":0.2259875038659064,\"2e28d5929d6519e5bb4aa07ef2959c00\":0.9167439666443318,\"f6dc0fdd6a24993f86d25a482dd49951\":0.23504466835661134}]"
    # got: "[{\"18267ba132bcc3a2a99b4a4240bc3123\":\"0d723499fd0adba7090643a611da10ca\",\"24d1b919140eb8efaf8163e42a1ea802\":0.4222304048031967,\"aa694b7cd99a5fdb1b9a4ebfb1b5cb96\":0.2259875038659064,\"2e28d5929d6519e5bb4aa07ef2959c00\":0.9167439666443318,\"f6dc0fdd6a24993f86d25a482dd49951\":0.23504466835661136}]"
    
    # Expected: "[{\"6747de13d4f2b2c42d286b6797809ef8\":1952643816,\"d6dbb22176e7f12d953998108880b757\":0.6487483,\"5a2906e143428c6fbbbb1486a4ae5afa\":0.49409765,\"85dd0dac971dbf721a015bb4ba148ae1\":\"9351d2acc8019d8361eee4f7c70f43b2\",\"815150928fd777b199f8896e5d1df5c3\":0.4933163,\"383b22c0723511faed6f0a722ea8205a\":\"e61d0d39ee96f8bb9d2d737467563215\",\"ce070001ca3b028ceea8becd7db51b44\":\"c6123a400f2cd9f1ed7ad4f0dca91a9a\",\"6df0f556fc2fc005b7368c5cabe5f12f\":\"1296371970ecfc43cb49ce4f2b333177\",\"ad834f8bc0aca76cd0764113db7bc71f\":\"1e5ad687352b08daf8bf4be530bbf0b0\",\"a66d6bbd6adbe288c874b399d9729d0c\":\"9f4ebc692d5ea10fba29cd861085892e\",\"01d33dda7bce555926278d0b31399b56\":268460381,\"43e6d81bc6e11b929be2bb9c5d4c3d27\":0.075179495,\"1eef16867e7100f35b56060b1393563d\":2408001787,\"b712cf72dfe686eb1a58e82b2f2d851d\":3163734724,\"312ecc189af1e159e5871a0a8876ddfd\":\"239f0bedaa93f4bf5328b1136b6655c0\"}]"
    # got: "[{\"6747de13d4f2b2c42d286b6797809ef8\":1952643816,\"d6dbb22176e7f12d953998108880b757\":0.64874830000000006,\"5a2906e143428c6fbbbb1486a4ae5afa\":0.49409765,\"85dd0dac971dbf721a015bb4ba148ae1\":\"9351d2acc8019d8361eee4f7c70f43b2\",\"815150928fd777b199f8896e5d1df5c3\":0.4933163,\"383b22c0723511faed6f0a722ea8205a\":\"e61d0d39ee96f8bb9d2d737467563215\",\"ce070001ca3b028ceea8becd7db51b44\":\"c6123a400f2cd9f1ed7ad4f0dca91a9a\",\"6df0f556fc2fc005b7368c5cabe5f12f\":\"1296371970ecfc43cb49ce4f2b333177\",\"ad834f8bc0aca76cd0764113db7bc71f\":\"1e5ad687352b08daf8bf4be530bbf0b0\",\"a66d6bbd6adbe288c874b399d9729d0c\":\"9f4ebc692d5ea10fba29cd861085892e\",\"01d33dda7bce555926278d0b31399b56\":268460381,\"43e6d81bc6e11b929be2bb9c5d4c3d27\":0.075179495,\"1eef16867e7100f35b56060b1393563d\":2408001787,\"b712cf72dfe686eb1a58e82b2f2d851d\":3163734724,\"312ecc189af1e159e5871a0a8876ddfd\":\"239f0bedaa93f4bf5328b1136b6655c0\"}]"
  end

  pending "skips jobs in default queue (push one and test that final integration step doesn't pull it in)"

  it "executes relay jobs" do      
      fetcher = Sidekiq::BasicFetch.new [remote_queue_name]
      
      jobs.each do |job|
        unit_of_work = fetcher.retrieve_work ctx
        unit_of_work.should be_a Sidekiq::BasicFetch::UnitOfWork
        
        jobstr = unit_of_work.not_nil!.job
        queued_job = Sidekiq::Job.from_json jobstr

        job_args = JSON.parse queued_job.args

        relayed_job = Sidekiq::Job.new
        relayed_job.klass = job_args[0].to_s
        relayed_job.queue = job_args[1].to_s
        relayed_job.args = job_args[2].to_json

        # check that queued job matches original
        relayed_job.args.should eq job.args
        
        # now we process the job to relay it
        time_to_queue = Benchmark.realtime do
          queued_job.execute ctx
        end

        puts "\nTime to queue remotely: #{time_to_queue}".colorize(:cyan)
      end
  
      unit_should_not_exist = fetcher.retrieve_work ctx
      unit_should_not_exist.should eq nil
  end

  it "passes jobs to remote" do
    fetcher = Sidekiq::BasicFetch.new [remote_queue_name]

    jobs.each do |job|
      unit_of_work = fetcher.retrieve_work remote_ctx
      unit_of_work.should be_a Sidekiq::BasicFetch::UnitOfWork
      
      jobstr = unit_of_work.not_nil!.job
      relayed_job = Sidekiq::Job.from_json jobstr
      
      relayed_job.args.should eq job.args
    end
end

  it "relays jobs" do
    cli = Sidekiq::Relay::CLI.new ["-c 2"]

    server = cli.configure do |config|
      # middleware would be added here
      config.queues.should_not contain "default"
    end

    jobs = generate_random_jobs("relayed_to_remote")

    jobs.each do |job|
      time_to_queue = Benchmark.realtime do
        jid = Sidekiq::Relay.enqueue job
      end

      puts "Time to queue locally: #{time_to_queue}"
    end

    delay 5 do
      exit 0
    end

    cli.run server
  end
end
