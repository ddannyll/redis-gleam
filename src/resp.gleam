import resp/encoder

pub type RespCommand {
  Ping
  Echo(String)
}

pub fn execute_resp_command(resp_command: RespCommand) -> BitArray {
  case resp_command {
    Ping -> encoder.encode_simple_string("PONG")
    Echo(str) -> encoder.encode_simple_string(str)
  }
}
