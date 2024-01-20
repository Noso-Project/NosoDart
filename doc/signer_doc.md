# Signature and verification

> This document describes examples of signing and verification with a key pair using the [NosoDart](https://github.com/Noso-Project/NosoDart) library.

### Table of contents 
- [Check for key pair matching](#check-for-key-pair-matching)
- [Signing message or creating an ECSignature](#signing-message-or-creating-an-ecsignature)
- [Verification of the signed message](#verification-of-the-signed-message)


## Check for key pair matching

This example demonstrates how to perform a key-pair matching check.

```dart
bool isMatching = NosoSigner().verifyKeysPair(KeyPair(publicKey: "examplePublic", privateKey: "examplePrivate"));
```

The **verifyKeysPair()** method will return **true** if the key match is confirmed, otherwise it will return **false**.

---

## Signing message or creating an ECSignature

This example explains how to create an ECSignature signature and convert it to Base64. Or just sign the message for further verification.

```dart
ECSignature? ecSignature = NosoSigner().signMessage("exampleMessage", "examplePrivatKey");
```

The **signMessage()** method will return a valid **ECSignature** if no exceptions occurred in the process, otherwise **null** will be returned;

How to convert ECSignature to Base64.

```dart
String signatureString = NosoSigner().encodeSignatureToBase64(ecSignature);
```

---

## Verification of the signed message

This example demonstrates how to verify a signed message.

```dart
bool isVerified = NosoSigner().verifySignedString("exampleMessage", ecSignature, "examplePublickKey");
```

The **verifySignedString()** method will return **true** if the message signature is confirmed, otherwise it will return **false**;

---
