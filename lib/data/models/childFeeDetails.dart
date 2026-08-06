import 'package:eschool/data/models/classFeeType.dart';
import 'package:eschool/data/models/advanceFee.dart';
import 'package:eschool/data/models/classDetails.dart';
import 'package:eschool/data/models/feeDiscount.dart';
import 'package:eschool/data/models/installment.dart';
import 'package:eschool/data/models/paidFeeDetails.dart';
import 'package:eschool/data/models/sessionYear.dart';
import 'package:eschool/utils/labelKeys.dart';

class ChildFeeDetails {
  final int? id;
  final String? name;
  final String? dueDate;
  final double? dueCharges;
  final double? dueChargesInPercentage;
  final int? classId;
  final int? schoolId;
  final int? sessionYearId;
  final String? createdAt;
  final String? updatedAt;
  final double? minimumInstallmentAmount;
  final bool? includeFeeInstallments;
  final double? totalCompulsoryFees;
  final double? totalOptionalFees;
  final double? dueChargesAmount;
  final List<ClassFeeType>? compulsoryFees;
  final List<ClassFeeType>? optionalFees;
  final List<ClassFeeType>? fees;
  final List<PaidFeeDetails>? paidFees;
  final List<Installment>? installments;
  final SessionYear? sessionYear;
  final ClassDetails? classDetails;
  final bool? isOverdue;

  /// Discount / relief records applied to this fee (compulsory and/or optional).
  final List<FeeDiscount>? existingDiscounts;

  /// Total discount amount across all scopes as computed by the backend.
  final double? totalDiscountAmount;

  /// Net payable amount after discount (only sent for installment enabled fees).
  final double? netPayableAmount;

  /// Original fee amount before discount (only sent for installment enabled fees).
  final double? originalFeeAmount;

  /// Pending amount after discount and payments (installment enabled fees).
  final double? pendingAmount;

  ChildFeeDetails({
    this.dueChargesAmount,
    this.isOverdue,
    this.existingDiscounts,
    this.totalDiscountAmount,
    this.netPayableAmount,
    this.originalFeeAmount,
    this.pendingAmount,
    this.id,
    this.name,
    this.dueDate,
    this.dueCharges,
    this.classId,
    this.schoolId,
    this.sessionYearId,
    this.createdAt,
    this.updatedAt,
    this.minimumInstallmentAmount,
    this.includeFeeInstallments,
    this.totalCompulsoryFees,
    this.totalOptionalFees,
    this.compulsoryFees,
    this.optionalFees,
    this.fees,
    this.paidFees,
    this.installments,
    this.classDetails,
    this.sessionYear,
    this.dueChargesInPercentage,
  });

