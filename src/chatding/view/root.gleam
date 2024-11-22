import chatding/view/chat
import chatding/view/message_send
import gleam/option.{None}
import nakai/attr.{content, href, name, rel, src}
import nakai/html.{
  Body, Head, Html, Script, a, h1_text, header, link, main, meta, title,
}

pub fn view() {
  Html([], [
    Head([
      meta([name("description"), content("Demo")]),
      meta([name("darkreader-lock")]),
      Script([src("htmx.js")], ""),
      Script([src("htmx-ext-sse.js")], ""),
      link([rel("stylesheet"), href("styles.css")]),
      title("chatding"),
    ]),
    Body([], [
      header([], [a([href("/")], [h1_text([], "chatding")])]),
      main([], [chat.view(), message_send.view(None)]),
    ]),
  ])
}
