import '../repositories/led_repository.dart';

class ControlLed {
  final LedRepository repository;

  ControlLed(this.repository);

  Future<void> toggle() async {
    return await repository.toggleLed();
  }

  Future<void> turnOn() async {
    return await repository.turnOnLed();
  }

  Future<void> turnOff() async {
    return await repository.turnOffLed();
  }
}