import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/app_exceptions.dart' as app_exceptions;
import '../services/logger_service.dart';
import 'supabase_client.dart';

class ApiService {
  final SupabaseClientService _supabase = SupabaseClientService();
  final LoggerService _logger = LoggerService();

  // Generic query methods
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? column,
    dynamic value,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _supabase.client.from(table).select() as dynamic;

      if (column != null && value != null) {
        query = query.eq(column, value);
      }

      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 20) - 1);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e, stack) {
      _logger.error('Database query error', error: e, stackTrace: stack);
      throw app_exceptions.DatabaseException(e.message);
    } catch (e, stack) {
      _logger.error('Unexpected query error', error: e, stackTrace: stack);
      throw app_exceptions.ServerException('An unexpected error occurred');
    }
  }

  Future<Map<String, dynamic>?> querySingle(
    String table,
    String column,
    dynamic value,
  ) async {
    try {
      final response = await _supabase.client
          .from(table)
          .select()
          .eq(column, value)
          .single();

      return response as Map<String, dynamic>?;
    } on PostgrestException catch (e, stack) {
      if (e.code == 'PGRST116') {
        return null;
      }
      _logger.error('Database query single error', error: e, stackTrace: stack);
      throw app_exceptions.DatabaseException(e.message);
    } catch (e, stack) {
      _logger.error('Unexpected query single error', error: e, stackTrace: stack);
      throw app_exceptions.ServerException('An unexpected error occurred');
    }
  }

  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _supabase.client
          .from(table)
          .insert(data)
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } on PostgrestException catch (e, stack) {
      _logger.error('Database insert error', error: e, stackTrace: stack);
      throw app_exceptions.DatabaseException(e.message);
    } catch (e, stack) {
      _logger.error('Unexpected insert error', error: e, stackTrace: stack);
      throw app_exceptions.ServerException('An unexpected error occurred');
    }
  }

  Future<List<Map<String, dynamic>>> insertAll(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final response = await _supabase.client.from(table).insert(data).select();
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e, stack) {
      _logger.error('Database insert all error', error: e, stackTrace: stack);
      throw app_exceptions.DatabaseException(e.message);
    } catch (e, stack) {
      _logger.error('Unexpected insert all error', error: e, stackTrace: stack);
      throw app_exceptions.ServerException('An unexpected error occurred');
    }
  }

  Future<void> update(
    String table,
    Map<String, dynamic> data,
    String column,
    dynamic value,
  ) async {
    try {
      await _supabase.client
          .from(table)
          .update(data)
          .eq(column, value);
    } on PostgrestException catch (e, stack) {
      _logger.error('Database update error', error: e, stackTrace: stack);
      throw app_exceptions.DatabaseException(e.message);
    } catch (e, stack) {
      _logger.error('Unexpected update error', error: e, stackTrace: stack);
      throw app_exceptions.ServerException('An unexpected error occurred');
    }
  }

  Future<void> delete(
    String table,
    String column,
    dynamic value,
  ) async {
    try {
      await _supabase.client.from(table).delete().eq(column, value);
    } on PostgrestException catch (e, stack) {
      _logger.error('Database delete error', error: e, stackTrace: stack);
      throw app_exceptions.DatabaseException(e.message);
    } catch (e, stack) {
      _logger.error('Unexpected delete error', error: e, stackTrace: stack);
      throw app_exceptions.ServerException('An unexpected error occurred');
    }
  }

  // Realtime subscription - simplified to avoid complex type issues
  void subscribeToTable(
    String table, {
    String? event,
    String? filterColumn,
    dynamic filterValue,
    required void Function(Map<String, dynamic> payload) onEvent,
  }) {
    try {
      final channel = _supabase.client.channel('public:$table');

      final eventType = event != null
          ? PostgresChangeEvent.values.firstWhere(
              (e) => e.name == event,
              orElse: () => PostgresChangeEvent.all,
            )
          : PostgresChangeEvent.all;

      channel.onPostgresChanges(
        table: table,
        schema: 'public',
        event: eventType,
        callback: (payload) {
          onEvent(payload as Map<String, dynamic>);
        },
      );

      channel.subscribe();
    } catch (e, stack) {
      _logger.error('Failed to subscribe to table', error: e, stackTrace: stack);
      throw app_exceptions.ServerException('Failed to subscribe to updates');
    }
  }

  // Storage operations
  Future<String> uploadFile(
    String bucket,
    String path,
    Uint8List fileBytes, {
    String? contentType,
  }) async {
    try {
      await _supabase.client.storage.from(bucket).uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(contentType: contentType),
          );

      final publicUrl = _supabase.client.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e, stack) {
      _logger.error('File upload error', error: e, stackTrace: stack);
      throw app_exceptions.StorageException('Failed to upload file');
    }
  }
}
