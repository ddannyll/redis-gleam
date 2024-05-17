import gleam/result
import resp/encoder
import store.{type RedisStore}

pub type RespCommand {
  Ping
  Echo(String)
  Set(key: String, value: String)
  Get(key: String)
}

const nil_bulk_string = <<"$-1\r\n":utf8>>

pub fn execute_resp_command(
  redis_store: RedisStore,
  resp_command: RespCommand,
) -> #(RedisStore, BitArray) {
  case resp_command {
    Ping -> #(redis_store, encoder.encode_simple_string("PONG"))
    Echo(str) -> #(redis_store, encoder.encode_simple_string(str))
    Set(key, value) -> #(
      store.set(redis_store, key, value),
      encoder.encode_simple_string("OK"),
    )
    Get(key) -> {
      let #(redis_store, get_result) = store.get(redis_store, key)
      #(
        redis_store,
        get_result
          |> result.map(encoder.encode_simple_string)
          |> result.unwrap(nil_bulk_string),
      )
    }
  }
}
