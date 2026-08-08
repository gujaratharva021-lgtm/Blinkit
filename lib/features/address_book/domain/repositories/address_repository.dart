import '../../../../core/utils/view_state.dart';
import '../entities/address_entity.dart';

abstract class AddressRepository {
  Future<Result<List<AddressEntity>>> getAddresses();
  Future<Result<AddressEntity>> addAddress(AddressEntity address);
  Future<Result<AddressEntity>> updateAddress(AddressEntity address);
  Future<Result<bool>> deleteAddress(String id);
  Future<Result<bool>> setDefaultAddress(String id);
}

