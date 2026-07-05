import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/models/password_model.dart';
import '../cubit/password_cubit.dart';

class AddPasswordPage extends StatefulWidget {
  const AddPasswordPage({super.key});

  @override
  State<AddPasswordPage> createState() => _AddPasswordPageState();
}

class _AddPasswordPageState extends State<AddPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _serviceController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedCategory = 'social';
  int _selectedColor = 0xFF6366F1;
  int _selectedIcon = 0xe3af; // Icons.lock

  final List<int> _colors = [
    0xFF6366F1, // Indigo
    0xFF0EA5E9, // Sky Blue
    0xFF10B981, // Emerald Green
    0xFFF59E0B, // Amber
    0xFFEF4444, // Red
    0xFFEC4899, // Pink
    0xFF8B5CF6, // Purple
  ];

  final List<Map<String, dynamic>> _icons = [
    {'icon': Icons.lock_rounded, 'code': 0xe3af},
    {'icon': Icons.people_rounded, 'code': 0xe491},
    {'icon': Icons.language_rounded, 'code': 0xe366},
    {'icon': Icons.mail_rounded, 'code': 0xe158},
    {'icon': Icons.business_center_rounded, 'code': 0xe11b},
    {'icon': Icons.shopping_bag_rounded, 'code': 0xf37d},
    {'icon': Icons.sports_esports_rounded, 'code': 0xe5e1},
    {'icon': Icons.account_balance_wallet_rounded, 'code': 0xe041},
  ];

  @override
  void dispose() {
    _serviceController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final model = PasswordModel(
        serviceName: _serviceController.text.trim(),
        username: _usernameController.text.trim(),
        categoryTag: _selectedCategory,
        colorValue: _selectedColor,
        iconCode: _selectedIcon,
      );

      await context.read<PasswordCubit>().addPassword(
        model,
        _passwordController.text.trim(),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save password: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final categories = [
      {'tag': 'social', 'label': l10n.social},
      {'tag': 'banking', 'label': l10n.banking},
      {'tag': 'work', 'label': l10n.work},
      {'tag': 'shopping', 'label': l10n.shopping},
      {'tag': 'entertainment', 'label': l10n.entertainment},
      {'tag': 'other', 'label': l10n.other},
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addPassword), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            // Service Name
            TextFormField(
              controller: _serviceController,
              decoration: InputDecoration(
                labelText: l10n.serviceName,
                hintText: l10n.serviceNameHint,
                border: const OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? '${l10n.serviceName} *' : null,
            ),
            Gap(16.h),

            // Username
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: l10n.username,
                border: const OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? '${l10n.username} *' : null,
            ),
            Gap(16.h),

            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: l10n.password,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? '${l10n.password} *' : null,
            ),
            Gap(20.h),

            // Category Selection
            Text(
              l10n.passwordCategory,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            Gap(10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: categories.map((cat) {
                final tag = cat['tag'] as String;
                final label = cat['label'] as String;
                final isSelected = _selectedCategory == tag;

                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = tag;
                    });
                  },
                );
              }).toList(),
            ),
            Gap(20.h),

            // Theme Color Selection
            Text(
              l10n.appearance,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            Gap(10.h),
            SizedBox(
              height: 44.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _colors.length,
                separatorBuilder: (_, __) => Gap(12.w),
                itemBuilder: (context, index) {
                  final col = _colors[index];
                  final isSelected = _selectedColor == col;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = col;
                      });
                    },
                    child: Container(
                      width: 44.w,
                      decoration: BoxDecoration(
                        color: Color(col),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3.r)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(col).withOpacity(0.5),
                                  blurRadius: 8.r,
                                  spreadRadius: 2.r,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            Gap(20.h),

            // Icon Selection
            Text(
              'Select Icon',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            Gap(10.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
              ),
              itemCount: _icons.length,
              itemBuilder: (context, index) {
                final item = _icons[index];
                final icon = item['icon'] as IconData;
                final code = item['code'] as int;
                final isSelected = _selectedIcon == code;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = code;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(_selectedColor).withOpacity(0.15)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: isSelected
                          ? Border.all(color: Color(_selectedColor), width: 2.r)
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Color(_selectedColor) : Colors.grey,
                      size: 24.r,
                    ),
                  ),
                );
              },
            ),
            Gap(40.h),

            // Save Button
            PrimaryButton(text: l10n.save, onPressed: () => _save(l10n)),
          ],
        ),
      ),
    );
  }
}
