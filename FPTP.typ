#set page(
  paper: "a4",
  header: align(left)[
    The SETP Protocol
  ],
)

#show title: set text(size: 50pt)
#show heading: set text(size: 20pt)
#show heading.where(level: 1): set text(size: 35pt)
#show heading.where(level: 2): set text(size: 25pt)

#set text(
  size: 14pt,
)

#set heading(
  numbering: "1.1.1.",
  outlined: true,
)

#set par(
  justify: true,
)

#set table(
  fill: (x, y) => if x == 0 { gray },
  inset: (right: 1em),
)

#title[The FPTP Protocol]
#pagebreak()
#outline()
#pagebreak()

= About this Document

This document describes the *Flexible Protocol Tunneling Protocol*, short *SETP*.
This protocol operates on the Application Layer and allows tunneling of other protocols over it.

== Data Type Notation

In this document, the `Rust` syntax is used for describing data types, as its syntax is very clear and concise.

= Overview

FPTP is engineered and designed to allow tunneling of various protocols over it to extend their use.
The prime example (and idea source) is tunneling IEEE 802.3 (Ethernet) over a TCP connection.

The protocol is designed in a way, that it can accommodate multiple channels to allow for tunneling of multiple protocols and instances thereof.
To achieve this, the server instance presents a list of services that can be mapped to channels of the connection.
Each service has its own UUID that can be mapped onto one of 256 channels per connection.

== Endianness

All multi-byte values in this protocol are transmitted in *Little Endian*  form.

= Streaming Mode

FPTP can run over streaming connections, such as TCP.
This section of the document describes this operating mode.
In this mode, the stream is sectioned into messages that may contain authentication, metadata, tunnel data, etc...

In this streaming mode, the protocol relies on the following assumptions:

- Data is guaranteed to be delivered
- Data is delivered in sequence

== Message Structure

The following table shows the overall message structure that is valid for all messages that are transported using this protocol:

#table(
  columns: 3,
  [Position], [1], [n],
  [Type], [`u8`], [`[u8]`],
  [Value], [Message ID], [Message Data],
)

== Messages

The following messages are available:

- #link(<streaming-message-ping>)[`0x00` - Ping]

- Ping
- Service List
- Service Join
- Authentication

- Channel Data

=== `0x00` - Ping <streaming-message-ping>

The ping command allows a device to check presence of another one and to
