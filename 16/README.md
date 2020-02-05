## 16th interop

- #haskell channel: mew.org:4433 for retry, h3-25/hq-25, VHRZSQ (probably DC).
- The test scripts are a toy at this moment. "-Q" has not implemented yet.
  The following is the example of "VHDRZS":

```
% haskell.sh | grep Mode
% sh haskell.sh| grep Mode
Mode: FullHandshake
Mode: FullHandshake
Mode: FullHandshake
Mode: PreSharedKey
Mode: FullHandshake
Mode: RTT0
```

## Things learned

- I misunderstood that a client should discard 0RTT if a server asks
  retry. So, Haskell server does not send ACK for retried 0RTT.

- Haskell server sometime stacked. It sends back a retry but cannot go
  further. This is because "accept" is called in the main thread. If
  the handshake in "accept" stacks, everything stacks. This experience
  results in new APIs: runQUICClient and runQUICServer.

- gQUIC prefers ChaCha20. When I tried to implement it, I noticed that
  the "cryptnite" package does not provide API to specify
  "counter". We should fix it.

- quant is unique. If max_packet_size is not specifies, it tries PMTU
  discovery with 2020 bytes. quant resends packets according to the
  result. Surprisingly, Short comes just after Initial. Since Short
  comes before Handshake, Haskell client fails into deadlock. Even if
  max_packet_size is specified, Crypto fragments in Initial are
  flipped. I need to implement reassembly.

- quantum: TBD
