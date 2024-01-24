import 'dart:typed_data';

import '../const.dart';

/// A model class representing an integer and decimal value pair.
class _DecimalIntegerModel {
  String intValue = "0";
  String decimalValue = "0";
  double _double = 0.0;

  /// Sets the values based on a double value.
  void setDouble(double doubleValue) {
    _double = doubleValue;
  }

  /// Gets the  double value
  double get getDouble =>
      _double == 0.00000000 ? double.parse("$intValue.$decimalValue") : _double;

  /// Gets the integer value.
  int get getInt => int.parse(intValue);
}

/// A utility class for Noso related mathematical operations.
class NosoMath {
  /// Calculates the fee for a given amount.
  int getFee(int amount) {
    int result = amount ~/ NosoConst.comissiontrfr;
    if (result < NosoConst.minimumFee) {
      return NosoConst.minimumFee;
    }
    return result;
  }

  /// Converts a numeric value (either integer or double) to a 64-bit big-endian integer.
  ///
  /// This method takes a numeric [amount] and converts it to a 64-bit integer in big-endian format.
  /// If the [amount] is an integer, it is multiplied by 10^8 (8 decimal places are added).
  /// If the [amount] is a double, it is converted to a string, split into integer and decimal parts,
  /// and padded with zeros to ensure 8 decimal places. The resulting string is then parsed into
  /// a 64-bit integer.
  ///
  /// Parameters:
  /// - [amount] The numeric value (integer or double) to be converted.
  ///
  /// Returns:
  /// - A 64-bit integer in big-endian format representing the converted value.
  ///
  /// Note: If the input is not a valid numeric type (int or double), the method returns 0.

  int doubleToBigEndian(dynamic amount) {
    if (amount is int) {
      return int.parse("${amount}00000000");
    }
    if (amount is double) {
      List<String> tempArray = amount.toString().split('.');

      while (tempArray[1].length < 8) {
        tempArray[1] += '0';
      }

      return int.parse(tempArray[0] + tempArray[1]);
    }

    return 0;
  }

  /// Converts a big integer to a double.
  ///
  /// The [valueInt] is the integer value to convert, [valueString] is the string
  /// representation of the integer, and [fromPsk] is a list of unicodes to convert
  /// [fromPsk] should be used only for deciphering balances from [Summary.psk]
  /// from little-endian format.
  double bigIntToDouble({
    int valueInt = 0,
    String? valueString,
    List<int>? fromPsk,
  }) {
    var inputBigInt = valueInt;
    if (valueString != null) {
      inputBigInt = int.parse(valueString);
    }
    if (fromPsk != null) {
      inputBigInt = _endianToInt(fromPsk);
    }
    return _convertFromBigInt(inputBigInt).getDouble;
  }

  /// Converts a big integer to an integer.
  ///
  /// The [valueInt] is the integer value to convert, [valueString] is the string
  /// representation of the integer, and [fromPsk] is a list of unicodes to convert
  /// [fromPsk] should be used only for deciphering balances from [Summary.psk]
  /// from little-endian format.
  int bigIntToInt({
    int valueInt = 0,
    String? valueString,
    List<int>? fromPsk,
  }) {
    var inputBigInt = valueInt;
    if (valueString != null) {
      inputBigInt = int.parse(valueString);
    }
    if (fromPsk != null) {
      inputBigInt = _endianToInt(fromPsk);
    }

    return _convertFromBigInt(inputBigInt).getInt;
  }

  /// Converts a list of bytes to a string representation of an integer.
  int _endianToInt(List<int> bytes) {
    return ByteData.view(Uint8List.fromList(bytes).buffer)
        .getInt64(0, Endian.little);
  }

  /// Converts a string representation of a big integer to the DecimalIntegerModel.
  _DecimalIntegerModel _convertFromBigInt(int value) {
    var returnData = _DecimalIntegerModel();
    var stringValue = value.toString();
    int length = stringValue.length;
    try {
      if (value == 0) {
        returnData.setDouble(0.00000000);
        return returnData;
      }

      if (length <= 8) {
        returnData.setDouble(value / 100000000);
        return returnData;
      } else {
        String integerPart = stringValue.substring(0, length - 8);
        String decimalPart = stringValue.substring(length - 8);

        if (decimalPart.isEmpty) {
          returnData.intValue = integerPart;
        } else {
          returnData.intValue = integerPart;
          returnData.decimalValue = decimalPart;
        }
      }
    } catch (e) {
      print('Error convertFromBigInt: $e');
    }
    return returnData;
  }
}
