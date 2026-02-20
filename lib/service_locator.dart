import 'package:get_it/get_it.dart';
import 'package:simple_flutter_chat/core/sources/firebase_sources.dart';
import 'package:simple_flutter_chat/shared/data/repositories/user_repository_impl.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/user_repository.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/chats/data/repositories/chats_repository_impl.dart';
import 'features/chats/domain/repositories/chats_repository.dart';
import 'features/direct/data/repositories/direct_repository_impl.dart';
import 'features/direct/domain/repositories/direct_repository.dart';

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

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      firebaseAuth: sl<FirebaseAuthSource>().instance,
      firebaseFirestore: sl<FirebaseFirestoreSource>().instance,
    ),
  );

  // TODO: GET ALL USER DATA FROM REPOSITORY NOT FROM FIREBASE AUTH DIRECTLY

  sl.registerLazySingleton<ChatsRepository>(
    () => ChatsRepositoryImpl(
      firebaseAuth: sl<FirebaseAuthSource>().instance,
      firebaseFirestore: sl<FirebaseFirestoreSource>().instance,
    ),
  );

  sl.registerLazySingleton<DirectRepository>(
    () => DirectRepositoryImpl(
      firestore: sl<FirebaseFirestoreSource>().instance,
      userRepo: sl<UserRepository>(),
    ),
  );
}
