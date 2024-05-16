import gleam/io

import gleam/bytes_builder
import gleam/erlang/process
import gleam/option.{None}
import gleam/otp/actor
import glisten.{Packet}
import resp
import resp/parser

pub fn main() {
  io.println("Starting redis clone")

  let assert Ok(_) =
    glisten.handler(fn(_conn) { #(Nil, None) }, fn(msg, state, conn) {
      let assert Packet(bits) = msg
      let request = parser.parse_resp_request(bits)
      let response = case request {
        Ok(request) -> resp.execute_resp_command(request)
        Error(err) -> parser.build_parse_error_message(err)
      }
      let assert Ok(_) =
        glisten.send(conn, bytes_builder.from_bit_array(response))
      actor.continue(state)
    })
    |> glisten.serve(6379)

  process.sleep_forever()
}
