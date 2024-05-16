pub type ParseError {
  UnexpectedInput(got: BitArray, expected: Expected)
  LengthMismatch(length: Int)
  InvalidUnicode
}

pub type Expected {
  ExpectedString(String)
  ExpectedBits(BitArray)
}

pub type RespCommand {
  RespCommand(execute: fn() -> Nil)
}
