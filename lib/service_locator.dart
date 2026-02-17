import 'package:get_it/get_it.dart';
import 'package:simple_flutter_chat/core/sources/firebase_sources.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';

final sl = GetIt.instance;

Future<void> initializeSingletons() async {
  sl.registerLazySingleton(() => FirebaseAuthSource());
  sl.registerLazySingleton(() => FirebaseFirestoreSource());
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl<FirebaseAuthSource>().instance,
      firebaseFirestore: sl<FirebaseFirestoreSource>().instance,
    ),
  );
}
