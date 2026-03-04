import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_flutter_chat/core/logger.dart';

import '../../domain/entities/Message.dart';
import '../../domain/repositories/direct_messages_controller_repository.dart';

class DirectMessagesControllerRepositoryImpl
    implements DirectMessagesControllerRepository {
  DirectMessagesControllerRepositoryImpl({
    required this.pageSize,
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;
  String? chatId;
  final int pageSize;
  bool _hasMoreMessages = true;
  bool _isLoadingOlder = false;
  final StreamController<List<Message>> _messageStreamController =
      StreamController<List<Message>>.broadcast();

  @override
  Stream<List<Message>> get messageStream => _messageStreamController.stream;
  DocumentSnapshot<Map<String, dynamic>>? _oldestCursor;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _mainSubscription;

  final List<Message> _messages = [];

  CollectionReference<Map<String, dynamic>> get _messagesCollectionRef =>
      _firestore.collection("chats/$chatId/messages");

  void _emit() {
    _messageStreamController.add(_messages);
  }

  void _sortAsc() {
    _messages.sort((a, b) {
      final t = a.createdAt.compareTo(b.createdAt);
      if (t != 0) return t;
      return a.messageId.compareTo(b.messageId);
    });
  }

  @override
  Future<void> loadNextPage() async {
    if (_oldestCursor == null || !_hasMoreMessages || _isLoadingOlder) return;
    _isLoadingOlder = true;

    try {
      final snap = await _messagesCollectionRef
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_oldestCursor!)
          .limit(pageSize)
          .get();

      final docs = snap.docs;

      if (docs.isNotEmpty) {
        _oldestCursor = docs.last;
      }
      _hasMoreMessages = docs.length == pageSize;

      for (final doc in docs) {
        final parsed = doc.data();

        final String? profileUrl = parsed["profileUrl"];

        _insertIfMissing(
          Message(
            createdAt: (parsed["createdAt"] as Timestamp).toDate(),
            nickname: parsed["nickname"],
            text: parsed["text"],
            userId: parsed["userId"],
            messageId: doc.id,
            editedAt: (parsed["editedAt"] as Timestamp?)?.toDate(),
            profileUrl: profileUrl,
          ),
        );
      }

      _sortAsc();
      _emit();
    } finally {
      _isLoadingOlder = false;
    }
  }

  void _insertIfMissing(Message message) {
    final exists = _messages.any((m) => m.messageId == message.messageId);
    if (!exists) {
      _messages.add(message);
    }
  }

  void _updateIfExists(Message message) {
    final index = _messages.indexWhere((m) => m.messageId == message.messageId);
    if (index != -1) {
      _messages[index] = message;
    }
  }

  void _allMessagesSubscriptionListener() {
    _mainSubscription?.cancel();

    if (_messages.isEmpty) return;

    final oldestLoadedCreatedAt = _messages.first.createdAt;

    _mainSubscription = _messagesCollectionRef
        .orderBy("createdAt")
        .startAt([Timestamp.fromDate(oldestLoadedCreatedAt)])
        .snapshots()
        .listen((snap) {
          for (final change in snap.docChanges) {
            final parsed = change.doc.data() ?? {};
            if (parsed.isEmpty) continue;

            final createdAtRaw = parsed["createdAt"];
            DateTime? createdAt;
            if (createdAtRaw is Timestamp) {
              createdAt = createdAtRaw.toDate();
            } else {
              createdAt = DateTime.now();
            }

            final String? profileUrl = parsed["profileUrl"];

            final msg = Message(
              createdAt: createdAt,
              nickname: parsed["nickname"],
              text: parsed["text"],
              userId: parsed["userId"],
              messageId: change.doc.id,
              editedAt: (parsed["editedAt"] as Timestamp?)?.toDate(),
              profileUrl: profileUrl,
            );

            switch (change.type) {
              case (DocumentChangeType.added):
                _insertIfMissing(msg);
                break;
              case (DocumentChangeType.modified):
                _updateIfExists(msg);
                break;
              case DocumentChangeType.removed:
                _messages.removeWhere((m) => m.messageId == change.doc.id);
                break;
            }
          }

          _sortAsc();
          _emit();
        });
  }

  @override
  Future<void> loadInitialPage() async {
    final snap = await _messagesCollectionRef
        .orderBy("createdAt", descending: true)
        .limit(pageSize)
        .get();

    final docs = snap.docs;
    if (docs.isNotEmpty) _oldestCursor = docs.last;
    talker.info("We are here");
    _messages.addAll(
      docs.map((message) {
        final data = message.data() as Map<String, dynamic>? ?? {};
        final createdAtRaw = data["createdAt"];
        final createdAt = createdAtRaw is Timestamp
            ? createdAtRaw.toDate()
            : DateTime.now();

        final String? profileUrl = data["profileUrl"];

        return Message(
          createdAt: createdAt,
          nickname: data["nickname"],
          text: data["text"],
          userId: data["userId"],
          messageId: message.id,
          editedAt: (data["editedAt"] as Timestamp?)?.toDate(),
          profileUrl: profileUrl,
        );
      }).toList(),
    );

    talker.info(_messages);

    _sortAsc();
    _emit();
    _allMessagesSubscriptionListener();
  }

  @override
  Future<void> init({required String chatId}) async {
    this.chatId = chatId;
    _messages.clear();

    await loadInitialPage();
  }
}
