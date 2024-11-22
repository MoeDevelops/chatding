import gleam/option.{type Option}
import nakai/attr.{Attr, class, id, name, placeholder, required, value}
import nakai/html.{button, div, form, input}

pub fn view(username: Option(String)) {
  div([id("send-message-form")], [
    form([class("send-message-form")], [
      input([
        class("message-input"),
        placeholder("message"),
        name("message"),
        required("true"),
      ]),
      input([
        placeholder("name"),
        name("name"),
        required("true"),
        value(username |> option.unwrap("")),
      ]),
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
