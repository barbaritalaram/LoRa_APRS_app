import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:src/infrastructure/services/logger_service.dart';

// Mock for path_provider
class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.'; // Use current directory for tests
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  group('LoggerService', () {
    late LoggerService loggerService;

    setUp(() async {
      loggerService = LoggerService();
      // Give time for async initialization
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('can be instantiated without errors', () {
      expect(loggerService, isNotNull);
    });

    test('log methods do not throw exceptions', () {
      expect(() => loggerService.d('debug message'), returnsNormally);
      expect(() => loggerService.i('info message'), returnsNormally);
      expect(() => loggerService.w('warning message'), returnsNormally);
      expect(() => loggerService.e('error message'), returnsNormally);
    });
  });
} 