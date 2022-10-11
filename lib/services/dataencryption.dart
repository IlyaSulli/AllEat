import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypty;
import 'dart:convert' as converty;
import 'package:crypto/crypto.dart' as cryptoy;

class DataEncryption {
  static Future<String> encrpyt(plaintext) async {
    dynamic encryptPassword;
    String strkey =
        'ZC8cegCGG45d1IjIACEtrfypDXtkgJ1rA+4JABPncUE='; //Static key and iv
    String striv = 'yvhsTTh739b2yUW9NNWrcKmHTtLTZNBjbiV3F/cSRzM=';
    var iv = cryptoy.sha256 //Grab the substring of the key and iv
        .convert(converty.utf8.encode(striv))
        .toString()
        .substring(0, 16);
    var key = cryptoy.sha256
        .convert(converty.utf8.encode(strkey))
        .toString()
        .substring(0, 16);
    encrypty.IV ivObj = encrypty.IV.fromUtf8(iv);
    encrypty.Key keyObj = encrypty.Key.fromUtf8(key);
    final encrypter =
        encrypty.Encrypter(encrypty.AES(keyObj, mode: encrypty.AESMode.cbc));
    encryptPassword = encrypter.encrypt(plaintext,
        iv: ivObj); //Use the key and iv to encrypt the plaintext password
    encryptPassword = encryptPassword.base64;
    return encryptPassword;
  }
}
