import '../entities/device_info.dart';
import '../entities/system_status.dart';

abstract class DeviceRepository {
  Future<DeviceInfo> getDeviceInfo();
  Future<SystemStatus> getSystemStatus();
}