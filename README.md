# Sidekiq Relay 

[![Build Status](https://travis-ci.com/pgeraghty/sidekiq_relay.svg?branch=master)](https://travis-ci.com/pgeraghty/sidekiq_relay)

Allows piping of Sidekiq jobs to remote Sidekiq configurations (i.e. non-local Redis) to reduce delays compared to directly enqueuing to remote Redis instances. Supports Redis Sentinel.

Ruby gem coming soon to use in conjunction (e.g. for enqueuing from Rails applications).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     sk_relay:
       github: pgeraghty/sidekiq_relay
   ```

2. Run `shards install`

## Usage

```crystal
require "sidekiq_relay"
```
Given the environment established via the [example Redis 4 Docker Compose file](docker/redis4/docker-compose.yml), tests should complete successfully.


TODO: Write further usage instructions here

TODO: example.cr that just needs Redis config

TODO: allow loading remote Redis config from YAML alongside a Docker image containing a statically-linked binary.

## Development

Testing and development require a functional Redis Sentinel configuration; I have provided [Docker Compose](https://docs.docker.com/compose/) files to establish these for Redis [4](docker/redis4/docker-compose.yml). Both set up a separate static network so that IP addresses are pre-established.

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/pgeraghty/sidekiq_relay_crystal/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Paul Geraghty](https://github.com/pgeraghty) - creator and maintainer
