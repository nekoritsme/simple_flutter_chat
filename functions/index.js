const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");
const {setGlobalOptions} = require("firebase-functions/v2");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

admin.initializeApp();

setGlobalOptions({maxInstances: 10});

exports.onMessageCreated = onDocumentCreated(
    "chats/{chatId}/messages/{messageId}",
    async (event) => {
      const messageData = event.data ? event.data.data() : null;
      if (!messageData) return;

      const chatId = event.params.chatId;
      const senderId = messageData.userId;

      if (!chatId || !senderId) return;

      const chatRef = admin.firestore().collection("chats").doc(chatId);
      const chatSnap = await chatRef.get();
      if (!chatSnap.exists) return;

      const chatData = chatSnap.data() || {};
      const participants = Array.isArray(chatData.participants) ?
      chatData.participants :
      [];

      const recipientIds = participants.filter((uid) => uid !== senderId);
      if (recipientIds.length === 0) return;

      const recipientSnaps = await Promise.all(
          recipientIds.map((uid) =>
            admin.firestore().collection("users").doc(uid).get(),
          ),
      );

      const nowMs = Date.now();
      const freshnessWindowMs = 90 * 1000;
      const tokens = [];

      for (const snap of recipientSnaps) {
        if (!snap.exists) continue;

        const userData = snap.data() || {};
        const isOnline = userData.isOnline === true;
        const lastSeenOnline = userData.lastSeenOnline;
        const hasToMillis =
        lastSeenOnline &&
        typeof lastSeenOnline.toMillis === "function";
        const lastSeenMs = hasToMillis ? lastSeenOnline.toMillis() : 0;
        const recentlyOnline = nowMs - lastSeenMs < freshnessWindowMs;

        if (isOnline && recentlyOnline) continue;

        if (Array.isArray(userData.fcmTokens)) {
          tokens.push(
              ...userData.fcmTokens.filter(
                  (token) => typeof token === "string" && token.length > 0,
              ),
          );
        } else if (
          typeof userData.fcmToken === "string" &&
        userData.fcmToken.length > 0
        ) {
          tokens.push(userData.fcmToken);
        }
      }

      const uniqueTokens = [...new Set(tokens)];
      if (uniqueTokens.length === 0) return;

      let senderName = "New message";
      if (
        typeof messageData.nickname === "string" &&
        messageData.nickname.length > 0
      ) {
        senderName = messageData.nickname;
      }

      let messageText = "You have a new message";
      if (
        typeof messageData.text === "string" &&
        messageData.text.length > 0
      ) {
        messageText = messageData.text.slice(0, 120);
      }

      const response = await admin.messaging().sendEachForMulticast({
        tokens: uniqueTokens,
        notification: {
          title: senderName,
          body: messageText,
        },
        data: {
          type: "chat_message",
          chatId: String(chatId),
          senderId: String(senderId),
        },
        android: {
          priority: "high",
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
            },
          },
        },
      });

      const invalidTokens = [];
      response.responses.forEach((item, index) => {
        if (item.success) return;

        const code = item.error && item.error.code ? item.error.code : "";
        const isTokenError =
        code === "messaging/registration-token-not-registered" ||
        code === "messaging/invalid-registration-token";

        if (isTokenError) {
          invalidTokens.push(uniqueTokens[index]);
        } else {
          logger.error("FCM send error", {code, chatId});
        }
      });

      if (invalidTokens.length === 0) return;

      await Promise.all(
          recipientIds.map((uid) =>
            admin.firestore().collection("users").doc(uid).set(
                {
                  fcmTokens: admin.firestore.FieldValue.arrayRemove(
                      ...invalidTokens,
                  ),
                },
                {merge: true},
            ),
          ),
      );
    },
);
