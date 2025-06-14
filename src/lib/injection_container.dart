import 'package:get_it/get_it.dart';

import 'data/datasources/i_local_datasource.dart';
import 'data/datasources/i_remote_datasource.dart';
import 'data/repositories/message_repository_impl.dart';
import 'domain/repositories/i_message_repository.dart';
import 'domain/usecases/send_message_use_case.dart';
import 'infrastructure/datasources/local_datasource_impl.dart';
import 'infrastructure/datasources/remote_datasource_impl.dart';
import 'infrastructure/services/logger_service.dart';

// Service Locator
final sl = GetIt.instance;

void init() {
  // Services
  sl.registerLazySingleton(() => LoggerService());

  // Use Cases
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<IMessageRepository>(
    () => MessageRepositoryImpl(remoteDatasource: sl(), localDatasource: sl()),
  );

  // Datasources
  sl.registerLazySingleton<IRemoteDatasource>(() => RemoteDatasourceImpl());
  sl.registerLazySingleton<ILocalDatasource>(
    () => LocalDatasourceImpl(logger: sl()),
  );

  // External (e.g., Bluetooth client, DB client)
  // Example: sl.registerLazySingleton(() => SomeBluetoothClient());
} 