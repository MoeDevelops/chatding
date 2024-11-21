import nakai/attr.{Attr, class, id, name, required}
import nakai/html.{button, div, form, input}

pub fn view() {
  div([id("send-message-form")], [
    form([class("send-message-form")], [
      input([class("message-input"), name("message"), required("true")]),
      button(
        [
          Attr("hx-post", "/api/send"),
          Attr("hx-target", "#send-message-form"),
          Attr("hx-swap", "outerHTML"),
          class("send-msg"),
        ],
        [html.Text("send")],
      ),
    ]),
  ])
}
