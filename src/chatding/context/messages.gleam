import gleam/erlang/process.{type Subject}
import gleam/option.{None}
import gleam/otp/actor.{Continue}
import gleam/string_tree.{type StringTree}

pub type MessagesMessage {
  Add(StringTree)
  Get(Subject(StringTree))
}

pub fn init() {
  let assert Ok(subject) = actor.start(string_tree.new(), loop)
  subject
}

fn loop(
  msg: MessagesMessage,
  state: StringTree,
) -> actor.Next(MessagesMessage, StringTree) {
  case msg {
    Add(tree) ->
      state
      |> string_tree.append_tree(tree)
      |> Continue(None)
    Get(subject) -> {
      actor.send(subject, state)
      Continue(state, None)
    }
  }
}
