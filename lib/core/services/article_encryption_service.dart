import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

/// Service for encrypting and decrypting scientific heritage article texts.
///
/// This protects offline draft texts from web crawlers, search indexing bots,
/// and scrapers by storing them as AES-256 encrypted binary blobs (.bin)
/// while allowing authors to maintain and edit raw Markdown (.md) locally.
class ArticleEncryptionService {
  ArticleEncryptionService._();

  // 32-byte key for AES-256 (32 characters UTF-8)
  static final Key _key = Key.fromUtf8('NiasHeritage_ScientificText_2026');
  // 16-byte IV for AES-CBC (16 characters UTF-8)
  static final IV _iv = IV.fromUtf8('NiasHeritage_IV!');

  static final Encrypter _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  /// Encrypts plain markdown string into raw encrypted bytes.
  static Uint8List encryptMarkdown(String markdownText) {
    final encrypted = _encrypter.encrypt(markdownText, iv: _iv);
    return encrypted.bytes;
  }

  /// Decrypts raw encrypted bytes back into plain markdown string.
  static String decryptMarkdown(Uint8List encryptedBytes) {
    final encrypted = Encrypted(encryptedBytes);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }
}
