import 'package:dio/dio.dart';
import '../../../../core/utils/view_state.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_mock_datasource.dart';
import '../models/address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressMockDataSource dataSource;

  AddressRepositoryImpl({required this.dataSource});

  @override
  Future<Result<List<AddressEntity>>> getAddresses() async {
    try {
      final result = await dataSource.fetchAddresses();
      return Result.success(result);
    } on DioException catch (e) {
      return Result.failure(AppFailure(e.error?.toString() ?? 'Network error'));
    } catch (e) {
      return Result.failure(AppFailure('Failed to load addresses'));
    }
  }

  @override
  Future<Result<AddressEntity>> addAddress(AddressEntity address) async {
    try {
      final saved =
          await dataSource.addAddress(AddressModel.fromEntity(address));
      return Result.success(saved);
    } catch (e) {
      return Result.failure(AppFailure('Failed to save address'));
    }
  }

  @override
  Future<Result<AddressEntity>> updateAddress(AddressEntity address) async {
    try {
      final saved =
          await dataSource.updateAddress(AddressModel.fromEntity(address));
      return Result.success(saved);
    } catch (e) {
      return Result.failure(AppFailure('Failed to update address'));
    }
  }

  @override
  Future<Result<bool>> deleteAddress(String id) async {
    try {
      final ok = await dataSource.deleteAddress(id);
      return Result.success(ok);
    } catch (e) {
      return Result.failure(AppFailure('Failed to delete address'));
    }
  }

  @override
  Future<Result<bool>> setDefaultAddress(String id) async {
    try {
      final ok = await dataSource.setDefaultAddress(id);
      return Result.success(ok);
    } catch (e) {
      return Result.failure(AppFailure('Failed to set default address'));
    }
  }
}

