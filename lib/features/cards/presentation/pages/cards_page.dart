import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/pin_auth_dialog.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../data/models/credit_card_model.dart';
import '../cubit/card_cubit.dart';
import '../cubit/card_state.dart';
import '../widgets/credit_card_widget.dart';
import 'add_card_page.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  Future<void> _handleCardTap(
    CreditCardModel card,
    AppLocalizations l10n,
  ) async {
    final authenticated = await showPinAuthDialog(context);

    if (!authenticated || !mounted) return;

    final cubit = context.read<CardCubit>();

    final fullNumber = await cubit.getCardNumber(card.id);
    final cvv = await cubit.getCvv(card.id);
    final pinCode = await cubit.getPinCode(card.id);

    if (!mounted) return;

    if (fullNumber == null || cvv == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load card details')),
      );
      return;
    }

    _showCardDetailsDialog(card, fullNumber, cvv, l10n, pinCode ?? "");
  }

  IconData _getCardIcon(String type) {
    if (type.toLowerCase() == 'visa') return Icons.payment_rounded;
    if (type.toLowerCase() == 'mastercard') return Icons.contactless_rounded;
    return Icons.credit_card_rounded;
  }

  void _showCardDetailsDialog(
    CreditCardModel card,
    String fullNumber,
    String cvv,
    AppLocalizations l10n,

    String pinCode,
  ) {
    bool obscureNumber = true;
    bool obscureCvv = true;
    bool obscurePinCode = true;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Row(
                children: [
                  Icon(
                    _getCardIcon(card.cardType),
                    color: AppColors.primary,
                    size: 28.r,
                  ),
                  Gap(8.w),
                  Expanded(
                    child: Text(
                      card.bankName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cardholder Name
                    Text(
                      l10n.cardHolderName,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    Text(
                      card.cardHolderName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap(16.h),

                    // Card Number
                    Text(
                      l10n.cardNumber,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            obscureNumber
                                ? card.maskedNumber
                                : _formatCardNumber(fullNumber),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            obscureNumber
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscureNumber = !obscureNumber;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: fullNumber));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.passwordCopied),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Gap(16.h),

                    // Expiration & CVV
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.expiryDate,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${card.expiryMonth}/${card.expiryYear}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Gap(16.h),
                              Text(
                                l10n.note,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              if (card.note != null && card.note!.isNotEmpty) ...[
                                Text(
                                  card.note!,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              Gap(16.h),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.cvv,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      obscureCvv ? '•••' : cvv,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      obscureCvv
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                    ),
                                    onPressed: () {
                                      setDialogState(() {
                                        obscureCvv = !obscureCvv;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy_rounded),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: cvv),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.passwordCopied),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Gap(16.h),
                              Text(
                                l10n.pinCode,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      obscurePinCode ? '••••' : pinCode,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      obscurePinCode
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                    ),
                                    onPressed: () {
                                      setDialogState(() {
                                        obscurePinCode = !obscurePinCode;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy_rounded),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: pinCode),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.passwordCopied),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (card.photoPath != null) ...[
                      Gap(20.h),
                      Text(
                        l10n.view,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      Gap(8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(card.photoPath!),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Text('Image not found'));
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.cancel),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatCardNumber(String number) {
    final buffer = StringBuffer();
    for (int i = 0; i < number.length; i++) {
      buffer.write(number[i]);
      if ((i + 1) % 4 == 0 && i != number.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  void _showCardPhoto(String photoPath, String bankName) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(10.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(bankName),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: InteractiveViewer(
                maxScale: 4.0,
                child: Image.file(File(photoPath), fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cards), centerTitle: true),
      body: BlocConsumer<CardCubit, CardState>(
        listener: (context, state) {
          if (state is CardError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is CardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CardLoaded) {
            final cards = state.cards;

            if (cards.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.credit_card_off_rounded,
                      size: 80.r,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    Gap(16.h),
                    Text(
                      l10n.noCards,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap(8.h),
                    Text(
                      l10n.noCardsSubtitle,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: cards.length,
              separatorBuilder: (_, __) => Gap(24.h),
              itemBuilder: (context, index) {
                final card = cards[index];

                return Dismissible(
                  key: Key(card.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.confirmDelete),
                            content: Text(l10n.confirmDeleteMessage),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(
                                  l10n.delete,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (_) {
                    context.read<CardCubit>().deleteCard(card.id);
                  },
                  child: Column(
                    children: [
                      CreditCardWidget(
                        bankName: card.bankName,
                        cardHolderName: card.cardHolderName,
                        cardNumber: card.maskedNumber,
                        expiryDate: '${card.expiryMonth}/${card.expiryYear}',
                        cvv: '•••',
                        cardType: card.cardType,
                        colorValue: card.colorValue,
                        showBack: false,
                        onTap: () => _handleCardTap(card, l10n),
                      ),
                      if (card.photoPath != null) ...[
                        Gap(8.h),
                        TextButton.icon(
                          onPressed: () =>
                              _showCardPhoto(card.photoPath!, card.bankName),
                          icon: const Icon(
                            Icons.photo_library_rounded,
                            size: 16,
                          ),
                          label: Text(
                            l10n.view,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_cards',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCardPage()),
          );
          if (mounted) {
            context.read<CardCubit>().loadCards();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
