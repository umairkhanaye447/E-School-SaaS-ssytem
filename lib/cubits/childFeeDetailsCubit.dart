import 'package:eschool/data/models/childFeeDetails.dart';
import 'package:eschool/data/repositories/feeRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChildFeeDetailsState {}

class ChildFeeDetailsInitial extends ChildFeeDetailsState {}

class ChildFeeDetailsFetchInProgress extends ChildFeeDetailsState {}

class ChildFeeDetailsFetchSuccess extends ChildFeeDetailsState {
  final List<ChildFeeDetails> fees;
  final int childId;
  final int? sessionYearId;

  ChildFeeDetailsFetchSuccess({
    required this.fees,
    required this.childId,
    this.sessionYearId,
  });
}

class ChildFeeDetailsFetchFailure extends ChildFeeDetailsState {
  final String errorMessage;

  ChildFeeDetailsFetchFailure(this.errorMessage);
}

class ChildFeeDetailsCubit extends Cubit<ChildFeeDetailsState> {
  final FeeRepository _feeRepository;

  ChildFeeDetailsCubit(this._feeRepository) : super(ChildFeeDetailsInitial());

  void fetchChildFeeDetails({
    required int childId,
    int? sessionYearId,
  }) async {
    try {
      emit(ChildFeeDetailsFetchInProgress());
      emit(ChildFeeDetailsFetchSuccess(
        childId: childId,
        sessionYearId: sessionYearId,
        fees: await _feeRepository.fetchChildFeeDetails(
          childId: childId,
          sessionYearId: sessionYearId,
        ),
      ));
    } catch (e) {
      emit(ChildFeeDetailsFetchFailure(e.toString()));
    }
  }

  void refreshFees() {
    if (state is ChildFeeDetailsFetchSuccess) {
      final successState = state as ChildFeeDetailsFetchSuccess;
      fetchChildFeeDetails(
        childId: successState.childId,
        sessionYearId: successState.sessionYearId,
      );
    }
  }
}
