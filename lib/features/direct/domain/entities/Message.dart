class Message {
  Message({
    required this.createdAt,
    required this.nickname,
    required this.text,
    required this.userId,
    required this.messageId,
    required this.editedAt,
    this.profileUrl,
    this.replyMessageId,
    this.replyMessage,
  });

  final DateTime createdAt;
  final String nickname;
  final String text;
  final String userId;
  final String messageId;
  final DateTime? editedAt;
  String? profileUrl;
  String? replyMessageId;
  String? replyMessage;
}
