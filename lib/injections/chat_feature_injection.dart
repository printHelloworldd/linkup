/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:get_it/get_it.dart';
import 'package:linkup/core/data/datasources/remote/firestore_datasource.dart';
import 'package:linkup/core/data/datasources/remote/supabase_datasource.dart';
import 'package:linkup/core/data/repository/firebase_messaging_repository_impl.dart';
import 'package:linkup/core/data/repository/secure_storage_repository_impl.dart';
import 'package:linkup/features/Authentication/data/repository/firebase_auth_repository_impl.dart';
import 'package:linkup/features/Chat/data/datasources/remote/chat_datasource.dart';
import 'package:linkup/features/Chat/data/repositories/chat_repository_impl.dart';
import 'package:linkup/features/Chat/domain/usecases/create_chat_room_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/delete_chat_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/delete_message_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/get_chats_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/get_messages_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/mark_chats_as_read_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/send_message_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/set_muted_status_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/set_pinned_status_uc.dart';
import 'package:linkup/features/Chat/presentation/bloc/chat_bloc.dart';
import 'package:linkup/features/Chat/presentation/provider/chats_list_provider.dart';
import 'package:linkup/features/Crypto/data/reposotory/crypto_repository_impl.dart';

final sl = GetIt.instance;

Future<void> initChatFeature() async {
  await _initDatasources();
  await _initRepositories();
  await _initUseCases();
  await _initStateProviders();
}

Future<void> _initDatasources() async {
  sl.registerLazySingleton<ChatDatasource>(() => ChatDatasource());
}

Future<void> _initRepositories() async {
  sl.registerLazySingleton<ChatRepositoryImpl>(
    () => ChatRepositoryImpl(
      chatDatasource: sl<ChatDatasource>(),
      firestoreDatasource: sl<FirestoreDatasource>(),
      supabaseDatasource: sl<SupabaseDatasource>(),
    ),
  );
}

Future<void> _initUseCases() async {
  sl.registerLazySingleton<CreateChatRoomUc>(
    () => CreateChatRoomUc(
      chatRepository: sl<ChatRepositoryImpl>(),
      cryptoRepository: sl<CryptoRepositoryImpl>(),
      secureStorageRepository: sl<SecureStorageRepositoryImpl>(),
    ),
  );
  sl.registerLazySingleton<GetChatsUc>(
    () => GetChatsUc(
      chatRepository: sl<ChatRepositoryImpl>(),
      cryptoRepository: sl<CryptoRepositoryImpl>(),
      secureStorageRepository: sl<SecureStorageRepositoryImpl>(),
    ),
  );
  sl.registerLazySingleton<GetMessagesUc>(
    () => GetMessagesUc(
      chatRepository: sl<ChatRepositoryImpl>(),
      cryptoRepository: sl<CryptoRepositoryImpl>(),
    ),
  );
  sl.registerLazySingleton<SendMessageUc>(
    () => SendMessageUc(
      chatRepository: sl<ChatRepositoryImpl>(),
      firebaseMessagingRepository: sl<FirebaseMessagingRepositoryImpl>(),
      cryptoRepository: sl<CryptoRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<DeleteMessageUc>(
    () => DeleteMessageUc(
      sl<ChatRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<DeleteChatUc>(
    () => DeleteChatUc(
      chatRepository: sl<ChatRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<MarkChatsAsReadUc>(
    () => MarkChatsAsReadUc(
      chatRepository: sl<ChatRepositoryImpl>(),
      firebaseAuthRepository: sl<FirebaseAuthRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<SetMutedStatusUc>(
    () => SetMutedStatusUc(
      chatRepository: sl<ChatRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<SetPinnedStatusUc>(
    () => SetPinnedStatusUc(
      chatRepository: sl<ChatRepositoryImpl>(),
    ),
  );
}

Future<void> _initStateProviders() async {
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(
      createChatRoomUc: sl<CreateChatRoomUc>(),
      getChatsUc: sl<GetChatsUc>(),
      sendMessageUc: sl<SendMessageUc>(),
      deleteMessageUc: sl<DeleteMessageUc>(),
      getMessagesUc: sl<GetMessagesUc>(),
      deleteChatUc: sl<DeleteChatUc>(),
      markChatsAsReadUc: sl<MarkChatsAsReadUc>(),
      setMutedStatusUc: sl<SetMutedStatusUc>(),
      setPinnedStatusUc: sl<SetPinnedStatusUc>(),
    ),
  );

  sl.registerFactory<ChatsListProvider>(
    () => ChatsListProvider(),
  );
}
