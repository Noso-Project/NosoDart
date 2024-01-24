# Querying nodes and processing responses

> This document is intended to show you how to connect to nodes, as well as how to request and process the necessary data using  [NosoDart](https://github.com/Noso-Project/NosoDart).

### Table of contents
- [Instructions for interacting with nodes](#instructions-for-interacting-with-nodes)
- [1. Get the status of the node](#1-get-the-status-of-the-node)
- [2. Receiving the balance of a specified address](#2--receiving-the-balance-at-the-specified-address)
- [3. Get a list of nodes that are currently online](#3-get-a-list-of-nodes-that-are-currently-online)
- [4. Get pending transcations](#4-get-pending)
- [5. Get and decrypt summary.psk](#5-get-and-decrypt-summarypsk)
- [6. Generation of new order depending on the type](#6-generation-of-new-order-depending-on-the-type)


## Instructions for interacting with nodes

We offer you an easy-to-use framework to create a node connection, send requests and receive responses List<int> (UnicodeChar).

**it is recommended that you do not forget to handle exceptions, as well as check the response for emptiness and errors.**

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
Node node = DataParser.parseDataNode(response);
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
List<Seed> listUserNodes = DataParser.parseDataSeeds(response);
```

The Node returns a list of active nodes of the last block
> 145488 1.169.139.141;8080:N4YubUBaEemehazgZqKD3R8hJM7zZEt:141 1.169.164.228;22222:N4DtatnoVsdUQ7UUoGDKc78hUUj2kEX:143 1.169.182.141;18080:N3eLTneZtG3VCkU5uGeyV1K9CNaD4Cc:422 ...
---

### 4. <a id="getPendingsList">Get Pending</a>

This method returns all pending that are not authorized in this block.

```dart
var response = await fetchNode(NodeRequest.getPendingsList, seed);
List<Pending>? pending = DataParser.parseDataPendings(responsePendings);
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
 Uint8List bytesPsk = await File("Summary.psk").readAsBytes();
 List<SummaryData> arraySummary = DataParser.parseSummaryData(bytesPsk);
```
---

### 6. <a id="getNewOrder">Generation of new order depending on the type</a>

This example shows how to generate a string for creating an order depending on the order type.

The library currently supports two types of orders:
**TRFR** - sending a payment to another address, **CUSTOM** - set an alias for the specified address.

Here is an example of creating an order to send a payment to another address
```dart
// Generate the necessary order string to send it to the node
var orderData = OrderData(currentAddress: "N4ZR3fKhTUod34evnEcDQX3i6XufBDU", receiver: "pasichDev", currentBlock: "145478", amount: NosoMath().doubleToBigEndian(10), message: "Hello", appInfo: AppInfo(appVersion: "NOSOSOVA_1_0"));
NewOrder? newOrder = OrderHandler().generateNewOrder(orderData,OrderType.TRFR);

// Check if newOrder is not null. If you made a mistake when filling in OrderData, the method will return 0
if (newOrder == null) { return; }

// Sending the generated string for processing to the node
var response =  await fetchNode(newOrder.getRequest(), seed);

// Decrypting a node's response. 
var result = String.fromCharCodes(response);
```

---

Here's an example of creating an alias setup order for the selected address
```dart
var alias = "NewAlias";

// Generate the necessary order string to send it to the node
var orderData = OrderData(currentAddress: "N4ZR3fKhTUod34evnEcDQX3i6XufBDU", receiver: alias, currentBlock: "145478", amount: 0, appInfo: AppInfo(appVersion: "NOSOSOVA_1_0"));
NewOrder? newOrder = OrderHandler().generateNewOrder(orderData,OrderType.CUSTOM);

// Check if newOrder is not null. If you made a mistake when filling in OrderData, the method will return 0
if (newOrder == null) { return; }

// Sending the generated string for processing to the node
var response =  await fetchNode(newOrder.getRequest(), seed);

// Decrypting a node's response. 
var result = String.fromCharCodes(response);
```

If the order is generated correctly, the node will return the [orderId]

> OR2w03vcemov17yc0m7q3cgd7eh54gq84bqv59qh6dt6p302zgvs

If the order is generated incorrectly, the node will return an error code

> ERROR 101

Note: Before generating a [newOrder], be sure to check the data for validity and the existing address balance. (This api method does not perform any checks and provides the data to the node as it is).
---


