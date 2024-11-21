import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/option.{None}
import gleam/otp/actor
import youid/uuid.{type Uuid}

pub type ClientsMessage {
  Connect(id: Uuid, Subject(ClientMessage))
  Disconnect(id: Uuid)
  NewMessage
  GetClients(subject: Subject(Dict(Uuid, Subject(ClientMessage))))
}

pub type ClientMessage {
  Join(client_amount: Int)
  Message
  Heartbeat
}

pub fn init() {
  let assert Ok(subject) = actor.start(dict.new(), loop)
  process.start(fn() { heartbeat(subject) }, False)
  subject
}

fn loop(
  msg: ClientsMessage,
  state: Dict(Uuid, Subject(ClientMessage)),
) -> actor.Next(ClientsMessage, Dict(Uuid, Subject(ClientMessage))) {
  case msg {
    Connect(id, subject) -> {
      let new_state =
        state
        |> dict.insert(id, subject)

      new_state
      |> send_all(Join(dict.size(new_state)))

      process.send(subject, Message)

      actor.Continue(new_state, None)
    }
    Disconnect(id) -> {
      let new_state =
        state
        |> dict.delete(id)

      new_state
      |> send_all(Join(dict.size(new_state)))

      actor.Continue(new_state, None)
    }
    NewMessage -> {
      state
      |> send_all(Message)

      actor.Continue(state, None)
    }
    GetClients(subject) -> {
      process.send(subject, state)

      actor.Continue(state, None)
    }
  }
}

fn send_all(clients: Dict(Uuid, Subject(ClientMessage)), message: ClientMessage) {
  clients
  |> dict.each(fn(_, subject) {
    subject
    |> process.send(message)
  })
}

fn heartbeat(clients: Subject(ClientsMessage)) -> Nil {
  // Wait 1s
  process.sleep(1000)

  // Get currenct clients
  let subject = process.new_subject()
  process.send(clients, GetClients(subject))
  let assert Ok(client_dict) = process.receive(subject, 500)

  // Send heartbeat to all clients
  client_dict
  |> send_all(Heartbeat)

  // Loop
  heartbeat(clients)
}
