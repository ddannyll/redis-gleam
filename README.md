# Redis in Gleam(Lang)

I was bored over the holidays and decided to try build REDIS using **Gleam!!**

My first time using a _functional_ language to this extent.

Was a bit tricky working without mutability, if statments and loops... but I got used to it eventually :)

This challenge was taken from [Code Crafters](https://app.codecrafters.io/)

# Using redis-gleam

1. [Install Gleam](https://gleam.run/getting-started/installing/)

2. [Install Redis](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/) (Used for client CLI)

3. Run `./spawn_redis_server.sh` or `gleam run`

4. In another terminal run `redis-cli` and start playing with redis!!

# Features

Right now, I've only implemented a subset of redis features

- [x] Resp 2.0 serialisation protocol
- [x] Echo
- [x] Ping
- [x] Get
- [x] Set
- [x] Set with expiry
- [ ] Replication
- [ ] RBD Persistence
- [ ] Streams
- [ ] Resp 3.0
