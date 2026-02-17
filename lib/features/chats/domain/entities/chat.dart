class Chat {
  final String id;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageTimestamp;
  final Map<String, DateTime> lastReadTimestamp;
  final List<String> participants;

  Chat({
    required this.id,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageTimestamp,
    required this.lastReadTimestamp,
    required this.participants,
  });
}
