import chatding/context.{type Context}
import chatding/context/clients.{NewMessage}
import chatding/context/messages.{Add}
import chatding/view/message
import chatding/view/message_send
import gleam/erlang/process
import gleam/http.{Post}
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string_tree
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
    use _id <- result.try(
      wisp.get_cookie(req, "sessionid", wisp.PlainText)
      |> result.then(uuid.from_string)
      |> result.replace_error(wisp.response(401)),
    )

    use message_str <- result.try(
      form.values
      |> list.key_find("message")
      |> result.replace_error(wisp.unprocessable_entity()),
    )

    use name <- result.try(
      form.values
      |> list.key_find("name")
      |> result.replace_error(wisp.unprocessable_entity()),
    )

    use _ <- result.try(case name {
      "" -> Error(wisp.unprocessable_entity())
      _ -> Ok(Nil)
    })

    use _ <- result.try(case message_str {
      "" -> Error(wisp.unprocessable_entity())
      "/clear" -> {
        process.send(ctx.messages, messages.Set(string_tree.new()))
        Ok(Nil)
      }
      _ -> Ok(Nil)
    })

    let message =
      message.view(name, message_str)
      |> nakai.to_inline_string_tree()

    process.send(ctx.messages, Add(message))
    process.send(ctx.clients, NewMessage)
    Ok(name)
  }

  case result {
    Ok(name) ->
      wisp.ok()
      |> wisp.set_header("Content-Type", "text/html")
      |> wisp.string_tree_body(
        message_send.view(Some(name)) |> nakai.to_inline_string_tree(),
      )
    Error(err) -> err
  }
}
