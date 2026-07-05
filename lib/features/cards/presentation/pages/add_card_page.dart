import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/media_import_helper.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/models/credit_card_model.dart';
import '../cubit/card_cubit.dart';
import '../widgets/credit_card_widget.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _bankController = TextEditingController();
  final _holderController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  final _noteController = TextEditingController();
  final _pinCodeController = TextEditingController();

  String _cardType = 'other';
  int _selectedColor = 0xFF1E293B;
  File? _cardPhoto;
  bool _isSaving = false;

  final List<int> _colors = [
    0xFF1E293B,
    0xFF1E1B4B,
    0xFF064E3B,
    0xFF7F1D1D,
    0xFF311B92,
    0xFF01579B,
  ];

  @override
  void initState() {
    super.initState();
    _numberController.addListener(_detectCardType);
  }

  @override
  void dispose() {
    _numberController.removeListener(_detectCardType);
    _bankController.dispose();
    _holderController.dispose();
    _numberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    _noteController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  void _detectCardType() {
    final num = _numberController.text.replaceAll(' ', '').trim();
    if (num.startsWith('4')) {
      setState(() => _cardType = 'visa');
    } else if (num.startsWith('5')) {
      setState(() => _cardType = 'mastercard');
    } else if (num.startsWith('3')) {
      setState(() => _cardType = 'amex');
    } else {
      setState(() => _cardType = 'other');
    }
  }

  String get _previewNumber {
    final raw = _numberController.text.replaceAll(' ', '').trim();
    if (raw.length >= 4) {
      return '•••• •••• •••• ${raw.substring(raw.length - 4)}';
    }
    return '•••• •••• •••• ••••';
  }

  Future<void> _captureCardPhoto() async {
    final media = await MediaImportHelper.importFromCamera(context);
    if (media == null || !mounted) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'card_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = await media.file.copy('${appDir.path}/$fileName');

    setState(() {
      _cardPhoto = savedFile;
    });
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final rawNum = _numberController.text.replaceAll(' ', '').trim();
      final masked = '•••• •••• •••• ${rawNum.substring(rawNum.length - 4)}';

      final model = CreditCardModel(
        bankName: _bankController.text.trim(),
        cardHolderName: _holderController.text.trim(),
        maskedNumber: masked,
        cardType: _cardType,
        colorValue: _selectedColor,
        expiryMonth: _expiryMonthController.text.trim(),
        expiryYear: _expiryYearController.text.trim(),
        photoPath: _cardPhoto?.path,
        note: _noteController.text.trim(),
      );

      await context.read<CardCubit>().addCard(
        model,
        rawNum,
        _cvvController.text.trim(),
        _noteController.text.trim(),
        _pinCodeController.text.trim(),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save card: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addCard), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            Text(
              l10n.appearance,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            Gap(10.h),
            CreditCardWidget(
              bankName: _bankController.text.isEmpty
                  ? l10n.bankName
                  : _bankController.text.trim(),
              cardHolderName: _holderController.text.isEmpty
                  ? l10n.cardHolderName
                  : _holderController.text.trim(),
              cardNumber: _previewNumber,
              expiryDate:
                  '${_expiryMonthController.text.isEmpty ? 'MM' : _expiryMonthController.text}/${_expiryYearController.text.isEmpty ? 'YY' : _expiryYearController.text}',
              cvv: '•••',
              cardType: _cardType,
              colorValue: _selectedColor,
              showBack: false,
              onTap: () {},
            ),
            Gap(12.h),
            SizedBox(
              height: 52.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _colors.length,
                separatorBuilder: (_, __) => Gap(12.w),
                itemBuilder: (context, index) {
                  final col = _colors[index];
                  final isSelected = _selectedColor == col;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = col),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 52.w : 44.w,
                      height: isSelected ? 52.w : 44.w,
                      decoration: BoxDecoration(
                        color: Color(col),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? Colors.white24 : Colors.black12),
                          width: isSelected ? 3.r : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(col).withOpacity(0.45),
                                  blurRadius: 10.r,
                                  spreadRadius: 2.r,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 22.r,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            Gap(24.h),

            TextFormField(
              controller: _bankController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.bankName,
                border: const OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? '${l10n.bankName} *' : null,
            ),
            Gap(16.h),

            TextFormField(
              controller: _holderController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.cardHolderName,
                border: const OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty
                  ? '${l10n.cardHolderName} *'
                  : null,
            ),
            Gap(16.h),

            TextFormField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.cardNumber,
                border: const OutlineInputBorder(),
                suffixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_cardType == 'visa')
                        const Icon(Icons.payment_rounded, color: Colors.blue)
                      else if (_cardType == 'mastercard')
                        const Icon(
                          Icons.contactless_rounded,
                          color: Colors.orange,
                        )
                      else if (_cardType == 'amex')
                        const Icon(
                          Icons.credit_card_rounded,
                          color: Colors.cyan,
                        )
                      else
                        const Icon(
                          Icons.credit_card_rounded,
                          color: Colors.grey,
                        ),
                    ],
                  ),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return '${l10n.cardNumber} *';
                final clean = val.replaceAll(' ', '');
                if (clean.length < 15 || clean.length > 16) {
                  return 'Invalid Card Number';
                }
                return null;
              },
            ),
            Gap(16.h),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryMonthController,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'MM',
                      counterText: '',
                      border: const OutlineInputBorder(),
                      hintText: l10n.expiryDate,
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return '*';
                      final m = int.tryParse(val) ?? 0;
                      if (m < 1 || m > 12) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: TextFormField(
                    controller: _expiryYearController,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'YY',
                      counterText: '',
                      border: OutlineInputBorder(),
                      hintText: 'Year',
                    ),
                    validator: (val) => val == null || val.isEmpty ? '*' : null,
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: l10n.cvv,
                      counterText: '',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? '*' : null,
                  ),
                ),
              ],
            ),
            Gap(24.h),
            TextFormField(
              controller: _pinCodeController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: l10n.pinCode,
                counterText: '',
                border: const OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? '*' : null,
            ),
            Gap(16.h),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l10n.note,
                border: OutlineInputBorder(),
              ),
            ),

            Text(
              l10n.addCardPhoto,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            Gap(4.h),
            Text(
              l10n.cardPhotoOptional,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            Gap(12.h),
            GestureDetector(
              onTap: _captureCardPhoto,
              child: Container(
                height: 150.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: _cardPhoto != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Image.file(
                          _cardPhoto!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 36.r,
                            color: AppColors.primary,
                          ),
                          Gap(8.h),
                          Text(
                            l10n.takePhoto,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Gap(40.h),

            PrimaryButton(
              text: l10n.save,
              isLoading: _isSaving,
              onPressed: () => _save(l10n),
            ),
          ],
        ),
      ),
    );
  }
}
