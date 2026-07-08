import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/pagination_notifier.dart';
import '../../../shared/models/donation.dart';
import '../providers/donation_history_provider.dart';

final paginatedHistoryProvider = StateNotifierProvider.autoDispose.family<PaginatedHistoryNotifier, PaginatedState<Donation>, String>((ref, donorId) {
  return PaginatedHistoryNotifier(ref, donorId);
});

class PaginatedHistoryNotifier extends PaginatedNotifier<Donation> {
  final Ref _ref;
  final String donorId;

  PaginatedHistoryNotifier(this._ref, this.donorId);

  @override
  Future<List<Donation>> fetchPage(int page, int pageSize) async {
    final dataSource = _ref.read(donationRemoteDataSourceProvider);
    return dataSource.getDonationHistory(donorId, limit: pageSize, offset: page * pageSize);
  }
}
