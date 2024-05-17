import gleam/bit_array
import gleam/int
import gleam/string as g_string

pub fn encode_simple_string(string: String) -> BitArray {
  bit_array.concat([
    <<"+":utf8>>,
    bit_array.from_string(string),
    <<"\r\n":utf8>>,
  ])
}

pub fn encode_simple_error(error_message: String) -> BitArray {
  bit_array.concat([
    <<"-":utf8>>,
    bit_array.from_string(error_message),
    <<"\r\n":utf8>>,
  ])
}

pub fn encode_bulk_string(string: String) -> BitArray {
  bit_array.concat([
    <<"$":utf8>>,
    bit_array.from_string(
      string
      |> g_string.length
      |> int.to_string,
    ),
    <<"\r\n":utf8>>,
    bit_array.from_string(string),
    <<"\r\n":utf8>>,
  ])
}
