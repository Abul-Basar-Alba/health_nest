// lib/src/services/payment_service.dart

import 'dart:convert';
import 'dart:math';

class PaymentService {
  // SSLCommerz Sandbox Credentials
  static const String storeId = 'ab68f66c73a5bf5';
  static const String storePassword = 'ab68f66c73a5bf5@ssl';

  // For Demo - Direct Gateway URL (Production এ backend থেকে আসবে)
  static const String demoGatewayUrl =
      'https://sandbox.sslcommerz.com/EasyCheckOut/testcddd';

  // Generate unique transaction ID
  static String generateTranId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNumber = random.nextInt(999999);
    return 'HEALTH_NEST_${timestamp}_$randomNumber';
  }

  // Initialize payment (Demo version for frontend)
  static Future<Map<String, dynamic>> initializePayment({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required double amount,
    required String productName,
    required String productCategory,
  }) async {
    try {
      final tranId = generateTranId();

      // Demo response (Real production এ backend API call করবে)
      await Future.delayed(const Duration(seconds: 1));

      return {
        'success': true,
        'sessionkey': 'demo_session_${DateTime.now().millisecondsSinceEpoch}',
        'gateway_url': '$demoGatewayUrl?amount=$amount&tran_id=$tranId',
        'tran_id': tranId,
        'amount': amount,
        'currency': 'BDT',
        'message': 'Payment gateway initialized successfully',
        'demo_info': {
          'store_id': storeId,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_phone': customerPhone,
          'product_name': productName,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Demo initialization completed. Real integration needs backend API.',
        'error_details': e.toString(),
      };
    }
  }

  // Demo payment validation
  static Future<Map<String, dynamic>> validatePayment({
    required String tranId,
    required double amount,
    required String currency,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return {
        'success': true,
        'status': 'VALID',
        'tran_date': DateTime.now().toIso8601String(),
        'tran_id': tranId,
        'val_id': 'demo_val_${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount.toString(),
        'store_amount': (amount * 0.97).toString(), // 3% gateway fee
        'bank_tran_id': 'DEMO_${DateTime.now().millisecondsSinceEpoch}',
        'card_type': 'MOBILEBANKING',
        'demo_note':
            'This is a demo validation. Real production needs proper backend integration.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Validation error: $e',
      };
    }
  }

  // Get payment methods with demo URLs
  static List<Map<String, dynamic>> getPaymentMethods() {
    return [
      {
        'name': 'bKash',
        'icon': '💰',
        'type': 'mobile_banking',
        'description': 'bKash Mobile Banking - ১৯০ থেকে payment করুন',
        'demo_url':
            'https://sandbox.sslcommerz.com/EasyCheckOut/testcddd?method=bkash',
      },
      {
        'name': 'Nagad',
        'icon': '💸',
        'type': 'mobile_banking',
        'description': 'Nagad Mobile Banking - ১৬৬ থেকে payment করুন',
        'demo_url':
            'https://sandbox.sslcommerz.com/EasyCheckOut/testcddd?method=nagad',
      },
      {
        'name': 'Rocket',
        'icon': '🚀',
        'type': 'mobile_banking',
        'description': 'Rocket Mobile Banking - ১৬২৯৮ থেকে payment করুন',
        'demo_url':
            'https://sandbox.sslcommerz.com/EasyCheckOut/testcddd?method=rocket',
      },
      {
        'name': 'Visa Card',
        'icon': '💳',
        'type': 'card',
        'description': 'Visa Credit/Debit Card - Test Card: 4242424242424242',
        'demo_url':
            'https://sandbox.sslcommerz.com/EasyCheckOut/testcddd?method=visa',
      },
      {
        'name': 'MasterCard',
        'icon': '💳',
        'type': 'card',
        'description':
            'MasterCard Credit/Debit Card - Test Card: 5555555555554444',
        'demo_url':
            'https://sandbox.sslcommerz.com/EasyCheckOut/testcddd?method=master',
      },
      {
        'name': 'Internet Banking',
        'icon': '🏦',
        'type': 'net_banking',
        'description': 'Bank Transfer - সব বাংলাদেশি ব্যাংক support করে',
        'demo_url':
            'https://sandbox.sslcommerz.com/EasyCheckOut/testcddd?method=internetbank',
      },
    ];
  }

  // Demo test numbers for mobile banking
  static Map<String, List<String>> getTestNumbers() {
    return {
      'bkash': [
        '01700000000', // Demo number for testing
        '01800000000',
        '01900000000',
      ],
      'nagad': [
        '01600000000',
        '01700000000',
        '01800000000',
      ],
      'rocket': [
        '01500000000',
        '01600000000',
        '01700000000',
      ],
    };
  }
}
