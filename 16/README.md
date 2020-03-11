## 16th interop

- [16th Implementation Draft](https://github.com/quicwg/base-drafts/wiki/16th-Implementation-Draft)
- #haskell channel: mew.org:4433 for retry, h3-25/hq-25, VHRZSQ (probably DC).
- The test scripts are a toy at this moment.
  The following is the example of "VHDRZSQ":

```
% sh haskell.sh| grep Mode
Mode: FullHandshake
Mode: FullHandshake
Mode: FullHandshake
Mode: PreSharedKey
Mode: FullHandshake
Mode: RTT0
Mode: FullHandshake
```

## Things learned

- ngtcp2 sends HANDSHAKE_DONE then CRYPTO for NewSessionTicket. So, if
  the TLS handshake thread is killed immediately on HANDSHAKE_DONE,
  NewSessionTicket cannot be processed, resulting in failures for
  resumption and 0RTT. So, on HANDSHAKE_DONE, a new thread is spawned
  and it waits for a while then kills the TLS handshake thread.

- I misunderstood that a client should discard 0RTT if a server asks
  retry. So, Haskell server does not send ACK for retried 0RTT.

- Haskell server sometime stacked. It sends back a retry but cannot go
  further. This is because `accept` is called in the main thread. If
  the handshake in `accept` stacks, everything stacks. This experience
  results in new APIs: `runQUICClient` and
  `runQUICServer`. `Connection` is automatically closed. It is ensured
  that server actions are executed in child threads.

- gQUIC prefers ChaCha20. When I tried to implement it, I noticed that
  the `cryptnite` package does not provide API to specify
  `counter`. We should fix it.

- quant is unique. If `max_packet_size` is not specified, it tries
  PMTU discovery with 2020 bytes. quant resends packets according to
  the result. Surprisingly, a Short packet comes just after
  Initial. Since Short comes before Handshake, Haskell client falls
  into deadlock. Even if `max_packet_size` is specified, Crypto
  fragments in Initial are reordered. This motivated me to implement
  reassembly.

- The quantum test sometime fails. This is because that Linux
  `connect(2)` behaves differently macOS `connect(2)`. macOS
  `connect(2)` fails if the addr-port is already used. But Linux
  `connect(2)` always success for UDP, sigh. So, on Linux, two sockets
  are created and only the latter can receive packets. To fix this
  issue, I introduced a fixed-size quantum table based on PSQ.

- Before sending a Pong ACK, the peer packet number of Ping should
  be registered.
