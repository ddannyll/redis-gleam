import gleeunit/should
import resp/encoder

pub fn encode_simple_str_test() {
  encoder.encode_simple_string("hello")
  |> should.equal(<<"+hello\r\n":utf8>>)
  
  encoder.encode_simple_string("")
  |> should.equal(<<"+\r\n":utf8>>)
}

pub fn encode_simple_err_test() {
  encoder.encode_simple_error("")
  |> should.equal(<<"-\r\n":utf8>>)
}

pub fn encode_bulk_str_test() {
  encoder.encode_bulk_string("the quick brown fox jumps over the lazy dog")
  |> should.equal(<<
    "$43\r\nthe quick brown fox jumps over the lazy dog\r\n":utf8,
  >>)
  
  encoder.encode_bulk_string("")
  |> should.equal(<<
    "$0\r\n\r\n":utf8,
  >>)
}
