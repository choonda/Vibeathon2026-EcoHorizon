abstract class SensorRepository {
  Stream<double> gForceStream();
}

class MockSensorRepository implements SensorRepository {
  @override
  Stream<double> gForceStream() async* {
    await Future.delayed(const Duration(seconds: 3));
    yield 0.1;
    await Future.delayed(const Duration(seconds: 3));
    yield 0.4;
    await Future.delayed(const Duration(seconds: 3));
    yield 0.2;
    await Future.delayed(const Duration(seconds: 3));
    yield -0.52;
  }
}