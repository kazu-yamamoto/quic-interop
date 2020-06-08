## 18th interop

- [18th Implementation Draft](https://github.com/quicwg/base-drafts/wiki/18th-Implementation-Draft)
- #haskell channel: mew.org:4433 (h3-28), mew.org:4433/num/<nnnn> for `T` (h3-28), mew.org:4434 for retry (h3-28 and hq-28), VHRZSQDC MBAT 3 https://mew.org/log/ for logs
- Test script usage:


## Performance tuning

- Retransmission database used to use PSQ (Priority Search Queue). To fix the problem where ACKs cannot catch up with retransmission, a list with multiple keys (mutiple packet numbers) was introduced. Deletion is a bottleneck. Now PSQ comes back and dynamic adjustments of retransmission timer is introduced. (07d41e11d2aac3df7290bc1956f3ced514702e25, 9f2ee9c219436cd2f3eef9025d596a5e70f6391d)
- Packet numbers should not be used as keys since both packet numbers and timestap (priority) are increased linearly. To balance PSQ, the lower 16-bits of packet numbers are reversed in log N.
- Avoiding re-calculation of keys. (76c15a547db1a108003d3aac52cb890e5a9a751c)
- Memorizing keys with proper currying:

Old:

```haskell
aes128gcmEncrypt :: Key -> Nonce -> PlainText -> AddDat -> [CipherText]
aes128gcmEncrypt (Key key) (Nonce nonce) plaintext (AddDat ad) =
    [ciphertext,tag]
  where
    aes = throwCryptoError (cipherInit key) :: AES128
    aead = throwCryptoError $ aeadInit AEAD_GCM aes nonce
    (AuthTag tag0, ciphertext) = aeadSimpleEncrypt aead ad plaintext 16
    tag = convert tag0
```

New:

```haskell
aes128gcmEncrypt :: Key -> (Nonce -> PlainText -> AddDat -> [CipherText])
aes128gcmEncrypt (Key key) =
    let aes = throwCryptoError (cipherInit key) :: AES128
    in \(Nonce nonce) plaintext (AddDat ad) ->
      let aead = throwCryptoError $ aeadInit AEAD_GCM aes nonce
          (AuthTag tag0, ciphertext) = aeadSimpleEncrypt aead ad plaintext 16
          tag = convert tag0
      in [ciphertext,tag]

```

- Using `memory`'s `xor`.
- Firefox Nightly increase ACK ranges linearly even if it receives ACKs of ACKs. If this ACK ranges are treated naively, a large list of ACKs are generated everytime ACKs are received. To prevent this, the minimum ACK value is maintained.
- Using Warp's position read maker based on file descriptor instead of `defaultPositionReadMaker` based on `Handle`.
- Using `unix-time` instead of `hourglass`. The former uses fast `gettimeofday` while the latter uses expensive `clock_gettime(CLOCK_REALTIME)`.
- Using CLMUL (`-f support_pclmuldq`) in cryptonite.


