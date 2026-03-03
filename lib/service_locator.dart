import 'package:get_it/get_it.dart';
import 'package:simple_flutter_chat/core/notifications/notification_service.dart';
import 'package:simple_flutter_chat/core/sources/firebase_sources.dart';
import 'package:simple_flutter_chat/features/direct/data/repositories/direct_messages_controller_repository_impl.dart';
import 'package:simple_flutter_chat/features/direct/domain/repositories/direct_messages_controller_repository.dart';
import 'package:simple_flutter_chat/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:simple_flutter_chat/shared/data/repositories/notification_token_sync_repository_impl.dart';
import 'package:simple_flutter_chat/shared/data/repositories/presence_service_repository_impl.dart';
import 'package:simple_flutter_chat/shared/data/repositories/user_repository_impl.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/notification_token_sync_repository.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/presence_service_repository.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/user_repository.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/chats/data/repositories/chats_repository_impl.dart';
import 'features/chats/domain/repositories/chats_repository.dart';
import 'features/direct/data/repositories/direct_repository_impl.dart';
import 'features/direct/domain/repositories/direct_repository.dart';
import 'features/settings/domain/repositories/settings_repository.dart';

final sl = GetIt.instance;

Future<void> initializeSingletons() async {
  sl.registerLazySingleton(() => FirebaseAuthSource());
  sl.registerLazySingleton(() => FirebaseFirestoreSource());

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

  sl.registerLazySingleton<DirectMessagesControllerRepository>(
    () => DirectMessagesControllerRepositoryImpl(
      pageSize: 20,
      firestore: sl<FirebaseFirestoreSource>().instance,
    ),
  );

  sl.registerLazySingleton<PresenceServiceRepository>(
    () => PresenceServiceRepositoryImpl(
      firestore: sl<FirebaseFirestoreSource>().instance,
      userRep: sl<UserRepository>(),
    ),
  );

  sl.registerLazySingleton<NotificationTokenSyncRepository>(
    () => NotificationTokenSyncRepositoryImpl(
      firebaseAuth: sl<FirebaseAuthSource>().instance,
      firebaseFirestore: sl<FirebaseFirestoreSource>().instance,
      notificationService: sl<NotificationService>(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl<FirebaseAuthSource>().instance,
      firebaseFirestore: sl<FirebaseFirestoreSource>().instance,
      presenceServiceRepository: sl<PresenceServiceRepository>(),
      notificationTokenSyncRepository: sl<NotificationTokenSyncRepository>(),
    ),
  );

  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl());

  sl.registerLazySingleton<NotificationService>(() => NotificationService());
}
