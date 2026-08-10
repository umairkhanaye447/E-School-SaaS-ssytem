import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/downloadFeeReceiptCubit.dart';
import 'package:eschool/cubits/latestPaymentTransactionCubit.dart';
import 'package:eschool/cubits/prePaymentTasksCubit.dart';
import 'package:eschool/cubits/schoolConfigurationCubit.dart';
import 'package:eschool/data/models/classFeeType.dart';
import 'package:eschool/data/models/childFeeDetails.dart';
import 'package:eschool/data/models/paymentGateway.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/data/repositories/feeRepository.dart';
import 'package:eschool/data/repositories/paymentRepository.dart';
import 'package:eschool/ui/screens/childFeeDetails/widgets/advanceInstallmentAmountBottomsheet.dart';
import 'package:eschool/ui/screens/childFeeDetails/widgets/downloadReceiptDialog.dart';
import 'package:eschool/ui/screens/childFeeDetails/widgets/feeInformationContainer.dart';
import 'package:eschool/ui/screens/childFeeDetails/widgets/feeReliefContainer.dart';
import 'package:eschool/ui/screens/childFeeDetails/widgets/feeSectionCard.dart';
import 'package:eschool/ui/screens/childFeeDetails/widgets/installments.dart';
import 'package:eschool/ui/screens/childFeeDetails/widgets/pendingTransactionWarningDialog.dart';
import 'package:eschool/ui/screens/childFeeDetails/widgets/selectPaymentMethodBottomsheet.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/ui/widgets/customTabBarContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/tabBarBackgroundContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/paymentGatewayService.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ChildFeeDetailsScreen extends StatefulWidget {
  final ChildFeeDetails childFeeDetails;
  final Student child;
  ChildFeeDetailsScreen(
      {Key? key, required this.childFeeDetails, required this.child})
      : super(key: key);

  static Widget routeInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PrePaymentTasksCubit(),
        ),
        BlocProvider(
            create: (context) =>
                LatestPaymentTransactionCubit(PaymentRepository())),
      ],
      child: ChildFeeDetailsScreen(
        childFeeDetails: arguments['childFeeDetails'] as ChildFeeDetails,
        child: arguments['child'] as Student,
      ),
    );
  }

  @override
  State<ChildFeeDetailsScreen> createState() => _ChildFeeDetailsScreenState();
}

class _ChildFeeDetailsScreenState extends State<ChildFeeDetailsScreen> {
  late String _currentlySelectedTabKey = compulsoryTitleKey;
  late List<int> _toPayOptionalFeeIds = [];
  late bool _enablePayInInstallments = false;
  late bool showPendingTransactionDialog = true;
  late double _advanceAmount = 0.0;

  final Razorpay _razorpay = Razorpay();
  PaymentGatewayService? _paymentGatewayService;

  /// Returns the date exactly as received from the API — no conversion.
  String _formatOptionalPaidDate(String? dateString) {
    return dateString ?? "";
  }

  @override
  void initState() {
    super.initState();
    // PaymentGatewayService will be initialized when needed in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize PaymentGatewayService with required dependencies from context
    if (_paymentGatewayService == null) {
      _paymentGatewayService = PaymentGatewayService(
        context: context,
        razorpay: _razorpay,
        onPaymentComplete: () {}, // Will be set during payment
        paymentDataProvider: context.read<PrePaymentTasksCubit>(),
        schoolConfigCubit: context.read<SchoolConfigurationCubit>(),
        authCubit: context.read<AuthCubit>(),
      );
    }
  }

  @override
  void dispose() {
    _paymentGatewayService?.dispose();
    super.dispose();
  }

  String getCurrencySymbol() {
    return context
            .read<SchoolConfigurationCubit>()
            .getSchoolConfiguration()
            .schoolSettings
            .currencySymbol ??
        '';
  }

