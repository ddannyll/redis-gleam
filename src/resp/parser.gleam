import gleam/bit_array
import gleam/list
import gleam/result
import gleam/string
import resp
import resp/encoder
import resp/parser/internal
import resp/parser/types.{
  type ParseError, InternalServerError, UnrecognisedCommand, WrongArguments,
}

pub fn parse_resp_request(
  bits: BitArray,
) -> Result(resp.RespCommand, ParseError) {
  internal.parse_array(bits)
  |> result.try(build_resp_command)
}

pub fn build_parse_error_message(resp_error: ParseError) -> BitArray {
  case resp_error {
    types.UnexpectedInput(got, expected) ->
      encoder.encode_simple_error(
        "Unexpected input: "
        <> got
        |> bit_array.to_string
        |> result.unwrap("<Could not parse unexpected input as utf8>")
        <> "\nExpected: "
        <> case expected {
          types.ExpectedString(str) -> str
          types.ExpectedBits(bits) ->
            bits
            |> bit_array.to_string
            |> result.unwrap("<Could not parse expected input as utf8>")
        },
      )
    types.InvalidUnicode -> encoder.encode_simple_error("Invalid Unicode")
    types.WrongArguments(command) ->
      encoder.encode_simple_error("Wrong arguments for: " <> command)
    types.InternalServerError ->
      encoder.encode_simple_error("Internal server error")
    types.UnrecognisedCommand(command) ->
      encoder.encode_simple_error("Could not recognise command: " <> command)
  }
}

fn build_resp_command(
  bulk_string_arr: List(String),
) -> Result(resp.RespCommand, ParseError) {
  case list.first(bulk_string_arr) {
    Ok(command) ->
      case string.lowercase(command), bulk_string_arr {
        "ping", _ -> Ok(resp.Ping)

        "echo", [_, str] -> Ok(resp.Echo(str))
        "echo", _ -> Error(WrongArguments("echo"))

        "set", [_, key, value] -> Ok(resp.Set(key, value))
        "set", _ -> Error(WrongArguments("set"))

        "get", [_, key] -> Ok(resp.Get(key))
        "get", _ -> Error(WrongArguments("get"))
        _, _ -> Error(UnrecognisedCommand(command))
      }
    Error(_) -> Error(InternalServerError)
  }
}
