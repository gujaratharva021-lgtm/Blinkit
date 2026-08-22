import 'package:flutter/foundation.dart';
import '../../../../core/utils/view_state.dart';
import '../../domain/entities/gst_entity.dart';
import '../../domain/repositories/gst_repository.dart';

class GstProvider extends ChangeNotifier {
  final GstRepository repository;

  GstProvider({required this.repository});

  ViewStatus status = ViewStatus.initial;
  String? errorMessage;
  List<GstEntity> gstList = [];
  final Set<String> pendingIds = {};
  bool isSaving = false;

  Future<void> loadGstDetails() async {
    status = ViewStatus.loading;
    notifyListeners();

    final result = await repository.getGstDetails();
    if (result.isSuccess) {
      gstList = result.data ?? [];
      status = gstList.isEmpty ? ViewStatus.empty : ViewStatus.loaded;
    } else {
      status = ViewStatus.error;
      errorMessage = result.failure?.message;
    }
    notifyListeners();
  }

  Future<bool> addGst(GstEntity gst) async {
    isSaving = true;
    notifyListeners();

    final result = await repository.addGst(gst);
    isSaving = false;
    if (result.isSuccess && result.data != null) {
      gstList = [...gstList, result.data!];
      status = ViewStatus.loaded;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<bool> updateGst(GstEntity gst) async {
    isSaving = true;
    notifyListeners();

    final result = await repository.updateGst(gst);
    isSaving = false;
    if (result.isSuccess && result.data != null) {
      gstList =
          gstList.map((g) => g.id == gst.id ? result.data! : g).toList();
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<void> deleteGst(String id) async {
    pendingIds.add(id);
    notifyListeners();

    final result = await repository.deleteGst(id);
    pendingIds.remove(id);
    if (result.isSuccess) {
      gstList = gstList.where((g) => g.id != id).toList();
      status = gstList.isEmpty ? ViewStatus.empty : ViewStatus.loaded;
    }
    notifyListeners();
  }
}

