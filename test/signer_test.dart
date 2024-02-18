import 'package:flutter_test/flutter_test.dart';
import 'package:noso_dart/crypto/noso_signer.dart';
import 'package:noso_dart/models/keys_pair.dart';
import 'package:pointycastle/ecc/api.dart';

void main() {
  print("Create Data To Test Signer Utility");
  String signatureString = "";
  String message = "verify";
  final keyPair = KeyPair(
      publicKey:
          "BGMijYOawruQR1bHCqAI+9BuOqtf6OQMjI/OlrIBTDCHFOt7FA4htq3HyZ3N9eF6RZRf70fNtBAg4y4Fdw2vF/E=",
      privateKey: "ARowNgRgu73gDGXFJapvU76hzBkB5iQNBFrzCUSu3OI=");
  ECSignature? ecSignature =
      NosoSigner().signMessage(message, keyPair.privateKey);
  var defaultBase64Signature =
      "MEQCIBU8CRb1+FwX4A4dbuccyzQpkKQ45vWZXqtBFgACsTTmAiBcxAGda0hsDtotGh1N56CpBRGy5HLtRHDkLYEEGvl+TQ==";
  if (ecSignature != null)
    signatureString = NosoSigner().encodeSignatureToBase64(ecSignature);

  print('ECSignature: $ecSignature');
  print('Encode to Base64: $signatureString');

  test('Test Encode To Base64', () {
    expect(signatureString, equals(defaultBase64Signature));
  });

  test('Test Decode Base64 To ECSignature', () {
    var decodeSignature = NosoSigner().decodeBase64ToSignature(signatureString);
    print('Decode To ECSignature: $decodeSignature');
    expect(decodeSignature.r, equals(ecSignature?.r));
    expect(decodeSignature.s, equals(ecSignature?.s));
  });

  test('Test Verify KeyPair', () {
    bool isVerified = false;
    if (ecSignature != null)
      isVerified =
          NosoSigner().verifyMessage(message, ecSignature, keyPair.publicKey);
    print('Verify KeyPair: $isVerified');
    expect(isVerified, equals(true));
  });
}
