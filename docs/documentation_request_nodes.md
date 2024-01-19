# Documentation of using queries to Nodes

> This document is intended to show you how to connect to nodes, as well as how to request and process the necessary data using  [NosoDart](https://github.com/Noso-Project/NosoDart).

### Table of contents
- [Instructions for interacting with nodes](#instructions-for-interacting-with-nodes)
- [1. Get the status of the node](#1-get-the-status-of-the-node)
- [2. Receiving the balance at the specified address](#2--receiving-the-balance-at-the-specified-address)
- [3. Get a list of nodes that are currently online](#3-get-a-list-of-nodes-that-are-currently-online)
- [4. Get Pending](#3-get-a-list-of-nodes-that-are-currently-online)
- [5. Get and decrypt summary.psk](#3-get-a-list-of-nodes-that-are-currently-online)

## Instructions for interacting with nodes

We offer you an easy-to-use construction in which we create a connection to a node, send it a request and receive a response List<int> (UnicodeChar).

**Recommend that you do not forget to handle exceptions, as well as check the response for emptiness and errors.**

```dart
// request - A command to request a node, which can be obtained in NodeRequest.
// seed - Selected seed to which the connection is established.
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

This method returns the list of seeds and the owner's hash that worked in the last block. This is used to

```dart
var response = await fetchNode(NodeRequest.getNodeList, seed);
List<Seed> listUserNodes = Seed().parseSeeds(response);
```

The Node returns a list of active nodes of the last block
> 145488 1.169.139.141;8080:N4YubUBaEemehazgZqKD3R8hJM7zZEt:141 1.169.164.228;22222:N4DtatnoVsdUQ7UUoGDKc78hUUj2kEX:143 1.169.182.141;18080:N3eLTneZtG3VCkU5uGeyV1K9CNaD4Cc:422 ...
---

### 4. <a id="getPendingsList">Get Pending</a>

This method returns all pending that are not authorized in this block.

```dart
var response = await fetchNode(NodeRequest.getPendingsList, seed);
List<Pending> pending = Pending().parsePendings(responsePendings);
```

Currently, all nodes support this version of the string, without the transaction ID.
> TRFR,N27ya6hcwoZgnHjjQbrmVRuExwZf2HC,N4ZR3fKhTUod34evnEcDQX3i6XufBDU,321000000,1000000

But this method also involves parsing data from the transaction ID.
> TRFR,OR65a30n8uzg9f5660aoc4pfxisov4gda11ydc5hgvtutnmr341n,N27ya6hcwoZgnHjjQbrmVRuExwZf2HC,N4ZR3fKhTUod34evnEcDQX3i6XufBDU,321000000,1000000 
---

### 5. <a id="getSummaryZip">Get and decrypt summary.psk</a>

This example shows how to get a database of addresses and their balances. Be sure to remove the header of the Summary.zip file, otherwise it may be unreadable.

```dart
var responsePsk = await fetchNode(NodeRequest.getSummaryZip, seed);
```

Write the resulting byte array to the Summary.zip file. Before unpacking the archive, remember to remove the zip file header.

```dart
// You can delete the file header as follows.
final Uint8List bytes = Uint8List.fromList(responsePsk);

// return breakpoint at which the bytes of the .psk file begin
int breakpoint = NosoHandler.removeZipHeaderPsk(bytes);

if (breakpoint != 0) {
final Uint8List modifiedBytes = bytes.sublist(breakpoint);
// writing a file from these modified bytes
} 
```

Decode the .psk file and get the SummaryData array

```dart
 Uint8List bytesPsk = await File("../Summary.psk").readAsBytes();
 List<SummaryData> arraySummary = WalletHandler.extractSummaryData(bytesPsk);
```
---

### 6. Create a line for payment and send the order

```dart
// Empty
```

### 7. Generate a string to change the alias and send the order

```dart
// Empty
```
