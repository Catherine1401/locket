import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:locket/features/moments/data/datasources/remote/moment_datasource.dart';
import 'package:locket/features/moments/domain/entities/moment.dart';
import 'package:locket/features/moments/domain/entities/moment_page.dart';

final class MomentDatasourceImpl implements MomentDatasource {
  final Dio _dio;
  MomentDatasourceImpl(this._dio);

  @override
  Future<Moment?> createMoment(String filePath, String? caption) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: 'moment.jpg'),
        if (caption != null && caption.isNotEmpty) 'caption': caption,
      });
      final response = await _dio.post('/moments', data: formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Moment.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      log('MomentDatasourceImpl.createMoment error', error: e);
      rethrow;
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Map<String, dynamic> _query({String? nextCursor, String? prevCursor, int limit = 20}) {
    return {
      'limit': limit.toString(),
      if (nextCursor != null) 'nextCursor': nextCursor,
      if (prevCursor != null) 'prevCursor': prevCursor,
    };
  }

  MomentPage _parseFeedResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return MomentPage.fromJson(data);
      }
    }
    return MomentPage.empty();
  }

  GridPage _parseGridResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return GridPage.fromJson(data);
      }
    }
    return GridPage.empty();
  }

  // ── Feed ─────────────────────────────────────────────────────────────────────

  @override
  Future<MomentPage> getFeed({String? nextCursor, String? prevCursor}) async {
    try {
      final response = await _dio.get(
        '/moments/feed',
        queryParameters: _query(nextCursor: nextCursor, prevCursor: prevCursor),
      );
      return _parseFeedResponse(response);
    } catch (e) {
      log('getFeed error', error: e);
      return MomentPage.empty();
    }
  }

  @override
  Future<MomentPage> getFeedByUser(String userId, {String? nextCursor, String? prevCursor}) async {
    try {
      final response = await _dio.get(
        '/users/$userId/moments/feed',
        queryParameters: _query(nextCursor: nextCursor, prevCursor: prevCursor),
      );
      return _parseFeedResponse(response);
    } catch (e) {
      log('getFeedByUser error', error: e);
      return MomentPage.empty();
    }
  }

  @override
  Future<MomentPage> getMyFeed({String? nextCursor, String? prevCursor}) async {
    try {
      final response = await _dio.get(
        '/moments/me/feed',
        queryParameters: _query(nextCursor: nextCursor, prevCursor: prevCursor),
      );
      return _parseFeedResponse(response);
    } catch (e) {
      log('getMyFeed error', error: e);
      return MomentPage.empty();
    }
  }

  // ── Grid ─────────────────────────────────────────────────────────────────────

  @override
  Future<GridPage> getGrid({String? nextCursor}) async {
    try {
      final response = await _dio.get(
        '/moments/grid',
        queryParameters: _query(nextCursor: nextCursor, limit: 50),
      );
      return _parseGridResponse(response);
    } catch (e) {
      log('getGrid error', error: e);
      return GridPage.empty();
    }
  }

  @override
  Future<GridPage> getGridByUser(String userId, {String? nextCursor}) async {
    try {
      final response = await _dio.get(
        '/users/$userId/moments/grid',
        queryParameters: _query(nextCursor: nextCursor, limit: 50),
      );
      return _parseGridResponse(response);
    } catch (e) {
      log('getGridByUser error', error: e);
      return GridPage.empty();
    }
  }

  @override
  Future<GridPage> getMyGrid({String? nextCursor}) async {
    try {
      final response = await _dio.get(
        '/moments/me/grid',
        queryParameters: _query(nextCursor: nextCursor, limit: 50),
      );
      return _parseGridResponse(response);
    } catch (e) {
      log('getMyGrid error', error: e);
      return GridPage.empty();
    }
  }
}
