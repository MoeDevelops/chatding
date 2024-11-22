import gleam/int
import nakai/attr.{class}
import nakai/html.{div_text}

pub fn view(amount: Int) {
  div_text(
    [class("connected-amount")],
    "Clients connected: " <> int.to_string(amount),
  )
}
