import chatding/context/clients.{type ClientsMessage}
import chatding/context/messages.{type MessagesMessage}
import gleam/erlang/process.{type Subject}

pub type Context {
  Context(clients: Subject(ClientsMessage), messages: Subject(MessagesMessage))
}

pub fn init() -> Context {
  let clients = clients.init()
  let messages = messages.init()

  Context(clients, messages)
}
