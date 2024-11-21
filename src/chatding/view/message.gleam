import nakai/attr.{class}
import nakai/html.{b_text, div, div_text}
import youid/uuid.{type Uuid}

pub fn view(id: Uuid, message: String) {
  div([class("message")], [
    b_text([], id |> uuid.to_string() <> ": "),
    div_text([class("message-content")], message),
  ])
}
