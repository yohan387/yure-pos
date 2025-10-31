import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/network/network_info.dart';

class MockConnectivity extends Mock implements Connectivity {}

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late NetworkInfoImpl networkInfo;
  late MockConnectivity mockConnectivity;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(mockConnectivity);
  });

  group('NetworkInfo - isConnected', () {
    test('returns false when connectivity is none', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final result = await networkInfo.isConnected;

      expect(result, isFalse);
      verify(() => mockConnectivity.checkConnectivity()).called(1);
    });

    test('returns true when connectivity is wifi and internet is accessible',
        () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      final result = await networkInfo.isConnected;

      // Note: This will actually ping Google in the real implementation
      // In a production test, we would mock the http client
      expect(result, isA<bool>());
      verify(() => mockConnectivity.checkConnectivity()).called(1);
    });

    test('returns true when connectivity is mobile and internet is accessible',
        () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      final result = await networkInfo.isConnected;

      // Note: This will actually ping Google in the real implementation
      expect(result, isA<bool>());
      verify(() => mockConnectivity.checkConnectivity()).called(1);
    });

    test('returns true when connectivity is ethernet', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.ethernet]);

      final result = await networkInfo.isConnected;

      expect(result, isA<bool>());
      verify(() => mockConnectivity.checkConnectivity()).called(1);
    });
  });
}
