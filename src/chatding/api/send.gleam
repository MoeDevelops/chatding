import chatding/context.{type Context}
import chatding/context/clients.{NewMessage}
import chatding/context/messages.{Add}
import chatding/view/message
import chatding/view/message_send
import gleam/dict
import gleam/erlang/process
import gleam/http.{Post}
import gleam/result
import nakai
import wisp.{type Request, type Response}
import youid/uuid

pub fn handle(req: Request, ctx: Context) -> Response {
  case req.method {
    Post -> post(req, ctx)
    _ -> wisp.method_not_allowed([Post])
  }
}

fn post(req: Request, ctx: Context) -> Response {
  use form <- wisp.require_form(req)

  let result = {
    use id <- result.try(
      wisp.get_cookie(req, "sessionid", wisp.PlainText)
      |> result.then(uuid.from_string)
      |> result.replace_error(wisp.response(401)),
    )

    use message_str <- result.try(
      form.values
      |> dict.from_list()
      |> dict.get("message")
      |> result.replace_error(wisp.unprocessable_entity()),
    )

    use _ <- result.try(case message_str {
      "" -> Error(wisp.unprocessable_entity())
      _ -> Ok(Nil)
    })

    let message =
      message.view(id, message_str)
      |> nakai.to_inline_string_builder()

    process.send(ctx.messages, Add(message))
    process.send(ctx.clients, NewMessage)
    Ok(Nil)
  }

  case result {
    Ok(_) ->
      wisp.ok()
      |> wisp.set_header("Content-Type", "text/html")
      |> wisp.string_builder_body(
        message_send.view() |> nakai.to_inline_string_builder(),
      )
    Error(err) -> err
  }
}
