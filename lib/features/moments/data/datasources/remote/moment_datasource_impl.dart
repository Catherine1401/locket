import 'package:dio/dio.dart';
import 'package:locket/features/moments/data/datasources/remote/moment_datasource.dart';
import 'package:locket/features/moments/domain/entities/moment.dart';

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
      print('MomentDatasourceImpl.createMoment error: $e');
      rethrow;
    }
  }
}
