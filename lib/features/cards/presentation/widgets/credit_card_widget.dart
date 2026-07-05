import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CreditCardWidget extends StatelessWidget {
  final String bankName;
  final String cardHolderName;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardType; // visa, mastercard, amex, other
  final int colorValue;
  final bool showBack;
  final VoidCallback onTap;

  const CreditCardWidget({
    super.key,
    required this.bankName,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardType,
    required this.colorValue,
    required this.showBack,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        tween: Tween<double>(begin: 0.0, end: showBack ? 180.0 : 0.0),
        builder: (context, val, child) {
          final isBack = val >= 90.0;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY((val * pi) / 180),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..rotateY(pi), // Correct mirroring
                    child: _buildBack(context),
                  )
                : _buildFront(context),
          );
        },
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(colorValue),
            Color(colorValue).withOpacity(0.8),
            Color(colorValue).withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(colorValue).withOpacity(0.4),
            blurRadius: 15.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bankName.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              _buildCardTypeIcon(),
            ],
          ),
          const Spacer(),
          // Chip
          Container(
            width: 40.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: Colors.amber.shade300.withOpacity(0.8),
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
          Gap(16.h),
          // Card Number
          Text(
            cardNumber,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          // Holder & Expiry
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARDHOLDER',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    cardHolderName.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    expiryDate,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(colorValue),
            Color(colorValue).withOpacity(0.8),
            Color(colorValue).withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(colorValue).withOpacity(0.4),
            blurRadius: 15.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Magnetic stripe
          Container(width: double.infinity, height: 40.h, color: Colors.black),
          Gap(20.h),
          // Signature stripe & CVV
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 35.h,
                    color: Colors.white70,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 10.w),
                    child: Text(
                      cardHolderName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 60.w,
                  height: 35.h,
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: Text(
                    cvv,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Back text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'This card is secure and encrypted completely offline in your Document Wallet. Do not share your CVV or PIN.',
              style: TextStyle(color: Colors.white38, fontSize: 8.sp),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTypeIcon() {
    IconData iconData = Icons.credit_card_rounded;
    if (cardType.toLowerCase() == 'visa') {
      iconData = Icons.payment_rounded;
    } else if (cardType.toLowerCase() == 'mastercard') {
      iconData = Icons.contactless_rounded;
    }

    return Icon(iconData, color: Colors.white, size: 30.r);
  }
}
