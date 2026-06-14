abstract class SensorRepository {
  Stream<double> gForceStream();
}

class MockSensorRepository implements SensorRepository {
  @override
  Stream<double> gForceStream() async* {
    yield 0.1;
    yield 0.4;
    yield 0.2;
    yield -0.52;
  }
}