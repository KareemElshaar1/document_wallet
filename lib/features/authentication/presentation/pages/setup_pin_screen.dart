import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glassmorphic_container.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _errorMessage = '';

  void _handleNumberPress(String value) {
    setState(() {
      _errorMessage = '';

      if (_pin.length < 4) {
        _pin += value;
      }

      if (_pin.length == 4) {
        if (!_isConfirming) {
          _confirmPin = _pin;
          _pin = '';
          _isConfirming = true;
        } else {
          if (_pin == _confirmPin) {
            context.read<AuthCubit>().setupNewPin(_pin);
          } else {
            _pin = '';
            _errorMessage = 'PIN codes do not match. Start over.';
            _isConfirming = false;
            _confirmPin = '';
          }
        }
      }
    });
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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                Gap(32.h),

                // Icon
                FadeInDown(
                  child: Icon(
                    Icons.security,
                    size: 60.r,
                    color: AppColors.primary,
                  ),
                ),

                Gap(20.h),

                // Title
                FadeInUp(
                  child: Text(
                    _isConfirming
                        ? 'Confirm your secure PIN'
                        : 'Create a secure PIN',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Gap(8.h),

                Text(
                  'Enter a 4-digit code to protect your offline documents',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                Gap(40.h),

                // PIN dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final filled = index < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 12.w),
                      width: 20.r,
                      height: 20.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.2),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.5),
                        ),
                      ),
                    );
                  }),
                ),

                // Error message fixed space
                SizedBox(
                  height: 36.h,
                  child: _errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const SizedBox(),
                ),

                Gap(10.h),

                // ✅ KEYPAD (FIXED OVERFLOW HERE)
                Expanded(
                  child: FadeInUp(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.6,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 10.h,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        if (index == 9) return const SizedBox();

                        if (index == 11) {
                          return InkWell(
                            onTap: _handleBackspace,
                            borderRadius: BorderRadius.circular(40.r),
                            child: Center(
                              child: Icon(Icons.backspace_outlined, size: 26.r),
                            ),
                          );
                        }

                        final value = index == 10 ? '0' : '${index + 1}';

                        return GlassmorphicContainer(
                          borderRadius: 40.r,
                          blur: 5,
                          child: InkWell(
                            onTap: () => _handleNumberPress(value),
                            borderRadius: BorderRadius.circular(40.r),
                            child: Center(
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Gap(20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
