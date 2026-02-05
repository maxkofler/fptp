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

- Authentication (`0x2.`)
  -

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

#pagebreak()

== Authentication

FPTP has a built-in authentication mechanism to allow a peer to verify the other peer's identity and decide on whether it should trust the other peer or not.
Trust in this sense may mean multiple things.
Each peer decides individually what it exposes to which other peer via authentication or even without authentication.
This is completely up to the peer and is not dictated by the protocol.

The authentication is handled in a handshake procedure described by the following steps:

+ One peer requests an authentication using an #link(<streaming-message-auth-request>)[Authentication Request]
+ The other peer sends a challenge sequence using the #link(<streaming-message-auth-challenge>)[Authentication Challenge] message
+ The requesting peer signs the challenge using its private key
+ The signature is delivered to the other peer using a #link(<streaming-message-auth-proof>)[Authentication Proof] message
+ The other peer confirms or denies the authentication using the #link(<streaming-message-auth-result>)[Authentication Result] message.


=== `0x21` - Authentication Information Request <streaming-message-auth-info-request>

=== `0x22` - Authentication Information Response <streaming-message-auth-info-response>

=== `0x23` - Authentication Request <streaming-message-auth-request>

Using this message, a peer can request a #link(<streaming-message-auth-challenge>)[challenge] from another peer to authenticate itself.
The requesting peer specifies the authentication scheme it wants to use in the message.

The other peer will respond with either a #link(<streaming-message-auth-challenge>)[authentication challenge] or a #link(<streaming-message-auth-result>)[authentication result], if the request is invalid, inappropriate or cannot be handled due to other reasons.

As additional information, the sender sends the fingerprint of the key it wants to authenticate itself with.
The serving peer may then simply check if this fingerprint exists / is trusted and decide on whether it should ultimately trust the requesting peer or not.
More information on the available fingerprint types are available in the #link(<fingerprint-types>)[fingerprint types] section of this document.

#table(
  columns: 5,
  [Position], [0], [1], [2], [3],
  [Type], [u8], [u8], [u8], [[u8]],
  [Value], [`0x23`], [?], [?], [[?]],
  [Name], [ID], [Scheme], [Fingerprint Type], [Fingerprint],
)

=== `0x24` - Authentication Challenge <streaming-message-auth-challenge>

This message is the response to a #link(<streaming-message-auth-request>)[authentication request] and contains a challenge byte sequence and the scheme selected by the requesting peer.

The challenge sequence should be aligned with the authentication scheme requirements and its structure, content and generation prerequisites are described in the #link(<authentication-schemes>)[authentication schemes] section.

This message is followed by a #link(<streaming-message-auth-proof>)[authentication proof] or a #link(<streaming-message-auth-result>)[authentication result] in the case that some error is encountered on the opposite peer and the authentication handshake cannot continue.

#table(
  columns: 5,
  [Position], [0], [1], [2], [4],
  [Type], [u8], [u8], [u16], [[u8]],
  [Value], [`0x24`], [?], [?], [[?]],
  [Name], [ID], [Scheme], [Challenge Length], [Challenge],
)


=== `0x25` - Authentication Proof <streaming-message-auth-proof>

This message is the response to a #link(<streaming-message-auth-challenge>)[authentication challenge] and is the answer (or proof) of the authenticating peer that it is authorized to access protected resources, whence the 'proof' terminology.

The structure and requirements for the `Proof` field are described in the #link(<authentication-schemes>)[authentication schemes] section.

This message is followed by a #link(<streaming-message-auth-result>)[authentication result] to confirm or deny the authentication.

#table(
  columns: 5,
  [Position], [0], [1], [2], [4],
  [Type], [u8], [u8], [u16], [[u8]],
  [Value], [`0x25`], [`0x00`], [?], [[?]],
  [Name], [ID], [Reserved], [Proof Length], [Proof],
)

=== `0x26` - Authentication Result <streaming-message-auth-result>

This message is a possible follow-up to any authentication message, as it can indicate all kinds of errors, or the success of a authentication handshake.
This message also marks the end of a authentication handshake and is the last message transmitted in the authentication sequence.

#table(
  columns: 4,
  [Position], [0], [1], [2],
  [Type], [u8], [u8], [u32],
  [Value], [`0x25`], [`0x00`], [?],
  [Name], [ID], [Reserved], [Result],
)

==== Authentication Result Codes

- `0x0001_0000`: Authentication success
- `0x0002_0000`: General authentication failure

#pagebreak()

= Authentication Schemes <authentication-schemes>

There are multiple schemes and algorithms that can be used to authenticate a peer.

- #link(<authentication-scheme-rsa-pss-sha256>)[0x10 - RSA-PSS-SHA256]

== 0x10 - RSA-PSS-SHA256 <authentication-scheme-rsa-pss-sha256>

This authentication scheme uses the *RSA* algorithm for signing, *RSA* for padding and *SHA256* to hash the challenge data.
The serving peer generates a cryptographically random string of binary data that should be at least 32 bytes long and sends it to the requesting peer.
The requesting peer then hashes the data using *SHA256* and pads it using the *PSS* padding scheme and signs it using the *RSA* algorithm.

= Fingerprint Types <fingerprint-types>

- #link(<fingerprint-type-sha256>)[0x10 - SHA256]

== 0x10 - SHA256 <fingerprint-type-sha256>

This type of fingerprint is generated by running the SHA256 cryptographic hash function over the raw binary data of the public key.

