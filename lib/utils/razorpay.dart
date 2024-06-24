import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayment extends StatefulWidget {
  final int total;
  RazorPayment({required this.total});

  @override
  State<RazorPayment> createState() => _RazorPaymentState();
}

class _RazorPaymentState extends State<RazorPayment> {
  var _razorpay = Razorpay();
  var options;

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    options = {
      'key': 'rzp_live_Yks1y6vQ4yFdnu',
      'amount': widget.total * 100,
      'name': 'Bite Box',
      'description': 'This is payment for your order.',
      'prefill': {'contact': '6302928392', 'email': 'biteboxcanteen@gmail.com'}
    };
    _razorpay.open(options);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Navigator.pop(context, {
      "status": "success",
      "orderId": response.paymentId,
    });
    print("Payment has been successfull");
    print(response.orderId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Navigator.pop(context, {
      "status": "failed",
    });
    print("Payment has been failed");
    print(response.code);
    print(response.message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet");
    print(response.walletName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(),
    ));
  }
}
