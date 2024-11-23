# chatding

Chatding is a reimplementation of the [Chatthing](https://github.com/0x6DD8/chatthing) project. It is a simple chat application built using Gleam and HTMX, with server-sent events (SSE) for real-time updates and a web-based frontend.

## Features

- Real-time chat updates using Server-Sent Events (SSE)
- Session management with cookies
- Written in Gleam

## Getting Started

### Prerequisites

- Gleam
- Erlang
- rebar3

### Installation

1. Clone the repository:

```sh
git clone https://github.com/MoeDevelops/chatding
cd chatthing
```

2. Build the project:

```sh
gleam build
```

3. Run the server:

```sh
gleam run
```

The server will start on port 5001.

### Usage

Open your web browser and navigate to `http://localhost:5001` to start using the chat application.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Chatthing](https://github.com/0x6DD8/chatthing) - The original project that inspired this reimplementation.
- [nakai](https://github.com/nakaixo/nakai) - A Gleam library for building HTML on the server.
- [mist](https://github.com/rawhat/mist) - A Gleam http server with sse support.
- [wisp](https://github.com/gleam-wisp/wisp) - A Gleam web framework built on mist.
- [htmx](https://github.com/bigskysoftware/htmx) - A library for accessing modern browser features directly from HTML.
