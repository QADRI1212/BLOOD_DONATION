import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/pagination_notifier.dart';
import '../../../shared/models/blood_request.dart';
import '../providers/blood_request_provider.dart';

final paginatedRequestsProvider = StateNotifierProvider.autoDispose<PaginatedRequestsNotifier, PaginatedState<BloodRequest>>((ref) {
  return PaginatedRequestsNotifier(ref);
});

class PaginatedRequestsNotifier extends PaginatedNotifier<BloodRequest> {
  final Ref _ref;

  PaginatedRequestsNotifier(this._ref);

  @override
  Future<List<BloodRequest>> fetchPage(int page, int pageSize) async {
    final dataSource = _ref.read(bloodRequestRemoteDataSourceProvider);
    return dataSource.getRequests(
      limit: pageSize,
      offset: page * pageSize,
    );
  }
}