  ChildFeeDetails copyWith({
    int? id,
    double? dueChargesAmount,
    String? name,
    bool? isOverdue,
    String? dueDate,
    double? dueCharges,
    int? classId,
    int? schoolId,
    int? sessionYearId,
    String? createdAt,
    String? updatedAt,
    double? minimumInstallmentAmount,
    bool? includeFeeInstallments,
    double? totalCompulsoryFees,
    double? totalOptionalFees,
    List<ClassFeeType>? compulsoryFees,
    List<ClassFeeType>? optionalFees,
    List<ClassFeeType>? fees,
    List<PaidFeeDetails>? paidFees,
    List<Installment>? installments,
    SessionYear? sessionYear,
    ClassDetails? classDetails,
    double? dueChargesInPercentage,
    List<FeeDiscount>? existingDiscounts,
    double? totalDiscountAmount,
    double? netPayableAmount,
    double? originalFeeAmount,
    double? pendingAmount,
  }) {
    return ChildFeeDetails(
      isOverdue: isOverdue ?? this.isOverdue,
      dueChargesAmount: dueChargesAmount ?? this.dueChargesAmount,
      existingDiscounts: existingDiscounts ?? this.existingDiscounts,
      totalDiscountAmount: totalDiscountAmount ?? this.totalDiscountAmount,
      netPayableAmount: netPayableAmount ?? this.netPayableAmount,
      originalFeeAmount: originalFeeAmount ?? this.originalFeeAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      classDetails: classDetails ?? this.classDetails,
      sessionYear: sessionYear ?? this.sessionYear,
      id: id ?? this.id,
      name: name ?? this.name,
      dueDate: dueDate ?? this.dueDate,
      dueCharges: dueCharges ?? this.dueCharges,
      classId: classId ?? this.classId,
      schoolId: schoolId ?? this.schoolId,
      sessionYearId: sessionYearId ?? this.sessionYearId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      minimumInstallmentAmount:
          minimumInstallmentAmount ?? this.minimumInstallmentAmount,
      includeFeeInstallments:
          includeFeeInstallments ?? this.includeFeeInstallments,
      totalCompulsoryFees: totalCompulsoryFees ?? this.totalCompulsoryFees,
      totalOptionalFees: totalOptionalFees ?? this.totalOptionalFees,
      compulsoryFees: compulsoryFees ?? this.compulsoryFees,
      optionalFees: optionalFees ?? this.optionalFees,
      fees: fees ?? this.fees,
      paidFees: paidFees ?? this.paidFees,
      installments: installments ?? this.installments,
      dueChargesInPercentage:
          dueChargesInPercentage ?? this.dueChargesInPercentage,
    );
  }

