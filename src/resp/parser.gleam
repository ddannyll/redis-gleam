import gleam/result
import resp/parser/internal
import resp/parser/types.{type ParseError, UnexpectedInput}

pub fn parse_request(request: BitArray) -> Result(List(String), ParseError) {
  case request {
    <<"*":utf8, rest:bits>> -> {
      internal.parse_digits(rest, 0)
      |> result.try(fn(parsed_digits) {
        internal.parse_array_elements(
          parsed_digits.rest,
          [],
          parsed_digits.parsed,
        )
      })
      |> result.try(fn(parsed_array_elems) {
        case parsed_array_elems.rest {
          <<>> -> Ok(parsed_array_elems.parsed)
          _ ->
            Error(UnexpectedInput(
              parsed_array_elems.rest,
              types.ExpectedBits(<<>>),
            ))
        }
      })
    }
    invalid_input ->
      Error(UnexpectedInput(invalid_input, types.ExpectedBits(<<"*":utf8>>)))
  }
}
