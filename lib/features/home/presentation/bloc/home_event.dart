part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load request
class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

/// Manual refresh request (pull to refresh)
class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

/// Real-time update for live auctions
class HomeLiveAuctionsUpdated extends HomeEvent {
  final List<Auction> auctions;

  const HomeLiveAuctionsUpdated(this.auctions);

  @override
  List<Object?> get props => [auctions];
}

/// Real-time update for upcoming auctions
class HomeUpcomingAuctionsUpdated extends HomeEvent {
  final List<Auction> auctions;

  const HomeUpcomingAuctionsUpdated(this.auctions);

  @override
  List<Object?> get props => [auctions];
}
