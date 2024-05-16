import gleeunit/should
import resp/parser/internal
import resp/parser/types

pub fn parse_bulk_string_array_test() {
  internal.parse_array(<<"*2\r\n$4\r\nLLEN\r\n$6\r\nmylist\r\n":utf8>>)
  |> should.equal(Ok(["LLEN", "mylist"]))
}

pub fn parse_digits_test() {
  internal.parse_digits(<<"24\r\n":utf8>>, 0)
  |> should.equal(Ok(internal.Parsed(24, <<>>)))
}

pub fn parse_digits_fail_test() {
  internal.parse_digits(<<"24r\n":utf8>>, 0)
  |> should.equal(
    Error(types.UnexpectedInput(
      <<"r\n":utf8>>,
      types.ExpectedString("Encoded digit"),
    )),
  )
}

pub fn parse_bulk_string_test() {
  internal.parse_bulk_string(<<"$4\r\nLLEN\r\n":utf8>>)
  |> should.equal(Ok(internal.Parsed("LLEN", <<>>)))
}

pub fn parse_bulk_string_fail_test() {
  internal.parse_bulk_string(<<"$4\r\nLLENtoolong\r\n":utf8>>)
  |> should.equal(
    Error(types.UnexpectedInput(
      <<"toolong\r\n":utf8>>,
      types.ExpectedBits(<<"\r\n":utf8>>),
    )),
  )
}
