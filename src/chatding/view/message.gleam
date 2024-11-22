import nakai/attr.{class}
import nakai/html.{b_text, div, div_text}

pub fn view(name: String, message: String) {
  div([class("message")], [
    b_text([], name <> ": "),
    div_text([class("message-content")], message),
  ])
}
