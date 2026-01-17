import '../entities/led_info.dart';
import '../repositories/led_repository.dart';

class GetLedStatus {
  final LedRepository repository;

  GetLedStatus(this.repository);

  Future<LedInfo> call() async {
    return await repository.getLedStatus();
  }
}