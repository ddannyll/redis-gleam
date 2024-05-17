import gleam/io

import gleam/bytes_builder
import gleam/erlang/process
import gleam/option.{None}
import gleam/otp/actor
import glisten.{Packet, User}
import resp
import resp/parser
import store

pub fn main() {
  io.println("Starting redis clone")
  let redis_store = store.new()

  let assert Ok(_) =
    glisten.handler(fn(_conn) { #(redis_store, None) }, fn(msg, state, conn) {
      let assert Packet(bits) = msg
      let request = parser.parse_resp_request(bits)
      let #(state, response) = case request {
        Ok(request) -> {
          resp.execute_resp_command(state, request)
        }
        Error(err) -> #(state, parser.build_parse_error_message(err))
      }
      let assert Ok(_) =
        glisten.send(conn, bytes_builder.from_bit_array(response))
      actor.continue(state)
    })
    |> glisten.serve(6379)

  process.sleep_forever()
}
