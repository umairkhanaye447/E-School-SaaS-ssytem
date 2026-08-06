import 'package:eschool/data/models/childFeeDetails.dart';
import 'package:eschool/data/models/paymentTransaction.dart';
import 'package:eschool/utils/api.dart';
import 'package:flutter/foundation.dart';

class FeeRepository {
  //
  Future<List<ChildFeeDetails>> fetchChildFeeDetails(
      {required int childId, int? sessionYearId}) async {
    try {
      final result = await Api.get(
        url: Api.getStudentFeesDetailParent,
        useAuthToken: true,
        queryParameters: {
          "child_id": childId,
          if (sessionYearId != null) "session_year_id": sessionYearId,
        },
      );
      return ((result['data'] ?? []) as List)
          .map((e) => ChildFeeDetails.fromJson(Map.from(e ?? {})))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
      throw ApiException(e.toString());
    }
  }

  Future<({PaymentTransaction paymentTransaction, Map<String, dynamic> data})>
      payCompulsoryFee(
          {required String paymentMethod,
          required int childId,
          required int feeId,
          List<int>? installmentIds,
          double? advanceAmount}) async {
    try {
      final result = await Api.post(body: {
        "payment_method": paymentMethod,
        "child_id": childId,
        "fees_id": feeId,
        "installment_ids": installmentIds ?? [],
        "advance": advanceAmount ?? 0
      }, url: Api.payChildCompulsoryFees, useAuthToken: true);

      if (kDebugMode) {
        debugPrint("API Response for $paymentMethod: $result");
      }

      // Extract payment transaction
      final paymentTransaction = PaymentTransaction.fromJson(
          Map.from(result['data']['payment_transaction'] ?? {}));

      // Extract payment data based on payment method
      Map<String, dynamic> data;
      if (paymentMethod == "Flutterwave" || paymentMethod == "Paystack") {
        // For Flutterwave and Paystack, we need the entire data object as it contains the payment_link
        data = Map<String, dynamic>.from(result['data'] ?? {});

        if (kDebugMode) {
          debugPrint("Extracted payment data for $paymentMethod: $data");
        }
      } else {
        // For Stripe/Razorpay, extract payment_intent as before
        data =
            Map<String, dynamic>.from(result['data']['payment_intent'] ?? {});
      }

      return (paymentTransaction: paymentTransaction, data: data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error in payCompulsoryFee: $e");
      }
      throw ApiException(e.toString());
    }
  }

  Future<({PaymentTransaction paymentTransaction, Map<String, dynamic> data})>
      payOptionalFees(
          {required String paymentMethod,
          required int childId,
          required int feeId,
          required List<int> optionalFeeIds}) async {
    try {
      final result = await Api.post(body: {
        "payment_method": paymentMethod,
        "child_id": childId,
        "fees_id": feeId,
        "optional_id": optionalFeeIds
      }, url: Api.payChildOptionalFees, useAuthToken: true);

      if (kDebugMode) {
        debugPrint(
            "API Response for optional fees with $paymentMethod: $result");
      }

      // Extract payment transaction
      final paymentTransaction = PaymentTransaction.fromJson(
          Map.from(result['data']['payment_transaction'] ?? {}));

      // Extract payment data based on payment method
      Map<String, dynamic> data;
      if (paymentMethod == "Flutterwave" || paymentMethod == "Paystack") {
        // For Flutterwave and Paystack, we need the entire data object as it contains the payment_link
        data = Map<String, dynamic>.from(result['data'] ?? {});

        if (kDebugMode) {
          debugPrint("Extracted payment data for $paymentMethod: $data");
        }
      } else {
        // For Stripe/Razorpay, extract payment_intent as before
        data =
            Map<String, dynamic>.from(result['data']['payment_intent'] ?? {});
      }

      return (paymentTransaction: paymentTransaction, data: data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error in payOptionalFees: $e");
      }
      throw ApiException(e.toString());
    }
  }

  Future<String> getFeeReceipt(
      {required int childId, required int feeId}) async {
    try {
      final result = await Api.get(queryParameters: {
        "child_id": childId,
        "fees_id": feeId,
      }, url: Api.downloadFeeReceipt, useAuthToken: true);

      return result['pdf'] ?? "";
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
