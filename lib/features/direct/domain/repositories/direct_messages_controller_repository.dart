import '../entities/Message.dart';

abstract interface class DirectMessagesControllerRepository {
  Stream<List<Message>> get messageStream;

  Future<void> init({required String chatId});
  Future<void> loadInitialPage();
  Future<void> loadNextPage();
  String? findByMessageIdAndReturnNickname({required String messageId});
  void removeMessage({required String messageId});
}
