import gleam/io
import gleam/list
import gleam/result
import gleam/string
import resp
import resp/parser/internal
import resp/parser/types.{
  type ParseError, InternalServerError, UnrecognisedCommand, WrongArguments,
}


pub fn parse_resp_request(bits: BitArray) -> Result(resp.RespCommand, ParseError) {
  internal.parse_array(bits)
  |> result.try(build_resp_command)
}

fn build_resp_command(
  bulk_string_arr: List(String),
) -> Result(resp.RespCommand, ParseError) {
  io.debug(bulk_string_arr)
  case list.first(bulk_string_arr) {
    Ok(command) ->
      case string.lowercase(command), bulk_string_arr {
        "ping", _ -> Ok(resp.Ping)
        "echo", [_, str] -> Ok(resp.Echo(str))
        "echo", _ -> Error(WrongArguments("echo"))
        _, _ -> Error(UnrecognisedCommand(command))
      }
    Error(_) -> Error(InternalServerError)
  }
}
