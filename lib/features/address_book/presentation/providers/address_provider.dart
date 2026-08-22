import 'package:flutter/foundation.dart';
import '../../../../core/utils/view_state.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';

class AddressProvider extends ChangeNotifier {
  final AddressRepository repository;

  AddressProvider({required this.repository});

  ViewStatus status = ViewStatus.initial;
  String? errorMessage;
  List<AddressEntity> addresses = [];

  /// Per-item submitting flag (used for delete/set-default row spinners).
  final Set<String> pendingIds = {};
  bool isSaving = false;

  Future<void> loadAddresses() async {
    status = ViewStatus.loading;
    notifyListeners();

    final result = await repository.getAddresses();
    if (result.isSuccess) {
      addresses = result.data ?? [];
      status = addresses.isEmpty ? ViewStatus.empty : ViewStatus.loaded;
    } else {
      status = ViewStatus.error;
      errorMessage = result.failure?.message;
    }
    notifyListeners();
  }

  Future<bool> addAddress(AddressEntity address) async {
    isSaving = true;
    notifyListeners();

    final result = await repository.addAddress(address);
    isSaving = false;
    if (result.isSuccess && result.data != null) {
      addresses = [...addresses, result.data!];
      status = ViewStatus.loaded;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<bool> updateAddress(AddressEntity address) async {
    isSaving = true;
    notifyListeners();

    final result = await repository.updateAddress(address);
    isSaving = false;
    if (result.isSuccess && result.data != null) {
      addresses = addresses
          .map((a) => a.id == address.id ? result.data! : a)
          .toList();
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<void> deleteAddress(String id) async {
    pendingIds.add(id);
    notifyListeners();

    final result = await repository.deleteAddress(id);
    pendingIds.remove(id);
    if (result.isSuccess) {
      addresses = addresses.where((a) => a.id != id).toList();
      status = addresses.isEmpty ? ViewStatus.empty : ViewStatus.loaded;
    }
    notifyListeners();
  }

  Future<void> setDefaultAddress(String id) async {
    pendingIds.add(id);
    notifyListeners();

    final result = await repository.setDefaultAddress(id);
    pendingIds.remove(id);
    if (result.isSuccess) {
      addresses = addresses
          .map((a) => a.copyWith(isDefault: a.id == id))
          .toList();
    }
    notifyListeners();
  }
}

