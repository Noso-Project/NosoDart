# Documentation
## Usage

### 1. Receiving the balance at the specified address

```dart
// Connect to the node via a socket, and write the following to it
socket.write("${NodeRequest.getHashBalance}  N4ZR3fKhTUod34evnEcDQX3i6XufBDU\n");

// The socket will respond with a List<int> which you can pass to the following method to convert the balance to a double.
NosoMath().bigIntToDouble(valueByte: listByte);

```
