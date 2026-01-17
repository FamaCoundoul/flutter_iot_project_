
import '../entities/sensor.dart';
import '../repositories/sensors_repository.dart';

class GetSensors {
  final SensorsRepository repository;

  GetSensors(this.repository);

  Future<List<Sensor>> call() async {
    return await repository.getSensors();
  }
}