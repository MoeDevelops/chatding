import gleam/int
import nakai/html.{div_text}

pub fn view(amount: Int) {
  div_text([], int.to_string(amount))
}
