## 17th interop

- [17th Implementation Draft](https://github.com/quicwg/base-drafts/wiki/17th-Implementation-Draft)
- #haskell channel: mew.org:4433 for retry, h3-27/hq-27, VHRZSQDC MBA.
- Test script usage:

```
% sh haskell.sh | grep Resu               
Result: (V) version negotiation  ... OK
Result: (H) handshake ... OK
Result: (D) stream data ... OK
Result: (R) TLS resumption ... OK
Result: (Z) 0-RTT ... OK
Result: (Q) quantum ... OK
Result: (M) change server CID ... OK
Result: (N) change client CID ... OK
Result: (B) NAT rebinding ... OK
Result: (A) address mobility ... OK
```

## Things learned

- If the ordering of Finished and Stream is flipped, a race between the transport and an appliction happens.
- To make the test of NAT rebinding correct, the old socket should be closed quickly.
- Haskell server should support `/{number}` for `MBA` so that the big data gives enough time to change anything.
- There were no consensus on criteria for `MBA`. The following is the result of discussion:

### M: Server CID change

A server offers new CIDs to a client in advance. Upon some events, the client sarts using a new server CID.

- Preparation: A server sends `NEW_CONNECTION_ID` to a client.
- Action: The client starts using a new CID of the server.
- Criteria: Traffic is exchanges with the new server CID.
- Optional: The server may send `RETIRE_CONNECTION_ID` later.
- Optional: To ask the server to use a new client CID, the client sends `NEW_CONNECTION_ID` with retire prior to.

### B: NAT Rebiding

A client's port changes. The client sends packets without noticing the change.

- Action: A client's port changes and the client sends packets without noticing the change.
- Criteria: Traffic is exchanges with the new port.
- Optional: The server may validate the new path
- Optional: The server may use a new client CID if available.

### A: Address Mobility

A server offers new CIDs to a client in advance. The client moves to a new address(/port). The client sends path challenges from the new address(/port) with a new server CID. The server sends path responses on any path.

- Preparation: A server sends `NEW_CONNECTION_ID` to a client.
- Action: The client moves to a new address. To start using the new address, the client sends path challenges from the new address with a new server CID.
- Action: The server sends path responses on any path.
- Criteria: Traffic is exchanges with the new server CID and the new client address.
- Optional: The server may send `RETIRE_CONNECTION_ID` later.
- Optional: The server starts using the new client CID and sends `RETIRE_CONNECTION_ID` for the old client CID.
- Optional: To ask the server to use a new client CID, the client sends `NEW_CONNECTION_ID` with retire prior to.

### N: Client CID change

This is an origial test case of Haskell client. Since `NEW_CONNECTION_ID` with `Retire Prior To` is sent by a server typically, this scenario is unusual.

- Preparation: A client sends `NEW_CONNECTION_ID` to a server.
- Action: The client sends `NEW_CONNECTION_ID` with `Retire Prior To`.
- Action: The server choose a new client CID and sends `RETIRE_CONNECTION_ID` for the old client CID.
