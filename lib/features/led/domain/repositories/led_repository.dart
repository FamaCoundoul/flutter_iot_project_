// features/led/domain/repositories/led_repository.dart
import '../entities/led_info.dart';

enum LedAction { on, off, toggle }

abstract class LedRepository {
  Future<LedInfo> getLedStatus();
  Future<void> toggleLed();
  Future<void> turnOnLed();
  Future<void>    turnOffLed();
}

