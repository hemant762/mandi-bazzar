
import 'package:encrypt/encrypt.dart';

final key = Key.fromUtf8("kjstrhfijufysyuJHG8diYDuTapJc456");
final iv = IV.fromUtf8("kjshiyyHdYDaJc56");

String encrypt(String text){
  final encrypter = Encrypter(AES(key,mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(text,iv: iv);
  return encrypted.base64;
}

String decrypt(String text){
  final encrypter = Encrypter(AES(key,mode: AESMode.cbc));
  final decrypted = encrypter.decrypt(Encrypted.from64(text),iv: iv);
  return decrypted;
}