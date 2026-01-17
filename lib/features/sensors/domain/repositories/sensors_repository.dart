
import '../entities/sensor.dart';

abstract class SensorsRepository {
  Future<List<Sensor>> getSensors();
  Future<Sensor> getSensorById(int id);
  Stream<List<Sensor>> streamSensors();
}