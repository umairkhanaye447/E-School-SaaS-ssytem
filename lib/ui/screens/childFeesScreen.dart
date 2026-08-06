import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/childFeeDetailsCubit.dart';
import 'package:eschool/cubits/schoolSessionYearsCubit.dart';
import 'package:eschool/data/models/childFeeDetails.dart';
import 'package:eschool/data/models/sessionYear.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/data/repositories/schoolRepository.dart';
import 'package:eschool/ui/widgets/customAppbar.dart';
import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/svgButton.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ChildFeesScreen extends StatefulWidget {
  final Student child;
  ChildFeesScreen({Key? key, required this.child}) : super(key: key);

  static Widget routeInstance() {
    return BlocProvider(
      create: (_) => SchoolSessionYearsCubit(SchoolRepository()),
      child: ChildFeesScreen(child: Get.arguments as Student),
    );
  }

  @override
  State<ChildFeesScreen> createState() => _ChildFeesScreenState();
}

class _ChildFeesScreenState extends State<ChildFeesScreen>
    with WidgetsBindingObserver {
  List<SessionYear> _sessionYears = [];
  SessionYear? _selectedSessionYear;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      _fetchSessionYears();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
  }

  void _fetchSessionYears() {
    context.read<SchoolSessionYearsCubit>().fetchSessionYears(
          useParentApi: context.read<AuthCubit>().isParent(),
          childId: widget.child.id ?? 0,
        );
  }

  void _fetchChildFeeDetails() {
    if (mounted) {
      context.read<ChildFeeDetailsCubit>().fetchChildFeeDetails(
            childId: widget.child.id ?? 0,
            sessionYearId: _selectedSessionYear?.id,
          );
    }
  }

  /// Opens filter bottom sheet with same design as assignment filter.
  void _onTapFilterButton() {
    if (_sessionYears.isEmpty) return;

    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Utils.bottomSheetTopRadius),
          topRight: Radius.circular(Utils.bottomSheetTopRadius),
        ),
      ),
      context: context,
      builder: (_) => _SessionYearFilterSheet(
        sessionYears: _sessionYears,
        selectedSessionYear: _selectedSessionYear,
        onSessionYearSelected: (sessionYear) {
          setState(() {
            _selectedSessionYear = sessionYear;
          });
          Navigator.of(context).pop();
          _fetchChildFeeDetails();
        },
      ),
    );
  }

  Widget _buildFeesContainer({required List<ChildFeeDetails> fees}) {
    return CustomRefreshIndicator(
      displacment: Utils.getScrollViewTopPadding(
        context: context,
        appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
      ),
      onRefreshCallback: () async {
        _fetchChildFeeDetails();
      },
      child: ListView.builder(
        padding: EdgeInsets.only(
          bottom: 25,
          left: Utils.screenContentHorizontalPadding,
          right: Utils.screenContentHorizontalPadding,
          top: Utils.getScrollViewTopPadding(
            context: context,
            appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
          ),
        ),
        itemCount: fees.length,
        itemBuilder: (context, index) {
          final feeDetails = fees[index];
          final valueTextStyle = TextStyle(
            fontSize: 13.0,
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.9),
          );
          final feePaymentStatusKey = feeDetails.getFeePaymentStatus();
          final feePaymentStatusColor =
              Utils.getFeePaymentStatusColor(context, feePaymentStatusKey);
          return Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(
                  Routes.childFeeDetails,
                  arguments: {
                    "childFeeDetails": feeDetails,
                    "child": widget.child,
                  },
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12.5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feeDetails.name ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          "${Utils.getTranslatedLabel(classKey)} : ${feeDetails.classDetails?.name ?? '-'}",
                          style: valueTextStyle,
                        ),
                        const Spacer(),
                        Text(
                          feeDetails.sessionYear?.name ?? "",
                          style: valueTextStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2.5),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Text(
                                "${Utils.getTranslatedLabel(statusKey)} : ",
                                style: valueTextStyle,
                              ),
                              Flexible(
                                child: Text(
                                  Utils.getTranslatedLabel(feePaymentStatusKey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: valueTextStyle.copyWith(
                                    color: feePaymentStatusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (feePaymentStatusKey != paidKey &&
                            !feeDetails
                                .didUserPaidPreviousCompulsoryFeeInInstallment())
                          Expanded(
                            flex: 3,
                            child: Text(
                              "${Utils.getTranslatedLabel(dueDateKey)} : ${feeDetails.dueDate ?? ''}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: valueTextStyle,
                              textAlign: TextAlign.end,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocListener<SchoolSessionYearsCubit, SchoolSessionYearsState>(
            listener: (context, state) {
              if (state is SchoolSessionYearsFetchSuccess) {
                _sessionYears = state.sessionYears;
                final defaultIndex = _sessionYears.indexWhere(
                  (e) => e.isDefault == 1,
                );
                _selectedSessionYear = defaultIndex != -1
                    ? _sessionYears[defaultIndex]
                    : (_sessionYears.isNotEmpty ? _sessionYears.first : null);
                setState(() {});
                _fetchChildFeeDetails();
              }
            },
            child: BlocBuilder<ChildFeeDetailsCubit, ChildFeeDetailsState>(
              builder: (context, state) {
                if (state is ChildFeeDetailsFetchSuccess) {
                  if (state.fees.isEmpty) {
                    return Center(
                      child: NoDataContainer(titleKey: noFeesFoundKey),
                    );
                  }
                  return _buildFeesContainer(fees: state.fees);
                }
                if (state is ChildFeeDetailsFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessageCode: state.errorMessage,
                      onTapRetry: () {
                        _fetchChildFeeDetails();
                      },
                    ),
                  );
                }
                return Center(
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: CustomAppBar(
              title: Utils.getTranslatedLabel(feesKey),
              onPressBackButton: () {
                Get.back();
              },
              trailingWidget: SvgButton(
                onTap: _onTapFilterButton,
                svgIconUrl: Utils.getImagePath("filter_icon.svg"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Private widget — same radio-button tile design as [AssignmentFilterBottomsheetContainer].
class _SessionYearFilterSheet extends StatefulWidget {
  final List<SessionYear> sessionYears;
  final SessionYear? selectedSessionYear;
  final Function(SessionYear) onSessionYearSelected;

  const _SessionYearFilterSheet({
    required this.sessionYears,
    required this.selectedSessionYear,
    required this.onSessionYearSelected,
  });

  @override
  State<_SessionYearFilterSheet> createState() =>
      _SessionYearFilterSheetState();
}

class _SessionYearFilterSheetState extends State<_SessionYearFilterSheet> {
  late SessionYear? _currentlySelected = widget.selectedSessionYear;

  Widget _buildFilterTile({
    required String title,
    required SessionYear sessionYear,
  }) {
    final isSelected = _currentlySelected?.id == sessionYear.id;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentlySelected = sessionYear;
          });
          widget.onSessionYearSelected(sessionYear);
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.75,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * (0.075),
        vertical: MediaQuery.of(context).size.height * (0.05),
      ),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Utils.bottomSheetTopRadius),
          topRight: Radius.circular(Utils.bottomSheetTopRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Utils.getTranslatedLabel(sessionYearKey),
            style: TextStyle(
              fontSize: 16.0,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(color: Theme.of(context).colorScheme.onSurface),
          ),
          ...widget.sessionYears.map(
            (sessionYear) => _buildFilterTile(
              title: sessionYear.name ?? '',
              sessionYear: sessionYear,
            ),
          ),
        ],
      ),
    );
  }
}
