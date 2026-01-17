
import '../entities/device_info.dart';
import '../repositories/device_repository.dart';

class GetDeviceInfo {
  final DeviceRepository repository;

  GetDeviceInfo(this.repository);

  Future<DeviceInfo> call() async {
    return await repository.getDeviceInfo();
  }
}