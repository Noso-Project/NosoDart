# Documentation of using queries to Nodes

> This document is intended to show you how to connect to nodes, as well as how to request and process the necessary data using  [NosoDart](https://github.com/Noso-Project/NosoDart).

### Table of contents
- [Instructions for interacting with nodes](#instructions-for-interacting-with-nodes)
- [1. Get the status of the node](#getNodeStatus)
- [2. Receiving the balance at the specified address](#getBalanceAddress)
- [3. Get a list of nodes that are currently online](#getNodeList)

## Instructions for interacting with nodes

We offer you an easy-to-use construction in which we create a connection to a node, send it a request and receive a response List<int> (UnicodeChar).

**Recommend that you do not forget to handle exceptions, as well as check the response for emptiness and errors.**

```dart
 Future<List<int>> fetchNode(String request, Seed seed) async {
    final responseBytes = <int>[];
    try {
      // Create connection to the selected node
      var socket = await Socket.connect(seed.ip, seed.port, timeout: const Duration(seconds: 2000);
      // Write the necessary request to the server
      socket.write(request);
      // Example of getting a response as a List<int> (UnicodeChar)
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
---

### 1. <a id="getNodeStatus">Get the status of the node</a>
This method returns information about the node if it is working normally, otherwise it returns the node status. 
```dart
var response = await fetchNode(NodeRequest.getNodeStatus, seed);
Node node = Node().parseResponseNode(response);
```
Example of a decoded response if the node is online. 
> NODESTATUS 39 145478 0 0 6F029 0.4.1Ba1 1705512443 8761C 304 1AA4FC7A831ED76CF83F18372F8F7947 FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1 1705512000 NpryectdevepmentfundsGE 0 234 FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1 1DEE2 9A623 F8CC2 FBE0E
---

### 2.  <a id="getBalanceAddress">Receiving the balance at the specified address</a>
This is a request to find out the actual balance of the address.
```dart
var response = await fetchNode(NodeRequest.getAddressBalance("N4ZR3fKhTUod34evnEcDQX3i6XufBDU"), seed);

// This method converts the response to a double balance.
// It is recommended to use the valueString parameter for this request, but never fromPsk;
double hashBalance = NosoMath().bigIntToDouble(valueString: String.fromCharCodes(response as Iterable<int>));

//hashBalance = 2278.03441877
```
The node returns the following response
> 227803441877
---

### 3. <a id="getNodeList">Get a list of nodes that are currently online</a>

```dart
var response = await fetchNode(NodeRequest.getNodeList), seed);
List<Seed> listUserNodes = Seed().parseSeeds(response);
```

The Node returns a list of active nodes of the last block
> 145488 1.169.139.141;8080:N4YubUBaEemehazgZqKD3R8hJM7zZEt:141 1.169.164.228;22222:N4DtatnoVsdUQ7UUoGDKc78hUUj2kEX:143 1.169.182.141;18080:N3eLTneZtG3VCkU5uGeyV1K9CNaD4Cc:422 ...

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
