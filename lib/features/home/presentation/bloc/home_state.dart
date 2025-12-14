part of 'home_bloc.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<Auction> liveAuctions;
  final List<Auction> upcomingAuctions;
  final List<Category> categories;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.liveAuctions = const [],
    this.upcomingAuctions = const [],
    this.categories = const [],
    this.errorMessage,
  });

  bool get isLoading => status == HomeStatus.loading;
  bool get hasError => status == HomeStatus.error;

  HomeState copyWith({
    HomeStatus? status,
    List<Auction>? liveAuctions,
    List<Auction>? upcomingAuctions,
    List<Category>? categories,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      liveAuctions: liveAuctions ?? this.liveAuctions,
      upcomingAuctions: upcomingAuctions ?? this.upcomingAuctions,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        liveAuctions,
        upcomingAuctions,
        categories,
        errorMessage,
      ];
}
