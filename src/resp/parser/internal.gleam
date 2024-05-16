import gleam/bit_array
import gleam/list
import gleam/result
import resp/parser/types.{type ParseError, InvalidUnicode, UnexpectedInput}

pub type Parsed(t) {
  Parsed(parsed: t, rest: BitArray)
}

pub fn parse_array(request: BitArray) -> Result(List(String), ParseError) {
  case request {
    <<"*":utf8, rest:bits>> -> {
      parse_digits(rest, 0)
      |> result.try(fn(parsed_digits) {
        parse_array_elements(parsed_digits.rest, [], parsed_digits.parsed)
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

pub fn parse_array_elements(
  bits: BitArray,
  current: List(String),
  n_elems: Int,
) -> Result(Parsed(List(String)), ParseError) {
  case
    current
    |> list.length
    >= n_elems
  {
    True -> Ok(Parsed(parsed: list.reverse(current), rest: bits))
    False -> {
      parse_bulk_string(bits)
      |> result.try(fn(parsed_string) {
        parse_array_elements(
          parsed_string.rest,
          [parsed_string.parsed, ..current],
          n_elems,
        )
      })
    }
  }
}

pub fn parse_bulk_string(bits: BitArray) -> Result(Parsed(String), ParseError) {
  case bits {
    <<"$":utf8, rest:bits>> -> {
      parse_digits(rest, 0)
      |> result.try(fn(parsed_digits) {
        let str_bit_slice =
          bit_array.slice(parsed_digits.rest, 0, parsed_digits.parsed)
        let rest_bit_slice =
          bit_array.slice(
            parsed_digits.rest,
            parsed_digits.parsed,
            bit_array.byte_size(parsed_digits.rest) - parsed_digits.parsed,
          )

        case str_bit_slice, rest_bit_slice {
          Ok(str_bit_slice), Ok(<<"\r\n":utf8, rest:bits>>) -> {
            case bit_array.to_string(str_bit_slice) {
              Ok(str) -> Ok(Parsed(parsed: str, rest: rest))
              Error(_) -> Error(InvalidUnicode)
            }
          }
          Ok(_), Ok(rest_bit_slice) -> {
            Error(UnexpectedInput(
              rest_bit_slice,
              types.ExpectedBits(<<"\r\n":utf8>>),
            ))
          }
          _, _ -> Error(InvalidUnicode)
        }
      })
    }
    unexpected ->
      Error(UnexpectedInput(unexpected, types.ExpectedBits(<<"$":utf8>>)))
  }
}

pub fn parse_crln(bits: BitArray) -> Result(Parsed(Nil), ParseError) {
  case bits {
    <<"\r\n":utf8, rest:bits>> -> Ok(Parsed(parsed: Nil, rest: rest))
    unexpected ->
      Error(UnexpectedInput(unexpected, types.ExpectedBits(<<"\r\n":utf8>>)))
  }
}

pub fn parse_digits(
  bits: BitArray,
  current: Int,
) -> Result(Parsed(Int), ParseError) {
  case bits {
    <<"0":utf8, rest:bits>> -> parse_digits(rest, current * 10 + 0)
    <<"1":utf8, rest:bits>> -> parse_digits(rest, current * 10 + 1)
    <<"2":utf8, rest:bits>> -> parse_digits(rest, current * 10 + 2)
    <<"3":utf8, rest:bits>> -> parse_digits(rest, current * 10 + 3)
    <<"4":utf8, rest:bits>> -> parse_digits(rest, current * 10 + 4)
    <<"5":utf8, rest:bits>> -> parse_digits(rest, current * 10 + 5)
    <<"6":utf8, rest:bits>> -> parse_digits(rest, current * 10 + 6)
    <<"7":utf8, rest:bits>> -> parse_digits(rest, current * 10 + 7)
    <<"8":utf8, rest:bits>> -> parse_digits(rest, current * 10 + 8)
    <<"9":utf8, rest:bits>> -> parse_digits(rest, current * 10 + 9)
    <<"\r\n":utf8, rest:bits>> -> Ok(Parsed(parsed: current, rest: rest))
    unexpected ->
      Error(UnexpectedInput(unexpected, types.ExpectedString("Encoded digit")))
  }
}
