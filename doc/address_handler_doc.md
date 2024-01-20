# Interaction with addresses

> This document describes examples of address creation and recovery from a key pair using the [NosoDart](https://github.com/Noso-Project/NosoDart) library.

### Table of contents 
- [Generate new address](#generate-new-address)
- [Recover an address from a key pair](#recover-an-address-from-a-key-pair)
- [Get hash using a public key](#get-hash-using-a-public-key)

## Generate new address

To generate a new address, use the following example

```dart
AddressObject address = AddressHandler.createNewAddress();
```

The **createNewAddress()** method will return the **AddressObject** model with a hash and the corresponding key pair.

---

## Recover an address from a key pair

An example of recovering an address from a pair of secret keys. To do this, use the **importAddressForKeysPair()** method, which takes two parameters.
- **String keys** - a space separated string with keys,
- **KeyPair? keysPair** -  is a pair of keys wrapped in the KeysPair model


```dart
var keysPairString = "examplePublic  examplePrivate";
var keysPair = KeyPair(publicKey: "examplePublic", privateKey: "examplePrivate");

AddressObject? address = AddressHandler.importAddressForKeysPair(keysPairString);
//OR
AddressObject? address = AddressHandler.importAddressForKeysPair("",keyPair: keysPair);

```

The **importAddressForKeysPair()** method will return the **AddressObject** model if the recovery is successful, otherwise it will return **null**; 

---

## Get hash using a public key

This example shows how to get how to get an address hash with a public key.

```dart
String hash = AddressHandler.getAddressFromPublicKey("examplePublicKey");
```

The **createNewAddress()** method will return a hash generated from the public key.

---


