import nakai/attr.{Attr, class}
import nakai/html.{div}

pub fn view() {
  div([Attr("hx-ext", "sse"), Attr("sse-connect", "/sse/connect")], [
    div([Attr("sse-swap", "join"), class("user-count")], []),
    div([class("message-list")], [
      div([Attr("sse-swap", "message"), class("message-container")], []),
    ]),
  ])
}
