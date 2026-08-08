import '../../../../core/utils/view_state.dart';
import '../entities/gst_entity.dart';

abstract class GstRepository {
  Future<Result<List<GstEntity>>> getGstDetails();
  Future<Result<GstEntity>> addGst(GstEntity gst);
  Future<Result<GstEntity>> updateGst(GstEntity gst);
  Future<Result<bool>> deleteGst(String id);
}

