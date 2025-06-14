import 'package:get_it/get_it.dart';

import 'data/datasources/i_local_datasource.dart';
import 'data/datasources/i_remote_datasource.dart';
import 'data/repositories/message_repository_impl.dart';
import 'domain/repositories/i_message_repository.dart';
import 'domain/usecases/send_message_use_case.dart';
import 'infrastructure/datasources/local_datasource_impl.dart';
import 'infrastructure/datasources/remote_datasource_impl.dart';
import 'infrastructure/services/logger_service.dart';

import 'domain/usecases/connect_to_device_usecase.dart';
import 'domain/usecases/disconnect_from_device_usecase.dart';
import 'domain/usecases/scan_for_devices_usecase.dart';
import 'presentation/features/bluetooth_scan/bloc/bluetooth_scan_bloc.dart';

// Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton(() => LoggerService());

  // BLoCs
  sl.registerFactory(() => BluetoothScanBloc(scanForDevicesUseCase: sl()));

  // Use Cases
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => ScanForDevicesUseCase(sl()));
  sl.registerLazySingleton(() => ConnectToDeviceUseCase(sl()));
  sl.registerLazySingleton(() => DisconnectFromDeviceUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<IMessageRepository>(
    () => MessageRepositoryImpl(
      localDatasource: sl(),
      remoteDatasource: sl(),
    ),
  );

  // Datasources
  sl.registerLazySingleton<IRemoteDatasource>(
    () => RemoteDatasourceImpl(logger: sl()),
  );
  sl.registerLazySingleton<ILocalDatasource>(
    () => LocalDatasourceImpl(logger: sl()),
  );

  // External (e.g., Bluetooth client, DB client)
  // Example: sl.registerLazySingleton(() => SomeBluetoothClient());
} 