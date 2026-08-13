import { prisma } from "../database.js";
import { messaging } from "../firebase.js";

type PushNotification = {
  titleAr: string;
  titleEn: string;
  bodyAr: string;
  bodyEn: string;
  data?: Record<string, unknown>;
};

export async function sendPushToUser(userId: string, notification: PushNotification) {
  const user = await prisma.user.findUnique({ where: { id: userId }, select: { language: true, fcmTokens: true } });
  if (!user?.fcmTokens.length) return;
  const arabic = user.language !== "en";
  const response = await messaging.sendEachForMulticast({
    tokens: user.fcmTokens,
    notification: {
      title: arabic ? notification.titleAr : notification.titleEn,
      body: arabic ? notification.bodyAr : notification.bodyEn
    },
    data: Object.fromEntries(Object.entries(notification.data ?? {}).map(([key, value]) => [key, String(value)]))
  });
  const invalid = response.responses
    .map((result, index) => result.success ? null : user.fcmTokens[index])
    .filter((token): token is string => Boolean(token));
  if (invalid.length) {
    await prisma.user.update({ where: { id: userId }, data: { fcmTokens: user.fcmTokens.filter(token => !invalid.includes(token)) } });
  }
}

export function sendPushSafely(userId: string, notification: PushNotification) {
  void sendPushToUser(userId, notification).catch(error => console.error("Unable to send Firebase notification", error));
}
