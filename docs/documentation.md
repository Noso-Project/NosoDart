# Documentation
## Usage

### 1. Receiving the balance at the specified address

```dart
// Connect to the node via a socket, and write the following to it
socket.write("${NodeRequest.getHashBalance}  N4ZR3fKhTUod34evnEcDQX3i6XufBDU\n");

// The socket will respond with a List<int> which you can pass to the following method to convert the balance to a double.
double hashBalance = NosoMath().bigIntToDouble(valueByte: listByte);
```

### 2. Get the status of the node

```dart
// Empty
```

### 3. Get a list of nodes that are currently online

```dart
// Empty
```

### 4. Get Pendings

```dart
// Empty
```

### 5. Get and decrypt summary.psk

```dart
// Empty
```


### 6. Create a line for payment and send the order

```dart
// Empty
```

### 7. Generate a string to change the alias and send the order

```dart
// Empty
```
