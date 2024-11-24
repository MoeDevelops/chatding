import chatding/api/send
import chatding/context.{type Context}
import chatding/sse/connect
import chatding/view/root
import gleam/http/request
import gleam/http/response
import mist
import nakai
import wisp.{type Request, type Response}
import wisp/wisp_mist

fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  let assert Ok(priv_dir) = wisp.priv_directory("chatding")
  use <- wisp.serve_static(req, "/", priv_dir <> "/static")

  handle_request(req)
}

pub fn handle_request(
  req: request.Request(mist.Connection),
  ctx: Context,
  secret_key_base: String,
) -> response.Response(mist.ResponseData) {
  case request.path_segments(req) {
    ["sse", "connect"] -> connect.handle(req, ctx)
    _ -> wisp_mist.handler(handle_request_wisp(_, ctx), secret_key_base)(req)
  }
}

fn handle_request_wisp(req: Request, ctx: Context) -> Response {
  use req <- middleware(req)
  case wisp.path_segments(req) {
    ["api", "send"] -> send.handle(req, ctx)
    [] ->
      wisp.ok()
      |> wisp.string_builder_body(root.view() |> nakai.to_string_tree())
    _ -> wisp.not_found() |> wisp.string_body("Not found")
  }
}
