class Message {
  Message({
    required this.createdAt,
    required this.nickname,
    required this.text,
    required this.messageId,
  });

  final DateTime createdAt;
  final String nickname;
  final String text;
  final String messageId;
}