  ChildFeeDetails.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        isOverdue = json['is_overdue'] as bool?,
        dueChargesAmount =
            double.parse((json['due_charges_amount'] ?? 0).toString()),
        name = json['name'] as String?,
        dueDate = json['due_date'] as String?,
        dueCharges = double.parse((json['due_charges'] ?? 0).toString()),
        dueChargesInPercentage =
            double.parse((json['due_charges_in_percentage'] ?? 0).toString()),
        classId = json['class_id'] as int?,
        schoolId = json['school_id'] as int?,
        sessionYearId = json['session_year_id'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        minimumInstallmentAmount =
            double.parse((json['minimum_installment_amount'] ?? 0).toString()),
        includeFeeInstallments = json['include_fee_installments'] as bool?,
        totalCompulsoryFees =
            double.parse((json['total_compulsory_fees'] ?? 0).toString()),
        compulsoryFees = ((json['compulsory_fees'] ?? []) as List)
            .map((e) => ClassFeeType.fromJson(Map.from(e ?? {})))
            .toList(),
        optionalFees = ((json['optional_fees'] ?? []) as List)
            .map((e) => ClassFeeType.fromJson(Map.from(e ?? {})))
            .toList(),
        fees = ((json['fees_class_type'] ?? []) as List)
            .map((e) => ClassFeeType.fromJson(Map.from(e ?? {})))
            .toList(),
        paidFees = ((json['fees_paid'] ?? []) as List)
            .map((e) => PaidFeeDetails.fromJson(Map.from(e ?? {})))
            .toList(),
        installments = ((json['installments'] ?? []) as List)
            .map((e) => Installment.fromJson(Map.from(e ?? {})))
            .toList(),
        sessionYear =
            SessionYear.fromJson(Map.from(json['session_year'] ?? {})),
        classDetails = ClassDetails.fromJson(Map.from(json['class'] ?? {})),
        existingDiscounts = ((json['existing_discounts'] ?? []) as List)
            .map((e) => FeeDiscount.fromJson(Map.from(e ?? {})))
            .toList(),
        totalDiscountAmount =
            double.parse((json['total_discount_amount'] ?? 0).toString()),
        netPayableAmount = json['net_payable_amount'] == null
            ? null
            : double.parse(json['net_payable_amount'].toString()),
        originalFeeAmount = json['original_fee_amount'] == null
            ? null
            : double.parse(json['original_fee_amount'].toString()),
        pendingAmount = json['pending_amount'] == null
            ? null
            : double.parse(json['pending_amount'].toString()),
        totalOptionalFees =
            double.parse((json['total_optional_fees'] ?? 0).toString());

  Map<String, dynamic> toJson() => {
        'id': id,
        'is_overdue': isOverdue,
        'name': name,
        'due_date': dueDate,
        'due_charges': dueCharges,
        'class_id': classId,
        'school_id': schoolId,
        'session_year_id': sessionYearId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'minimum_installment_amount': minimumInstallmentAmount,
        'include_fee_installments': includeFeeInstallments,
        'total_compulsory_fees': totalCompulsoryFees,
        'total_optional_fees': totalOptionalFees,
        'compulsory_fees': compulsoryFees?.map((e) => e.toJson()).toList(),
        'optional_fees': optionalFees?.map((e) => e.toJson()).toList(),
        'fees_class_type': fees?.map((e) => e.toJson()).toList(),
        'fees_paid': paidFees?.map((e) => e.toJson()).toList(),
        'installments': installments?.map((e) => e.toJson()).toList(),
        'class': classDetails?.toJson(),
        'session_year': sessionYear?.toJson(),
        'due_charges_amount': dueChargesAmount,
        'due_charges_in_percentage': dueChargesInPercentage,
        'existing_discounts':
            existingDiscounts?.map((e) => e.toJson()).toList(),
        'total_discount_amount': totalDiscountAmount,
        'net_payable_amount': netPayableAmount,
        'original_fee_amount': originalFeeAmount,
        'pending_amount': pendingAmount,
      };

  String getFeePaymentStatus() {
    if (paidFees?.isEmpty ?? true) {
      return pendingKey;
    }
    return paidFees!.first.isFullyPaid == 1 ? paidKey : partiallyPaidKey;
  }

  bool isGivenOptionalFeePaid({required int optionalFeeId}) {
    if ((paidFees ?? []).isEmpty) {
      return false;
    }

    return paidFees!.first.optionalPaidFees!
        .where((element) => element.id == optionalFeeId)
        .toList()
        .isNotEmpty;
  }

  bool isFeeOverDue() {
    return isOverdue ?? false;
  }

  double getTotalCompulsoryAmountWithDue() {
    return (dueChargesAmount ?? 0.0) + (totalCompulsoryFees ?? 0.0);
  }

  double remainingFeeAmountToPay() {
    if (paidFees!.isEmpty) {
      return totalCompulsoryFees ?? 0.0;
    } else {
      double totalPaidAmount = 0.0;
      for (var compulsoryPaidAmount
          in (paidFees!.first.compulsoryPaidFees ?? [])) {
        totalPaidAmount =
            totalPaidAmount + (compulsoryPaidAmount.amount ?? 0.0);
      }
      //
      return (totalCompulsoryFees ?? 0.0) - totalPaidAmount;
    }
  }

  bool didUserPaidPreviousCompulsoryFeeInInstallment() {
    //If user has paid any amount using installment
    return (installments ?? []).isNotEmpty
        ? installments!.where((element) => (element.isPaid ?? false)).isNotEmpty
        : false;
  }

  bool hasPaidCompulsoryFullyOrUsingInstallment() {
    //If user has paid any amount
    return !((paidFees ?? [])
        .where((element) => (element.compulsoryPaidFees ?? []).isNotEmpty)
        .isNotEmpty);
  }

  bool isCompulsoryFeeFullyPaid() {
    //If user has paid any amount using installment
    return (paidFees?.isNotEmpty ?? false)
        ? (paidFees!
            .where((element) => element.isFullyPaid == 1)
            .toList()
            .isNotEmpty)
        : false;
  }

  /// Unpaid installments that are already due and must be part of the current
  /// payment (shown as "Outstanding installment(s)" in the summary).
  ///
  /// An installment is due when:
  /// - the backend applied a due charge to it (overdue penalty), OR
  /// - it comes before the installment currently being collected. This covers
  ///   unpaid installments whose due date has passed but that have no due
  ///   charge yet (e.g. still inside a grace period) — without this they would
  ///   fall between "outstanding" and "next" and be silently skipped from the
  ///   payment (and their amount would wrongly surface as payable "advance").
  List<Installment> dueInstallments() {
    final all = installments ?? [];

    // Position of the installment currently being collected: the backend
    // flagged current one, else the first unpaid one (nothing precedes it, so
    // the position rule adds nothing in that fallback case).
    final current = currentInstallment();
    final currentIndex =
        current.id == null ? -1 : all.indexWhere((e) => e.id == current.id);

    final due = <Installment>[];
    for (var i = 0; i < all.length; i++) {
      final installment = all[i];
      if (installment.isPaid ?? false) continue;
      // The current installment itself is handled as the "next" installment
      // of the payment, never as an outstanding one.
      if (installment.isCurrent ?? false) continue;
      final hasDueCharge = (installment.dueChargeAmount ?? 0.0) != 0.0;
      final isBeforeCurrent = currentIndex != -1 && i < currentIndex;
      if (hasDueCharge || isBeforeCurrent) {
        due.add(installment);
      }
    }
    return due;
  }

  bool hasAnyDueInstallment() {
    return dueInstallments().isNotEmpty;
  }

  List<Installment> unpaidInstallments() {
    return (installments ?? [])
        .where((element) => !(element.isPaid ?? false))
        .toList();
  }

  bool hasAnyUnpaidInstallment() {
    return unpaidInstallments().isNotEmpty;
  }

  bool hasOptionalFees() {
    return (optionalFees ?? []).isNotEmpty;
  }

  bool hasAnyUnpaidOptionlFee() {
    return (optionalFees ?? [])
        .where((e) => (e.isPaid ?? false) == false)
        .toList()
        .isNotEmpty;
  }

  List<Installment> paidInstallments() {
    return (installments ?? []).where((e) => (e.isPaid ?? false)).toList();
  }

  double remainingInstallmentAmount() {
    double remaining = 0.0;

    for (var installment in (installments ?? [])) {
      if (!(installment.isPaid ?? false)) {
        // For an unpaid installment the amount still owed is:
        //   max(0, installmentAmount - paidAmount - advancePaid - discount)
        //   + dueCharge
        // The due charge is a penalty that must be paid together with the
        // installment, so it has to be part of the remaining total — and it is
        // added AFTER clamping the fee part so excess relief can never swallow
        // it, matching how the payable amount is computed on the fee screen.
        final dueCharge = installment.isInstallmentOverdue()
            ? (installment.dueChargeAmount ?? 0.0)
            : 0.0;
        remaining += netRemainingOfInstallment(installment) + dueCharge;
      }
    }

    return remaining > 0.0 ? remaining : 0.0;
  }

  Installment currentInstallment() {
    final index = (installments ?? [])
        .indexWhere((element) => (element.isCurrent ?? false));
    if (index != -1) {
      return installments![index];
    }

    // If no installment is marked as current, find the first unpaid one
    final unpaidIndex =
        (installments ?? []).indexWhere((element) => !(element.isPaid ?? true));
    if (unpaidIndex != -1) {
      return installments![unpaidIndex];
    }

    return Installment.fromJson({});
  }

  // Get the next installment that needs to be paid (even if not marked as current)
  Installment nextUnpaidInstallment() {
    // First try to get the current installment if it's unpaid
    final current = currentInstallment();
    if (!(current.isPaid ?? true) && current.id != null) {
      return current;
    }

    // Otherwise find the first unpaid one
    final unpaidInstallments = this.unpaidInstallments();
    if (unpaidInstallments.isNotEmpty) {
      // Sort by ID to get them in order
      unpaidInstallments.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
      return unpaidInstallments.first;
    }

    return Installment.fromJson({});
  }

  /// Amount still owed on an installment after deducting any advance already
  /// paid toward it, clamped to >= 0 (before relief/discount and before due
  /// charges).
  ///
  /// This is the single source of truth for the "remaining minus advance"
  /// figure. Advance payments are tracked separately from paid_amount by the
  /// backend (the per-installment cards subtract them the same way), so they
  /// must be deducted here too or totals over-report what is still owed.
  double installmentAmountAfterAdvance(Installment installment) {
    final advancePaid =
        installmentTotalAdvancePaidAmount(installmentId: installment.id ?? 0);
    final base = installment.remainingAmount - advancePaid;
    return base > 0.0 ? base : 0.0;
  }

  /// Net amount still owed on an installment: [installmentAmountAfterAdvance]
  /// minus its relief/discount, clamped to >= 0.
  /// Due charges are intentionally excluded: they are penalties on the
  /// installments being paid now, not future fee amount an advance could go
  /// toward.
  double netRemainingOfInstallment(Installment installment) {
    final netRemaining = installmentAmountAfterAdvance(installment) -
        (installment.discountAmount ?? 0.0);
    return netRemaining > 0.0 ? netRemaining : 0.0;
  }

  /// Cached because [ChildFeeDetails] is immutable for a screen's lifetime and
  /// the value is read multiple times per rebuild.
  late final double _maximumAdvanceInstallmentAmount =
      _computeMaximumAdvanceInstallmentAmount();

  double maximumAdvanceInstallmentAmount() => _maximumAdvanceInstallmentAmount;

  double _computeMaximumAdvanceInstallmentAmount() {
    // Get next installment and due installments
    final nextInstallment = nextUnpaidInstallment();
    final dueInsts = dueInstallments();

    // Net remaining of the next installment (part of the current payment).
    // Must be net of its discount — the same basis as the unpaid total below —
    // otherwise the discount gets subtracted twice and the maximum advance
    // comes out too low by exactly the relief amount.
    double nextInstallmentAmount = 0.0;
    if (nextInstallment.id != null && !(nextInstallment.isPaid ?? false)) {
      // Check if this installment is already in due installments
      if (!dueInsts.any((inst) => inst.id == nextInstallment.id)) {
        nextInstallmentAmount = netRemainingOfInstallment(nextInstallment);
      }
    }

    // Net remaining of overdue installments (also part of the current payment).
    double outstandingNetAmount = 0.0;
    for (var installment in dueInsts) {
      outstandingNetAmount += netRemainingOfInstallment(installment);
    }

    // Sum up remaining amounts of all unpaid installments (net of their discounts)
    // This represents the total left to pay across all future installments.
    double totalUnpaidNetRemaining = 0.0;
    for (var installment in (installments ?? [])) {
      if (!(installment.isPaid ?? false)) {
        totalUnpaidNetRemaining += netRemainingOfInstallment(installment);
      }
    }

    // Advance = total unpaid net remaining minus what's already being paid
    // (next installment + outstanding installments)
    double advanceMax =
        totalUnpaidNetRemaining - nextInstallmentAmount - outstandingNetAmount;

    // Ensure the value is not negative
    return advanceMax > 0.0 ? advanceMax : 0.0;
  }

  String optionalPaidDate({required int optionalFeeId}) {
    // Search across ALL paidFees entries, not just .first.
    // A student may have multiple payment records for the same fee.
    for (final paidFee in (paidFees ?? [])) {
      final optionalFeeIndex = (paidFee.optionalPaidFees ?? [])
          .indexWhere((element) => element.feesClassId == optionalFeeId);
      if (optionalFeeIndex != -1) {
        return paidFee.optionalPaidFees![optionalFeeIndex].date ?? "";
      }
    }
    return "";
  }

  String installmentPaidDate({required int installmentId}) {
    final installmentIndex = (paidFees ?? []).isEmpty
        ? -1
        : (paidFees!.first.compulsoryPaidFees ?? [])
            .indexWhere((element) => element.installmentId == installmentId);
    if (installmentIndex == -1) {
      return "";
    }
    return paidFees!.first.compulsoryPaidFees![installmentIndex].date ?? "";
  }

  List<AdvanceFee> installmentAdvancePaidAmount({required int installmentId}) {
    final installmentIndex = (paidFees ?? []).isEmpty
        ? -1
        : (paidFees!.first.compulsoryPaidFees ?? [])
            .indexWhere((element) => element.installmentId == installmentId);
    if (installmentIndex == -1) {
      return [];
    }
    return paidFees!.first.compulsoryPaidFees![installmentIndex].advanceFees ??
        [];
  }

  /// Total advance amount already paid toward the given installment.
  double installmentTotalAdvancePaidAmount({required int installmentId}) {
    double total = 0.0;
    for (final advanceFee
        in installmentAdvancePaidAmount(installmentId: installmentId)) {
      total += advanceFee.amount ?? 0.0;
    }
    return total;
  }

  bool hasUserPaidFullFeeWithoutInstallment() {
    return isCompulsoryFeeFullyPaid() &&
        !didUserPaidPreviousCompulsoryFeeInInstallment();
  }

  String fullCompulsoryFeePaidDate() {
    return (paidFees ?? []).isEmpty
        ? ""
        : (paidFees!.first.compulsoryPaidFees ?? []).isEmpty
            ? ""
            : (paidFees!.first.compulsoryPaidFees!.first.date ?? '');
  }

  // ----------------------------------------------------------------------------
  // Discount / Fee relief helpers
  // ----------------------------------------------------------------------------

  /// Whether installments are enabled for this fee.
  bool isInstallmentEnabled() => includeFeeInstallments ?? false;

  // Discount lists are derived by filtering [existingDiscounts]. They are read
  // several times per rebuild, so they are cached (the model is immutable for
  // the screen's lifetime) to avoid re-allocating a filtered list each call.
  late final List<FeeDiscount> _allDiscounts = existingDiscounts ?? [];
  late final List<FeeDiscount> _compulsoryDiscounts =
      _allDiscounts.where((d) => d.isCompulsory).toList();
  late final List<FeeDiscount> _optionalDiscounts =
      _allDiscounts.where((d) => d.isOptional).toList();

  /// All discount records (any scope).
  List<FeeDiscount> allDiscounts() => _allDiscounts;

  bool hasAnyDiscount() => allDiscounts().isNotEmpty;

  /// Discount records scoped to the compulsory fee.
  List<FeeDiscount> compulsoryDiscounts() => _compulsoryDiscounts;

  /// Discount records scoped to the optional fee.
  List<FeeDiscount> optionalDiscounts() => _optionalDiscounts;

  /// Discounts relevant for the currently selected tab.
  List<FeeDiscount> discountsForScope({required bool compulsory}) =>
      compulsory ? compulsoryDiscounts() : optionalDiscounts();

  bool hasCompulsoryDiscount() => compulsoryDiscounts().isNotEmpty;

  bool hasOptionalDiscount() => optionalDiscounts().isNotEmpty;

  /// Total relief applied to the compulsory fee.
  double totalCompulsoryDiscountAmount() => compulsoryDiscounts()
      .fold(0.0, (sum, d) => sum + d.effectiveDiscountAmount);

  /// Total relief applied to the optional fee.
  double totalOptionalDiscountAmount() => optionalDiscounts()
      .fold(0.0, (sum, d) => sum + d.effectiveDiscountAmount);

  /// Net payable for the compulsory fee after relief (never negative).
  /// Prefers the backend computed value when available, otherwise derives it.
  double compulsoryNetPayableAmount() {
    final derived =
        (totalCompulsoryFees ?? 0.0) - totalCompulsoryDiscountAmount();
    final value = netPayableAmount ?? derived;
    return value > 0.0 ? value : 0.0;
  }

  /// Returns the discount amount applied to a specific installment, derived from
  /// the discount items mapped to that installment id. Falls back to the
  /// installment's own discount_amount via the caller when no item is found.
  double installmentDiscountAmount({required int installmentId}) {
    double amount = 0.0;
    for (final discount in compulsoryDiscounts()) {
      for (final item in discount.itemsForFeeTypeId(installmentId)) {
        if (item.isInstallment) {
          amount += item.discountAmount ?? 0.0;
        }
      }
    }
    return amount;
  }
}
