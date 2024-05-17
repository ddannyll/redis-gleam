import gleam/dict
import gleam/result

pub type RedisStore {
  RedisStore(store: dict.Dict(String, String))
}

pub type RedisStoreError {
  KeyDoesNotExist
}

pub fn new() -> RedisStore {
  RedisStore(store: dict.new())
}

pub fn set(redis_store: RedisStore, key: String, value: String) -> RedisStore {
  RedisStore(
    store: redis_store.store
    |> dict.insert(key, value),
  )
}

pub fn get(
  redis_store: RedisStore,
  key: String,
) -> #(RedisStore, Result(String, RedisStoreError)) {
  #(
    redis_store,
    redis_store.store
      |> dict.get(key)
      |> result.replace_error(KeyDoesNotExist),
  )
}
