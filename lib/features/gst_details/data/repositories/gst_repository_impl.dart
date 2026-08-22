import 'package:dio/dio.dart';
import '../../../../core/utils/view_state.dart';
import '../../domain/entities/gst_entity.dart';
import '../../domain/repositories/gst_repository.dart';
import '../datasources/gst_mock_datasource.dart';
import '../models/gst_model.dart';

class GstRepositoryImpl implements GstRepository {
  final GstMockDataSource dataSource;

  GstRepositoryImpl({required this.dataSource});

  @override
  Future<Result<List<GstEntity>>> getGstDetails() async {
    try {
      final result = await dataSource.fetchGstDetails();
      return Result.success(result);
    } on DioException catch (e) {
      return Result.failure(AppFailure(e.error?.toString() ?? 'Network error'));
    } catch (e) {
      return Result.failure(AppFailure('Failed to load GST details'));
    }
  }

  @override
  Future<Result<GstEntity>> addGst(GstEntity gst) async {
    try {
      final saved = await dataSource.addGst(GstModel.fromEntity(gst));
      return Result.success(saved);
    } catch (e) {
      return Result.failure(AppFailure('Failed to save GST details'));
    }
  }

  @override
  Future<Result<GstEntity>> updateGst(GstEntity gst) async {
    try {
      final saved = await dataSource.updateGst(GstModel.fromEntity(gst));
      return Result.success(saved);
    } catch (e) {
      return Result.failure(AppFailure('Failed to update GST details'));
    }
  }

  @override
  Future<Result<bool>> deleteGst(String id) async {
    try {
      final ok = await dataSource.deleteGst(id);
      return Result.success(ok);
    } catch (e) {
      return Result.failure(AppFailure('Failed to delete GST details'));
    }
  }
}