  TextStyle getPaidOnTextStyle() {
    return TextStyle(
        fontSize: 12.0,
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.75));
  }

  /// Section heading (e.g. "Fee Breakdown") — Poppins Medium 14, #212121.
  TextStyle _sectionTitleStyle() => TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: Theme.of(context).colorScheme.secondary,
      );

  /// Breakdown line label — Poppins Regular 12, #494949.
  TextStyle _breakdownLabelStyle() => TextStyle(
        fontSize: 12.0,
        letterSpacing: 0.4,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Breakdown line value — Poppins Regular 12, #212121.
  TextStyle _breakdownValueStyle() => TextStyle(
        fontSize: 12.0,
        color: Theme.of(context).colorScheme.secondary,
      );

  /// Total row — Poppins Medium 14, #212121.
  TextStyle _totalRowStyle() => TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: Theme.of(context).colorScheme.secondary,
      );

  /// Outlined card container (1.5px #DFDFDF border, 16 radius, 16 padding).
  Widget _borderedCard({required Widget child}) => FeeSectionCard(child: child);

  /// 1px divider line used inside cards.
  Widget _cardLine() => const FeeCardDivider();

  Widget _sectionTitle(String title) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(title, style: _sectionTitleStyle()),
      );

  /// A single label/value line inside a breakdown card.
  Widget _breakdownRow({
    required String label,
    required String value,
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: isTotal ? _totalRowStyle() : _breakdownLabelStyle(),
          ),
        ),
        const SizedBox(width: 24.0),
        Text(
          value,
          style: isTotal
              ? _totalRowStyle()
              : (valueColor != null
                  ? _breakdownValueStyle().copyWith(color: valueColor)
                  : _breakdownValueStyle()),
        ),
      ],
    );
  }

  Widget _buildPayInInstallmentsCard() {
    return _borderedCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              Utils.getTranslatedLabel(payInInstallmentsKey),
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          SizedBox(
            height: 24.0,
            child: Transform.scale(
              scale: 0.85,
              child: Switch(
                value: _enablePayInInstallments,
                onChanged: (value) {
                  _enablePayInInstallments = value;
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///[This will to determine wheather to show pay in installment button or not]
  bool showPayInInstallmentsContainer() {
    //if intallment allowed by school
    if (widget.childFeeDetails.includeFeeInstallments ?? false) {
      return (widget.childFeeDetails
          .hasPaidCompulsoryFullyOrUsingInstallment());
    }
    return false;
  }

  //
  void onTapSelectOptionalFee({required int optionalFeeId}) {
    if (_toPayOptionalFeeIds.contains(optionalFeeId)) {
      _toPayOptionalFeeIds.removeWhere((element) => element == optionalFeeId);
    } else {
      _toPayOptionalFeeIds.add(optionalFeeId);
    }
    setState(() {});
  }

  void prePaymentTasksListener(
      BuildContext context, PrePaymentTasksState state) {
    _paymentGatewayService?.handlePrePaymentTasksListener(
      state: state,
      paymentMethodGetter: (state) =>
          (state as PrePaymentTasksSuccess).paymentMethod.paymentMethod ?? "",
      apiKeyGetter: (state) =>
          (state as PrePaymentTasksSuccess).paymentMethod.apiKey ?? "",
      errorMessageGetter: (state) =>
          (state as PrePaymentTasksFailure).errorMessage,
      isFailureState: (state) => state is PrePaymentTasksFailure,
      isSuccessState: (state) => state is PrePaymentTasksSuccess,
    );
  }

  //
  void startPrePaymentProcess(
      {double? advanceAmount, List<int>? installmentIds}) {
    ///[Will check for multiple enabled payment gateways]
    final enabledPaymentGateways = context
        .read<SchoolConfigurationCubit>()
        .getSchoolConfiguration()
        .enabledPaymentGateways;

    ///[If there is only one enabled payment gateway then start the prepayment process]
    if (enabledPaymentGateways.length == 1) {
      context.read<PrePaymentTasksCubit>().performPrePaymentTasks(
          advanceAmount: advanceAmount,
          installmentIds: installmentIds,
          optionalFeeIds: _toPayOptionalFeeIds,
          compulsoryFee: _currentlySelectedTabKey == compulsoryTitleKey,
          paymentMethod: enabledPaymentGateways.first,
          childId: widget.child.id ?? 0,
          feeId: widget.childFeeDetails.id ?? 0);
    } else {
      ///[If multiple payment gateway enabled by school then user need to select the payment gateway]
      Utils.showBottomSheet(
              child: SelectPaymentMethodBottomsheet(
                  paymentGeteways: enabledPaymentGateways),
              context: context)
          .then((selectedPaymentMethod) {
        if (selectedPaymentMethod != null) {
          ///[Start the prepayment process with selected payment gateway]
          context.read<PrePaymentTasksCubit>().performPrePaymentTasks(
              advanceAmount: advanceAmount,
              installmentIds: installmentIds,
              optionalFeeIds: _toPayOptionalFeeIds,
              compulsoryFee: _currentlySelectedTabKey == compulsoryTitleKey,
              paymentMethod: selectedPaymentMethod as PaymentGeteway,
              childId: widget.child.id ?? 0,
              feeId: widget.childFeeDetails.id ?? 0);
        }
      });
    }
  }

  ///[Listener of latest payment transaction cubit]
  void latestPaymentTransactionListener(
      {required LatestPaymentTransactionState state,
      double? advanceAmount,
      List<int>? installmentIds}) {
    if (state is LatestPaymentTransactionFetchSuccess) {
      ///[If there is any pending transaciton by this user in recent time then show the warning]
      if (context
          .read<LatestPaymentTransactionCubit>()
          .doesUserHaveLatestPendingTransactions()) {
        ///[Show warning]
        Get.dialog<bool>(PendingTransactionWarningDialog()).then((value) {
          if (value != null && value) {
            startPrePaymentProcess(
                advanceAmount: advanceAmount, installmentIds: installmentIds);
          }
        });
      } else {
        startPrePaymentProcess(
            advanceAmount: advanceAmount, installmentIds: installmentIds);
      }
    } else if (state is LatestPaymentTransactionFetchFailure) {
      Utils.showCustomSnackBar(
          context: context,
          errorMessage:
              Utils.getErrorMessageFromErrorCode(context, state.errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error);
    }
  }

  Widget _buildDownloadFeeReceiptButton() {
    if ((widget.childFeeDetails.paidFees ?? []).isEmpty) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: () {
        Get.dialog(BlocProvider(
          create: (context) => DownloadFeeReceiptCubit(FeeRepository()),
          child: DownloadReceiptDialog(
            child: widget.child,
            childFeeDetails: widget.childFeeDetails,
          ),
        ));
      },
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.transparent)),
        child: Icon(
          CupertinoIcons.printer,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return ScreenTopBackgroundContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomBackButton(
                onTap: () {
                  if (context.read<PrePaymentTasksCubit>().state
                      is PrePaymentTasksInProgress) {
                    return;
                  }
                  if (context.read<LatestPaymentTransactionCubit>().state
                      is LatestPaymentTransactionFetchInProgress) {
                    return;
                  }
                  Get.back();
                },
              ),
              Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                        end: Utils.screenContentHorizontalPadding),
                    child: _buildDownloadFeeReceiptButton(),
                  )),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  alignment: Alignment.topCenter,
                  width: boxConstraints.maxWidth * (0.5),
                  child: Text(
                    Utils.getTranslatedLabel(feeDetailsKey),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SegmentedTrack(boxConstraints: boxConstraints),
              AnimatedAlign(
                curve: Utils.tabBackgroundContainerAnimationCurve,
                duration: Utils.tabBackgroundContainerAnimationDuration,
                alignment: _currentlySelectedTabKey == compulsoryTitleKey
                    ? AlignmentDirectional.centerStart
                    : AlignmentDirectional.centerEnd,
                child:
                    TabBarBackgroundContainer(boxConstraints: boxConstraints),
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerStart,
                isSelected: _currentlySelectedTabKey == compulsoryTitleKey,
                onTap: () {
                  if (context.read<PrePaymentTasksCubit>().state
                      is PrePaymentTasksInProgress) {
                    return;
                  }
                  if (context.read<LatestPaymentTransactionCubit>().state
                      is LatestPaymentTransactionFetchInProgress) {
                    return;
                  }
                  setState(() {
                    _currentlySelectedTabKey = compulsoryTitleKey;
                  });
                },
                titleKey: compulsoryTitleKey,
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerEnd,
                isSelected: _currentlySelectedTabKey == optionalTitleKey,
                onTap: () {
                  if (context.read<PrePaymentTasksCubit>().state
                      is PrePaymentTasksInProgress) {
                    return;
                  }
                  if (context.read<LatestPaymentTransactionCubit>().state
                      is LatestPaymentTransactionFetchInProgress) {
                    return;
                  }
                  setState(() {
                    _currentlySelectedTabKey = optionalTitleKey;
                  });
                },
                titleKey: optionalTitleKey,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentInfoBackgroundContainer({required Widget child}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.raised,
        borderRadius: AppRadius.sheetTop,
      ),
      padding: const EdgeInsets.all(16.0),
      child: child,
    );
  }

  /// Clamps the chosen advance [value] to the allowed range and updates state so
  /// the Payable Amount recalculates immediately.
  ///
  /// The value arrives through the bottom sheet's onAmountSelected callback,
  /// which is the reliable channel — the Get.back result via `.then` can
  /// silently fail and leave the amount unapplied.
  void _applyAdvanceAmount(double value, double maximumAdvanceAmount) {
    var parsed = value;

    // Guard against NaN / negative / above-maximum values. The clamp also
    // applies when the maximum is 0 — that means "no advance allowed", not
    // "no limit".
    if (parsed.isNaN || parsed < 0.0) {
      parsed = 0.0;
    }
    if (parsed > maximumAdvanceAmount) {
      parsed = maximumAdvanceAmount;
    }

    if (!mounted) {
      return;
    }
    if (parsed != _advanceAmount) {
      setState(() {
        _advanceAmount = parsed;
      });
    }
  }

  Widget _buildAdvanceAmountContainer(double maximumAdvanceAmount) {
    return Row(
      children: [
        Expanded(
          child: Text(
            Utils.getTranslatedLabel(advanceAmountKey),
            style: TextStyle(
              fontSize: 12.0,
              letterSpacing: 0.4,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          "${getCurrencySymbol()}${_advanceAmount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        Material(
          child: Builder(builder: (context) {
            return GestureDetector(
              onTap: () {
                Utils.showBottomSheet(
                  child: AdvanceInstallmentAmountBottomsheet(
                    advanceInstallmentAmount: _advanceAmount,
                    maximumAmountLimit: maximumAdvanceAmount,
                    // Reliable channel: the sheet delivers the chosen value the
                    // moment the user confirms/clears. The Get.back result via
                    // `.then` can silently fail, so it is not relied upon.
                    onAmountSelected: (amount) =>
                        _applyAdvanceAmount(amount, maximumAdvanceAmount),
                  ),
                  context: context,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent)),
                child: Icon(
                  Icons.edit,
                  size: 18,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.3),
                ),
              ),
            );
          }),
        )
      ],
    );
  }

  ///[If compulsory fee is selected then show payment info]
  Widget _buildCompulsoryInstallmentPaymentInfoContainer() {
    // Computed once here and reused (visibility gate + advance editor) instead
    // of being recomputed for each read.
    final maximumAdvanceAmount =
        widget.childFeeDetails.maximumAdvanceInstallmentAmount();

    // Get all outstanding installments (ones that are due but not paid)
    final outstandingInstallments = widget.childFeeDetails.dueInstallments();

    // Get current installment
    final currentInstallment = widget.childFeeDetails.currentInstallment();

    // Get next installment if current is already paid
    final nextInstallment = (currentInstallment.isPaid ?? false)
        ? widget.childFeeDetails.nextUnpaidInstallment()
        : currentInstallment;

    // Whether the next installment is part of this payment (exists, not paid
    // yet, and not already counted among the outstanding/overdue installments).
    final isNextInstallmentInThisPayment = nextInstallment.id != null &&
        !(nextInstallment.isPaid ?? false) &&
        !outstandingInstallments.any((inst) => inst.id == nextInstallment.id);

    // Amount payable for the next installment: remaining minus any advance
    // already paid toward it, matching the per-installment card display.
    final nextInstallmentAmount = isNextInstallmentInThisPayment
        ? widget.childFeeDetails.installmentAmountAfterAdvance(nextInstallment)
        : 0.0;

    // Net for the next installment after its own relief (never negative) —
    // this is what actually gets charged for it.
    final nextInstallmentNetAmount = isNextInstallmentInThisPayment
        ? widget.childFeeDetails.netRemainingOfInstallment(nextInstallment)
        : 0.0;

    // Split the outstanding installments into their base (fee) part and their
    // due charge (penalty) part, so the penalty can be shown on its own line.
    // The base part is net of advances already paid toward each installment;
    // the net part additionally deducts each installment's own relief.
    double outstandingBaseAmount = 0.0;
    double outstandingNetAmount = 0.0;
    double dueChargesAmount = 0.0;
    for (var installment in outstandingInstallments) {
      outstandingBaseAmount +=
          widget.childFeeDetails.installmentAmountAfterAdvance(installment);
      outstandingNetAmount +=
          widget.childFeeDetails.netRemainingOfInstallment(installment);
      dueChargesAmount += (installment.dueChargeAmount ?? 0.0);
    }

    // Include the due charge of the next/current installment too, when it is
    // overdue and part of this payment (i.e. not one of the outstanding ones).
    // Gated on membership in the payment — not on the amount — because an
    // advance can bring the payable amount to zero while the penalty is still owed.
    if (isNextInstallmentInThisPayment &&
        nextInstallment.isInstallmentOverdue()) {
      dueChargesAmount += (nextInstallment.dueChargeAmount ?? 0.0);
    }

    // Collect installment IDs for payment
    List<int> installmentIds = [];

    // Add next installment ID only if it's part of this payment
    if (isNextInstallmentInThisPayment) {
      installmentIds.add(nextInstallment.id!);
    }

    // Add all outstanding installment IDs
    for (var installment in outstandingInstallments) {
      if (installment.id != null) {
        installmentIds.add(installment.id!);
      }
    }

    // Relief effectively applied to this payment, derived per installment as
    // (base - net). This clamps each installment's relief to its own base —
    // matching the per-installment cards — so the summary rows always
    // reconcile: bases − relief + advance + due charges = payable.
    final reliefAmount = (nextInstallmentAmount - nextInstallmentNetAmount) +
        (outstandingBaseAmount - outstandingNetAmount);
    final hasRelief = reliefAmount > 0.0;
    final hasDueCharges = dueChargesAmount > 0.0;

    // Payable = net of every installment being paid now + the user-entered
    // advance + due charges. The advance is added after relief (relief can
    // never swallow it), and relief never reduces the due charge penalty,
    // mirroring the full payment flow.
    final payableAmount = nextInstallmentNetAmount +
        outstandingNetAmount +
        _advanceAmount +
        dueChargesAmount;

    return _buildPaymentInfoBackgroundContainer(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show outstanding installments section if any due installments exist
        // (base fee only — the due charge is shown on its own line below).
        if (outstandingBaseAmount > 0.0) ...[
          _buildPaymentSummaryRow(
            label: Utils.getTranslatedLabel(outstandingInstallmentKey),
            value:
                "${getCurrencySymbol()}${outstandingBaseAmount.toStringAsFixed(2)}",
          ),
          const SizedBox(height: 12.0),
        ],
        // Show next installment section only if it's not already in outstanding
        if (nextInstallmentAmount > 0.0) ...[
          _buildPaymentSummaryRow(
            label: nextInstallment.name ?? '',
            value:
                "${getCurrencySymbol()}${nextInstallmentAmount.toStringAsFixed(2)}",
          ),
          const SizedBox(height: 12.0),
        ],
        // Show the advance amount section only when an advance is actually
        // possible (or one is already entered and may need clearing) —
        // otherwise the editor is a dead end that can only reject every input.
        if (maximumAdvanceAmount > 0.0 || _advanceAmount > 0.0) ...[
          _buildAdvanceAmountContainer(maximumAdvanceAmount),
          const SizedBox(height: 12.0),
        ],
        // Due charges (penalty) for the selected installments
        if (hasDueCharges) ...[
          _buildPaymentSummaryRow(
            label: Utils.getTranslatedLabel(dueChargesKey),
            value:
                "+${getCurrencySymbol()}${dueChargesAmount.toStringAsFixed(2)}",
            valueColor: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12.0),
        ],
        // Relief / discount for the selected installments
        if (hasRelief) ...[
          _buildPaymentSummaryRow(
            label: Utils.getTranslatedLabel(reliefAmountKey),
            value: "-${getCurrencySymbol()}${reliefAmount.toStringAsFixed(2)}",
            valueColor: Theme.of(context).colorScheme.onSecondary,
          ),
          const SizedBox(height: 12.0),
        ],
        _cardLine(),
        const SizedBox(height: 12.0),
        // Payable total after relief
        _buildPaymentSummaryRow(
          label: Utils.getTranslatedLabel(payableAmountKey),
          value: "${getCurrencySymbol()}${payableAmount.toStringAsFixed(2)}",
          isPayable: true,
        ),
        nextInstallment.id == null
            ? Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  "${Utils.getTranslatedLabel(nextInstallmentPaymentStartsFromKey)} ${Utils.formatApiDate(currentInstallment.dueDate ?? '')}",
                  style: getPaidOnTextStyle(),
                ),
              )
            : const SizedBox(),
        const SizedBox(
          height: 16,
        ),
        // Only show the pay button if there are installments to pay or advance amount
        (installmentIds.isNotEmpty || _advanceAmount > 0)
            ? _buildPayNowButton(
                installmentIds: installmentIds, advanceAmount: _advanceAmount)
            : const SizedBox()
      ],
    ));
  }

  ///[A single label/value row used inside the bottom payment summary]
  ///[isPayable -> the prominent "Payable Amount" total row (Poppins Medium 16)]
  Widget _buildPaymentSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isPayable = false,
  }) {
    final labelStyle = isPayable
        ? TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
            color: Theme.of(context).colorScheme.secondary,
          )
        : TextStyle(
            fontSize: 12.0,
            letterSpacing: 0.4,
            color: Theme.of(context).colorScheme.onSurface,
          );
    final valueStyle = isPayable
        ? TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
            color: Theme.of(context).colorScheme.secondary,
          )
        : TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: valueColor ?? Theme.of(context).colorScheme.secondary,
          );
    return Row(
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        const SizedBox(width: 8.0),
        Text(value, style: valueStyle),
      ],
    );
  }

  ///[If compulsory fee is selected then show payment info]
  Widget _buildCompulsoryFullPaidPaymentInfoContainer() {
    final feeAmount = widget.childFeeDetails.totalCompulsoryFees ?? 0.0;
    final isOverDue = widget.childFeeDetails.isFeeOverDue();
    final dueAmount =
        isOverDue ? (widget.childFeeDetails.dueChargesAmount ?? 0.0) : 0.0;

    final reliefAmount = widget.childFeeDetails.totalCompulsoryDiscountAmount();
    final hasRelief =
        widget.childFeeDetails.hasCompulsoryDiscount() && reliefAmount > 0.0;
    final hasDueCharges = isOverDue && dueAmount > 0.0;

    // Payable = fee - relief + due charges (relief never makes it negative).
    final payableAmount =
        ((feeAmount - reliefAmount) > 0.0 ? (feeAmount - reliefAmount) : 0.0) +
            dueAmount;

    return _buildPaymentInfoBackgroundContainer(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPaymentSummaryRow(
          label: Utils.getTranslatedLabel(totalFeeAmountKey),
          value: "${getCurrencySymbol()}${feeAmount.toStringAsFixed(2)}",
        ),
        // Due charges (penalty) shown before relief, matching the installment flow.
        if (hasDueCharges) ...[
          const SizedBox(height: 12.0),
          _buildPaymentSummaryRow(
            label: Utils.getTranslatedLabel(dueChargesKey),
            value: "+${getCurrencySymbol()}${dueAmount.toStringAsFixed(2)}",
            valueColor: Theme.of(context).colorScheme.error,
          ),
        ],
        if (hasRelief) ...[
          const SizedBox(height: 12.0),
          _buildPaymentSummaryRow(
            label: Utils.getTranslatedLabel(reliefAmountKey),
            value: "-${getCurrencySymbol()}${reliefAmount.toStringAsFixed(2)}",
            valueColor: Theme.of(context).colorScheme.onSecondary,
          ),
        ],
        const SizedBox(height: 12.0),
        _cardLine(),
        const SizedBox(height: 12.0),
        _buildPaymentSummaryRow(
          label: Utils.getTranslatedLabel(payableAmountKey),
          value: "${getCurrencySymbol()}${payableAmount.toStringAsFixed(2)}",
          isPayable: true,
        ),
        const SizedBox(height: 16.0),
        _buildPayNowButton()
      ],
    ));
  }

  Widget _buildOptionalBottmsheetPaymentInfoContainer() {
    if (!widget.childFeeDetails.hasOptionalFees()) {
      return const SizedBox();
    }

    if (widget.childFeeDetails.hasAnyUnpaidOptionlFee()) {
      double totalAmount = 0.0;
      double reliefAmount = 0.0;
      for (var optionalFee in (widget.childFeeDetails.optionalFees ??
          ([] as List<ClassFeeType>))) {
        if (_toPayOptionalFeeIds.contains(optionalFee.id)) {
          totalAmount = (optionalFee.amount ?? 0.0) + totalAmount;
          reliefAmount = (optionalFee.discountAmount ?? 0.0) + reliefAmount;
        }
      }

      final hasRelief = reliefAmount > 0.0;
      final payableAmount = (totalAmount - reliefAmount) > 0.0
          ? (totalAmount - reliefAmount)
          : 0.0;

      //
      return _buildPaymentInfoBackgroundContainer(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPaymentSummaryRow(
            label: Utils.getTranslatedLabel(totalFeeAmountKey),
            value: "${getCurrencySymbol()}${totalAmount.toStringAsFixed(2)}",
          ),
          if (hasRelief) ...[
            const SizedBox(height: 12.0),
            _buildPaymentSummaryRow(
              label: Utils.getTranslatedLabel(reliefAmountKey),
              value:
                  "-${getCurrencySymbol()}${reliefAmount.toStringAsFixed(2)}",
              valueColor: Theme.of(context).colorScheme.onSecondary,
            ),
          ],
          const SizedBox(height: 12.0),
          _cardLine(),
          const SizedBox(height: 12.0),
          _buildPaymentSummaryRow(
            label: Utils.getTranslatedLabel(payableAmountKey),
            value: "${getCurrencySymbol()}${payableAmount.toStringAsFixed(2)}",
            isPayable: true,
          ),
          const SizedBox(height: 16.0),
          _buildPayNowButton()
        ],
      ));
    }

    return const SizedBox();
  }

  Widget _buildCompulsoryBottomPaymentInfoContainer() {
    if (widget.childFeeDetails.isCompulsoryFeeFullyPaid()) {
      return const SizedBox();
    }

    bool usedInstallment = _enablePayInInstallments ||
        (widget.childFeeDetails
            .didUserPaidPreviousCompulsoryFeeInInstallment());

    if (usedInstallment) {
      return _buildCompulsoryInstallmentPaymentInfoContainer();
    }

    return _buildCompulsoryFullPaidPaymentInfoContainer();
  }

  Widget _buildPayNowButton(
      {double? advanceAmount, List<int>? installmentIds}) {
    return BlocConsumer<LatestPaymentTransactionCubit,
        LatestPaymentTransactionState>(
      listener: (context, state) {
        latestPaymentTransactionListener(
            state: state,
            advanceAmount: advanceAmount,
            installmentIds: installmentIds);
      },
      builder: (context, state) {
        return BlocConsumer<PrePaymentTasksCubit, PrePaymentTasksState>(
          listener: prePaymentTasksListener,
          builder: (context, paymentTaskState) {
            return PopScope(
              canPop: (state is! LatestPaymentTransactionFetchInProgress) &&
                  (paymentTaskState is! PrePaymentTasksInProgress),
              child: CustomRoundedButton(
                height: 48,
                radius: 8.0,
                // Full width within the bottom sheet's 16px horizontal padding.
                widthPercentage: (MediaQuery.of(context).size.width - 32.0) /
                    MediaQuery.of(context).size.width,
                textSize: 16.0,
                fontWeight: FontWeight.w500,
                backgroundColor: Theme.of(context).colorScheme.primary,
                buttonTitle: Utils.getTranslatedLabel(payNowKey),
                showBorder: false,
                child: (paymentTaskState is PrePaymentTasksInProgress) ||
                        (state is LatestPaymentTransactionFetchInProgress)
                    ? CustomCircularProgressIndicator(
                        widthAndHeight: 20,
                        strokeWidth: 2,
                      )
                    : null,
                onTap: () {
                  if (state is LatestPaymentTransactionFetchInProgress) {
                    return;
                  }
                  if (paymentTaskState is PrePaymentTasksInProgress) {
                    return;
                  }

                  if (_currentlySelectedTabKey == optionalTitleKey) {
                    ///
                    if (_toPayOptionalFeeIds.isEmpty) {
                      Utils.showCustomSnackBar(
                          context: context,
                          errorMessage: Utils.getTranslatedLabel(
                              pleaseSelectAtLeastOneOptionalFeeKey),
                          backgroundColor: Theme.of(context).colorScheme.error);
                      return;
                    }

                    ///
                  } else {
                    // If it's compulsory fees payment
                    if ((widget.childFeeDetails.currentInstallment().isPaid ??
                        false)) {
                      // If current installment is paid, check if there's a next unpaid installment
                      final nextInstallment =
                          widget.childFeeDetails.nextUnpaidInstallment();

                      // If there's no next installment and advance amount is zero, show error
                      if (nextInstallment.id == null && _advanceAmount <= 0.0) {
                        Utils.showCustomSnackBar(
                            context: context,
                            errorMessage: Utils.getTranslatedLabel(
                                advanceAmountCanNotBeZeroKey),
                            backgroundColor:
                                Theme.of(context).colorScheme.error);
                        return;
                      }
                    }
                  }

                  context
                      .read<LatestPaymentTransactionCubit>()
                      .fetchLatestPaymentTransactions();
                },
              ),
            );
          },
        );
      },
    );
  }

  ///[A single selectable optional fee row inside the breakdown card]
  Widget _buildOptionalFeeRow(ClassFeeType optionalFee) {
    final isOnlinePaymentEnabled = context
        .read<SchoolConfigurationCubit>()
        .getSchoolConfiguration()
        .isOnlineFeePaymentEnable();
    final isFeeSelectedToPay =
        _toPayOptionalFeeIds.contains(optionalFee.id ?? 0);
    final isPaid = optionalFee.isPaid ?? false;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isOnlinePaymentEnabled) ...[
          isPaid
              ? Icon(Icons.verified,
                  size: 20.0, color: Theme.of(context).colorScheme.onSecondary)
              : GestureDetector(
                  onTap: () {
                    onTapSelectOptionalFee(optionalFeeId: optionalFee.id ?? 0);
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    alignment: Alignment.center,
                    child: isFeeSelectedToPay
                        ? Icon(Icons.check,
                            size: 15.0,
                            color: Theme.of(context).colorScheme.primary)
                        : const SizedBox(),
                  ),
                ),
          const SizedBox(width: 10.0),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                optionalFee.feesType?.name ?? optionalFee.feesTypeName ?? "",
                style: _breakdownLabelStyle(),
              ),
              if (isPaid)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    "${Utils.getTranslatedLabel(paidOnKey)} ${_formatOptionalPaidDate(widget.childFeeDetails.optionalPaidDate(optionalFeeId: optionalFee.id ?? 0))}",
                    style: getPaidOnTextStyle(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 24.0),
        Text(
          "${getCurrencySymbol()}${(optionalFee.amount ?? 0).toStringAsFixed(2)}",
          style: _breakdownValueStyle(),
        ),
      ],
    );
  }

  Widget _buildOptionalFeesContainer() {
    final optionalFees = widget.childFeeDetails.optionalFees ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (optionalFees.isNotEmpty) ...[
          _sectionTitle(Utils.getTranslatedLabel(feeBreakdownKey)),
          const SizedBox(height: 8.0),
          _borderedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < optionalFees.length; i++) ...[
                  if (i != 0) ...[
                    const SizedBox(height: 12.0),
                    _cardLine(),
                    const SizedBox(height: 12.0),
                  ],
                  _buildOptionalFeeRow(optionalFees[i]),
                ],
              ],
            ),
          ),
        ],

        // ---- Fee Relief (discount) for optional scope ----
        if (widget.childFeeDetails.hasOptionalDiscount()) ...[
          const SizedBox(height: 16.0),
          FeeReliefContainer(
            childFeeDetails: widget.childFeeDetails,
            compulsory: false,
          ),
        ],

        const SizedBox(height: 50.0),
      ],
    );
  }

  ///[Fee Breakdown card listing each compulsory fee type and the total]
  Widget _buildCompulsoryBreakdownCard() {
    final fees = widget.childFeeDetails.compulsoryFees ?? [];
    final children = <Widget>[];
    for (var fee in fees) {
      children.add(_breakdownRow(
        label: fee.feesType?.name ?? fee.feesTypeName ?? "",
        value: "${getCurrencySymbol()}${(fee.amount ?? 0).toStringAsFixed(2)}",
      ));
      children.add(const SizedBox(height: 12.0));
      children.add(_cardLine());
      children.add(const SizedBox(height: 12.0));
    }

    // Due charge line (shown only when the fee is overdue).
    if (widget.childFeeDetails.isFeeOverDue() &&
        !widget.childFeeDetails
            .didUserPaidPreviousCompulsoryFeeInInstallment() &&
        !_enablePayInInstallments &&
        !widget.childFeeDetails.isCompulsoryFeeFullyPaid()) {
      children.add(_breakdownRow(
        label:
            "${Utils.getTranslatedLabel(dueKey)} (${widget.childFeeDetails.dueChargesInPercentage}%)",
        value:
            "${getCurrencySymbol()}${(widget.childFeeDetails.dueChargesAmount ?? 0).toStringAsFixed(2)}",
        valueColor: Theme.of(context).colorScheme.error,
      ));
      children.add(const SizedBox(height: 12.0));
      children.add(_cardLine());
      children.add(const SizedBox(height: 12.0));
    }

    children.add(_breakdownRow(
      label: Utils.getTranslatedLabel(totalFeeKey),
      value:
          "${getCurrencySymbol()}${(widget.childFeeDetails.totalCompulsoryFees ?? 0).toStringAsFixed(2)}",
      isTotal: true,
    ));

    // Paid-on line for a fully paid (non installment) fee.
    if (widget.childFeeDetails.hasUserPaidFullFeeWithoutInstallment()) {
      children.add(const SizedBox(height: 12.0));
      children.add(_cardLine());
      children.add(const SizedBox(height: 12.0));
      children.add(_breakdownRow(
        label: Utils.getTranslatedLabel(paidOnKey),
        value: _formatOptionalPaidDate(
            widget.childFeeDetails.fullCompulsoryFeePaidDate()),
      ));
    }

    return _borderedCard(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ));
  }

  ///[Installments card with the list of installments and remaining amount]
  Widget _buildInstallmentsCard() {
    return _borderedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Installments(childFeeDetails: widget.childFeeDetails),
          _cardLine(),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: Text(
                  Utils.getTranslatedLabel(remainingAmountKey),
                  style: _totalRowStyle(),
                ),
              ),
              const SizedBox(width: 24.0),
              Text(
                "${getCurrencySymbol()}${widget.childFeeDetails.remainingInstallmentAmount().toStringAsFixed(2)}",
                style: _totalRowStyle()
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompulsoryFeesContainer() {
    final showInstallmentsList = _enablePayInInstallments ||
        widget.childFeeDetails.didUserPaidPreviousCompulsoryFeeInInstallment();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Fee Breakdown ----
        _sectionTitle(Utils.getTranslatedLabel(feeBreakdownKey)),
        const SizedBox(height: 8.0),
        _buildCompulsoryBreakdownCard(),

        // ---- Fee Relief (discount) ----
        if (widget.childFeeDetails.hasCompulsoryDiscount()) ...[
          const SizedBox(height: 16.0),
          FeeReliefContainer(
            childFeeDetails: widget.childFeeDetails,
            compulsory: true,
          ),
        ],

        // ---- Pay In Installments toggle ----
        if (showPayInInstallmentsContainer()) ...[
          const SizedBox(height: 16.0),
          _buildPayInInstallmentsCard(),
        ],

        // ---- Installments list ----
        if (showInstallmentsList) ...[
          const SizedBox(height: 16.0),
          _buildInstallmentsCard(),
        ],

        const SizedBox(height: 50.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * (0.3),
                  left: Utils.screenContentHorizontalPadding,
                  right: Utils.screenContentHorizontalPadding,
                  top: Utils.getScrollViewTopPadding(
                      context: context,
                      appBarHeightPercentage:
                          Utils.appBarBiggerHeightPercentage)),
              child: Column(
                children: [
                  FeeInformationContainer(
                    child: widget.child,
                    childFeeDetails: widget.childFeeDetails,
                  ),
                  const SizedBox(height: 16.0),
                  _currentlySelectedTabKey == compulsoryTitleKey
                      ? _buildCompulsoryFeesContainer()
                      : _buildOptionalFeesContainer()
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: context
                    .read<SchoolConfigurationCubit>()
                    .getSchoolConfiguration()
                    .isOnlineFeePaymentEnable()
                ? (_currentlySelectedTabKey == compulsoryTitleKey)
                    ? _buildCompulsoryBottomPaymentInfoContainer()
                    : _buildOptionalBottmsheetPaymentInfoContainer()
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
