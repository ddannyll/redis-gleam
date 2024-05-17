import birl
import birl/duration
import gleam/dict
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result

pub type RedisStore {
  RedisStore(store: dict.Dict(String, RedisStoreValue))
}

pub type RedisStoreValue {
  RedisStoreValue(value: String, metadata: ValueMetadata)
}

pub type ValueMetadata {
  ValueMetadata(date_modified: birl.Time, expiry: Option(duration.Duration))
}

pub type RedisStoreError {
  KeyDoesNotExist
  ValueExpired
}

pub fn new() -> RedisStore {
  RedisStore(store: dict.new())
}

pub fn set(
  redis_store: RedisStore,
  key: String,
  value: String,
  expiry: Option(duration.Duration),
) -> RedisStore {
  RedisStore(
    store: redis_store.store
    |> dict.insert(
      key,
      RedisStoreValue(value, ValueMetadata(birl.now(), expiry)),
    ),
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
      |> result.replace_error(KeyDoesNotExist)
      |> result.try(fn(val) {
      case val.metadata.expiry {
        None -> Ok(val.value)
        Some(expiry) ->
          case
            birl.add(val.metadata.date_modified, expiry)
            |> birl.compare(birl.now())
          {
            order.Gt -> Ok(val.value)
            _ -> Error(ValueExpired)
          }
      }
    }),
  )
}
