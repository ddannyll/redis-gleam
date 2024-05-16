pub type ParseError {
  UnexpectedInput(got: BitArray, expected: Expected)
  InvalidUnicode

  WrongArguments(command: String)
  InternalServerError
  UnrecognisedCommand(command: String)
}

pub type Expected {
  ExpectedString(String)
  ExpectedBits(BitArray)
}
