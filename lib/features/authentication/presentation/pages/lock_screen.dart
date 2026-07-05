import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/glassmorphic_container.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';

  void _handleNumberPress(String value) {
    if (_pin.length < 4) setState(() => _pin += value);

    if (_pin.length == 4) {
      context.read<AuthCubit>().enterPin(_pin);
      setState(() => _pin = '');
    }
  }

  void _handleBackspace() {
    setState(() {
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final errorMessage = state is AuthLocked ? state.errorMessage : null;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.bgDark,
                        AppColors.surfaceDark,
                        // ignore: deprecated_member_use
                        AppColors.primary.withOpacity(0.15),
                      ]
                    : [
                        AppColors.bgLight,
                        // ignore: deprecated_member_use
                        AppColors.primaryLight.withOpacity(0.35),
                        Colors.white,
                      ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Gap(48.h),

                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: EdgeInsets.all(22.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 24.r,
                              offset: Offset(0, 10.h),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 44.r,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Gap(24.h),

                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Text(
                            l10n.appName,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                            textAlign: TextAlign.center,
                          ),
                          Gap(8.h),
                          Text(
                            l10n.enterYourPin,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.75),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    Gap(36.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final filled = index < _pin.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.symmetric(horizontal: 12.w),
                          width: 16.r,
                          height: 16.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled
                                ? AppColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: filled
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.35),
                              width: 2,
                            ),
                          ),
                        );
                      }),
                    ),

                    SizedBox(
                      height: 36.h,
                      child: errorMessage != null && errorMessage.isNotEmpty
                          ? Center(
                              child: ShakeX(
                                child: Text(
                                  l10n.invalidPin,
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    Gap(12.h),

                    Expanded(
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.35,
                                crossAxisSpacing: 14.w,
                                mainAxisSpacing: 12.h,
                              ),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            if (index == 9) {
                              return const SizedBox.shrink();
                            }

                            if (index == 11) {
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _handleBackspace,
                                  borderRadius: BorderRadius.circular(40.r),
                                  child: Center(
                                    child: Icon(
                                      Icons.backspace_outlined,
                                      size: 24.r,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final value = index == 10 ? '0' : '${index + 1}';
                            return GlassmorphicContainer(
                              borderRadius: 40.r,
                              blur: 5.0,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _handleNumberPress(value),
                                  borderRadius: BorderRadius.circular(40.r),
                                  child: Center(
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: 26.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    Gap(24.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
