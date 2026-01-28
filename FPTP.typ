#set page(
  paper: "a4",
  header: align(left)[
    The FPTP Protocol
  ],
)

#show title: set text(size: 40pt)
#show heading: set text(size: 15pt)
#show heading.where(level: 1): set text(size: 25pt)
#show heading.where(level: 2): set text(size: 20pt)
#show link: it => underline(text(fill: blue)[#it])
#show raw: it => { highlight(it, fill: rgb("ddd"), radius: 2pt, extent: 0.5pt, top-edge: 1.1em, bottom-edge: -0.3em) }


#set text(
  size: 10pt,
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

The protocol is designed in such a way, so that it can accommodate multiple channels to allow for tunneling of multiple protocols and instances thereof.
To achieve this, the server instance presents a list of services that can be mapped to channels of the connection.
Each service has its own UUID that can be mapped onto one of 256 channels per connection.

== Endianness

All multi-byte values in this protocol are transmitted in *Little Endian*  form.

== Numbering

All numberings and indices start at `0`, as is common in programming terminology.

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
  [Position], [0], [n],
  [Type], [u8], [[u8]],
  [Name], [ID], [Message Data],
)

The `ID` field identifies the message that is delivered on in this frame to allow the receiver to interpret it accordingly.

== Messages

The following message `ID`s are available:

- #link(<streaming-message-ping-request>)[`0x01` - Ping Request]
- #link(<streaming-message-ping-response>)[`0x02` - Ping Response]

- Service Discovery and Mapping (`0x1.`)
  - #link(<streaming-message-service-list-request>)[`0x11` - Service List Request]
  - #link(<streaming-message-service-list-response>)[`0x12` - Service List Response]

- Ping
- Service List
- Service Join
- Authentication

- Channel Data

#pagebreak()

=== `0x01` - Ping Request <streaming-message-ping-request>

The Ping Request command allows one side of the connection to check presence of another peer, measure roundtrip times, etc. without any other side effects.
A requirement of this message is that is must not have any side effects on the sending and receiving side, allowing these messages to be sprinkled into the normal communication flow without the possibility of disrupting anything other.

#table(
  columns: 4,
  [Position], [0], [1], [n],
  [Type], [u8], [u8], [[u8]],
  [Value], [`0x01`], [?], [?],
  [Name], [ID], [Length], [Payload],
)

The Ping message allows for up to 255 bytes of arbitrary payload to be sent with it.
The other peer will respond with a #link(<streaming-message-ping-response>)[Ping Response] that will include an exact copy of the payload data sent in the request.

=== `0x02` - Ping Response <streaming-message-ping-response>

This message is the response to the #link(<streaming-message-ping-request>)[Ping Request] message.
It confirms presence and activity to the requesting peer.
The contents of the request `Payload` field must be mirrored exactly.


#table(
  columns: 4,
  [Position], [0], [1], [n],
  [Type], [u8], [u8], [[u8]],
  [Value], [`0x02`], [?], [?],
  [Name], [ID], [Length], [Payload],
)

#pagebreak()

=== `0x11` - Service List Request <streaming-message-service-list-request>

This message allows a peer to request a list of services another one provides.
The other peer will the deliver the list of services and their descriptions in a #link(<streaming-message-service-list-response>)[Service List Response].

#table(
  columns: 2,
  [Position], [0],
  [Type], [u8],
  [Value], [`0x11`],
  [Name], [ID],
)

=== `0x12` - Service List Response <streaming-message-service-list-response>
