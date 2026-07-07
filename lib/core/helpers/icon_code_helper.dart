import 'package:flutter/material.dart';

class IconCodeHelper {
  IconCodeHelper._();

  static IconData folderIcon(int code) {
    return switch (code) {
      0xe2a3 => Icons.folder_rounded,
      _ => Icons.folder_rounded,
    };
  }

  static IconData passwordIcon(int code) {
    return switch (code) {
      0xe3af => Icons.lock_rounded,
      0xe491 => Icons.people_rounded,
      0xe366 => Icons.language_rounded,
      0xe158 => Icons.mail_rounded,
      0xe11b => Icons.business_center_rounded,
      0xf37d => Icons.shopping_bag_rounded,
      0xe5e1 => Icons.sports_esports_rounded,
      0xe041 => Icons.account_balance_wallet_rounded,
      _ => Icons.lock_rounded,
    };
  }
}
