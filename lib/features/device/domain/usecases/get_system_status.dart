import '../entities/system_status.dart';
import '../repositories/device_repository.dart';

class GetSystemStatus {
  final DeviceRepository repository;

  GetSystemStatus(this.repository);

  Future<SystemStatus> call() async {
    return await repository.getSystemStatus();
  }
}