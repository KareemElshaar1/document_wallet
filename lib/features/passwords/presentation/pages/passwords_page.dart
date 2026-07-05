import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/pin_auth_dialog.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/glassmorphic_container.dart';
import '../../data/models/password_model.dart';
import '../cubit/password_cubit.dart';
import '../cubit/password_state.dart';
import 'add_password_page.dart';

class PasswordsPage extends StatefulWidget {
  const PasswordsPage({super.key});

  @override
  State<PasswordsPage> createState() => _PasswordsPageState();
}

class _PasswordsPageState extends State<PasswordsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  Timer? _clipboardTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _clipboardTimer?.cancel();
    super.dispose();
  }

  void _copyToClipboard(String password, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.passwordCopied),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    _clipboardTimer?.cancel();
    _clipboardTimer = Timer(const Duration(seconds: 30), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });
  }

  Future<void> _handleRevealPassword(PasswordModel model, AppLocalizations l10n) async {
    final authenticated = await showPinAuthDialog(context);
    if (!authenticated || !mounted) return;

    final plain = await context.read<PasswordCubit>().getPlainPassword(model.id);
    if (plain != null && mounted) {
      _showDecryptedPasswordDialog(model, plain, l10n);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load password')),
      );
    }
  }

  void _showDecryptedPasswordDialog(
    PasswordModel model,
    String plainPassword,
    AppLocalizations l10n,
  ) {
    bool obscure = true;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(model.serviceName),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.username}:',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  Text(
                    model.username,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  Gap(12.h),
                  Text(
                    '${l10n.password}:',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          obscure ? '••••••••••••' : plainPassword,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: obscure ? null : 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscure = !obscure;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _copyToClipboard(plainPassword, l10n);
                  },
                  icon: const Icon(Icons.copy_rounded, color: Colors.white),
                  label: Text(l10n.copy),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final categories = [
      {'tag': 'social', 'label': l10n.social, 'icon': Icons.people_rounded},
      {'tag': 'banking', 'label': l10n.banking, 'icon': Icons.account_balance_rounded},
      {'tag': 'work', 'label': l10n.work, 'icon': Icons.business_center_rounded},
      {'tag': 'shopping', 'label': l10n.shopping, 'icon': Icons.shopping_bag_rounded},
      {'tag': 'entertainment', 'label': l10n.entertainment, 'icon': Icons.play_circle_fill_rounded},
      {'tag': 'other', 'label': l10n.other, 'icon': Icons.more_horiz_rounded},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.passwords),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),

          SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedCategory == null;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: ChoiceChip(
                      label: Text(l10n.allTypes),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                    ),
                  );
                }

                final cat = categories[index - 1];
                final tag = cat['tag'] as String;
                final label = cat['label'] as String;
                final icon = cat['icon'] as IconData;
                final isSelected = _selectedCategory == tag;

                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    avatar: Icon(icon, size: 16.r, color: isSelected ? Colors.white : AppColors.primary),
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = tag;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Gap(16.h),

          Expanded(
            child: BlocConsumer<PasswordCubit, PasswordState>(
              listener: (context, state) {
                if (state is PasswordError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is PasswordLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PasswordLoaded) {
                  var list = state.passwords;

                  if (_searchQuery.isNotEmpty) {
                    list = list.where((item) {
                      return item.serviceName.toLowerCase().contains(_searchQuery) ||
                          item.username.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  if (_selectedCategory != null) {
                    list = list.where((item) => item.categoryTag == _selectedCategory).toList();
                  }

                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.vpn_key_outlined, size: 80.r, color: Colors.grey.withOpacity(0.5)),
                          Gap(16.h),
                          Text(
                            l10n.noPasswords,
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                          Gap(8.h),
                          Text(
                            l10n.noPasswordsSubtitle,
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.all(16.r),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => Gap(12.h),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final color = Color(item.colorValue);

                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: const Icon(Icons.delete_rounded, color: Colors.white),
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
                          context.read<PasswordCubit>().deletePassword(item.id);
                        },
                        child: GlassmorphicContainer(
                          borderRadius: 16.r,
                          padding: EdgeInsets.zero,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16.r),
                              onTap: () => _handleRevealPassword(item, l10n),
                              child: Padding(
                                padding: EdgeInsets.all(16.r),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        IconData(item.iconCode, fontFamily: 'MaterialIcons'),
                                        color: color,
                                        size: 24.r,
                                      ),
                                    ),
                                    Gap(16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.serviceName,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Gap(4.h),
                                          Text(
                                            item.username,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.lock_rounded,
                                      color: AppColors.primary.withOpacity(0.5),
                                      size: 20.r,
                                    ),
                                    Gap(4.w),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.grey,
                                      size: 20.r,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_passwords',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPasswordPage()),
          );
          if (mounted) {
            context.read<PasswordCubit>().loadPasswords();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
