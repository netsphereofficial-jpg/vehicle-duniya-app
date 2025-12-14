part of 'bidding_bloc.dart';

enum BiddingStatus { initial, loading, loaded, placing, placed, error }

class BiddingState extends Equatable {
  final BiddingStatus status;
  final List<Bid> myBids;
  final String? errorMessage;
  final String? successMessage;

  const BiddingState({
    this.status = BiddingStatus.initial,
    this.myBids = const [],
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == BiddingStatus.loading;
  bool get isPlacing => status == BiddingStatus.placing;
  bool get hasError => status == BiddingStatus.error;

  BiddingState copyWith({
    BiddingStatus? status,
    List<Bid>? myBids,
    String? errorMessage,
    String? successMessage,
  }) {
    return BiddingState(
      status: status ?? this.status,
      myBids: myBids ?? this.myBids,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [status, myBids, errorMessage, successMessage];
}
