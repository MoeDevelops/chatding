import chatding/view/chat
import chatding/view/message_send
import nakai/attr.{content, href, name, rel, src}
import nakai/html.{
  Body, Head, Html, Script, a, h1_text, header, link, main, meta,
}

pub fn view() {
  Html([], [
    Head([
      meta([name("description"), content("Demo")]),
      Script([src("htmx.js")], ""),
      Script([src("htmx-ext-sse.js")], ""),
      link([rel("stylesheet"), href("styles.css")]),
    ]),
    Body([], [
      header([], [a([href("/")], [h1_text([], "Demo")])]),
      main([], [chat.view(), message_send.view()]),
    ]),
  ])
}
