import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/service_locator.dart';
import '../storage/secure_storage.dart';

Future<bool> showPinAuthDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => const PinAuthDialog(),
  );
  return result ?? false;
}

class PinAuthDialog extends StatefulWidget {
  const PinAuthDialog({super.key});

  @override
  State<PinAuthDialog> createState() => _PinAuthDialogState();
}

class _PinAuthDialogState extends State<PinAuthDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return AlertDialog(
      title: Text(l10n.enterPinToConfirm),
      content: TextField(
        controller: _controller,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 4,
        autofocus: true,
        decoration: InputDecoration(
          hintText: l10n.enterPin,
          counterText: '',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () async {
            final pin = _controller.text.trim();
            final savedPin = await sl<SecureStorage>().getPin();
            if (savedPin == pin) {
              if (mounted) {
                Navigator.pop(context, true);
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.invalidPin)),
                );
                _controller.clear();
              }
            }
          },
          child: Text(l10n.view),
        ),
      ],
    );
  }
}
