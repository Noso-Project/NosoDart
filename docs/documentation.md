# Documentation of using queries to Nodes

> This document is intended to show you how to connect to nodes, as well as how to request and process the necessary data using  [NosoDart](https://github.com/Noso-Project/NosoDart).

### Table of contents
- [Instructions for interacting with nodes](#instructions-for-interacting-with-nodes)
- [Get the status of the node](#getNodeStatus)

## Instructions for interacting with nodes

We offer you an easy-to-use construction in which we create a connection to a node, send it a request and receive a response (list of unicodes).

**Recommend that you do not forget to handle exceptions, as well as check the response for emptiness and errors.**

```dart
 Future<List<int>> fetchNode(String request, Seed seed) async {
    final responseBytes = <int>[];
    try {
      // Create connection to the selected node
      var socket = await Socket.connect(seed.ip, seed.port, timeout: const Duration(seconds: 2000);
      // Write the necessary request to the server
      socket.write(request);
      // Example of getting a response as a list of unicodes
      await for (var byteData in socket) {
        responseBytes.addAll([...byteData]);
      }
      socket.close();
      // Check if the response is not empty and if an error is returned
      if (responseBytes.isNotEmpty) {
        return responseBytes;
      } else {
        return <int>[];
      }
    } on TimeoutException catch (_) {
     return <int>[];
    } on SocketException catch (e) {
     return <int>[];
    } catch (e) {
      return <int>[];
    }
  }

```

<a id="getNodeStatus">### 1. Get the status of the node</a>

```dart
// Empty
```


### 2. Receiving the balance at the specified address

```dart
// Connect to the node via a socket, and write the following to it
var request = await fetchNode(NodeRequest.getAddressBalance("N4ZR3fKhTUod34evnEcDQX3i6XufBDU"), seed);

// The socket will respond with a List<int> which you can pass to the following method to convert the balance to a double.
double hashBalance = NosoMath().bigIntToDouble(valueString: String.fromCharCodes(request as Iterable<int>));
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
