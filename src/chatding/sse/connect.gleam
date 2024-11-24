import chatding/context.{type Context}
import chatding/context/clients.{
  type ClientMessage, Connect, Disconnect, Heartbeat, Join, Message,
}
import chatding/context/messages
import chatding/view/join
import gleam/bit_array
import gleam/erlang/process.{Normal}
import gleam/function
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/option.{None}
import gleam/otp/actor.{type InitResult, type Next, Continue, Ready}
import gleam/string_tree
import mist.{type Connection, type ResponseData, type SSEConnection}
import nakai
import youid/uuid.{type Uuid}

pub fn handle(req: Request(Connection), ctx: Context) -> Response(ResponseData) {
  let id = uuid.v4()
  mist.server_sent_events(
    req,
    initial_response(id),
    fn() { init(ctx, id) },
    fn(msg, conn, _) { loop(ctx, id, msg, conn) },
  )
}

fn initial_response(id: Uuid) -> Response(String) {
  response.new(200)
  |> response.set_header(
    "Set-Cookie",
    "sessionid="
      <> id
    |> uuid.to_string()
    |> bit_array.from_string()
    |> bit_array.base64_encode(False)
      <> "; Path=/; SameSite=Strict",
  )
}

fn init(ctx: Context, id: Uuid) -> InitResult(Nil, ClientMessage) {
  let subject = process.new_subject()
  process.send(ctx.clients, Connect(id, subject))

  Ready(
    Nil,
    process.new_selector()
      |> process.selecting(subject, function.identity),
  )
}

fn loop(
  ctx: Context,
  id: Uuid,
  msg: ClientMessage,
  connection: SSEConnection,
) -> Next(ClientMessage, Nil) {
  case msg {
    Join(amount) -> {
      case
        mist.send_event(
          connection,
          mist.event(join.view(amount) |> nakai.to_inline_string_tree())
            |> mist.event_name("join"),
        )
      {
        Ok(_) -> Continue(Nil, None)
        Error(_) -> {
          process.send(ctx.clients, Disconnect(id))
          actor.Stop(Normal)
        }
      }
    }
    Message -> {
      let subject = process.new_subject()
      process.send(ctx.messages, messages.Get(subject))
      let assert Ok(view) = process.receive(subject, 500)

      case
        mist.send_event(
          connection,
          mist.event(view)
            |> mist.event_name("message"),
        )
      {
        Ok(_) -> Continue(Nil, None)
        Error(_) -> {
          process.send(ctx.clients, Disconnect(id))
          actor.Stop(Normal)
        }
      }
    }
    Heartbeat -> {
      case
        mist.send_event(
          connection,
          mist.event(string_tree.new())
            |> mist.event_name("heartbeat"),
        )
      {
        Ok(_) -> Continue(Nil, None)
        Error(_) -> {
          process.send(ctx.clients, Disconnect(id))
          actor.Stop(Normal)
        }
      }
    }
  }
}
