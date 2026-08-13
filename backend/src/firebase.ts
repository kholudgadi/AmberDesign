import { applicationDefault, cert, getApps, initializeApp } from "firebase-admin/app";
import { getMessaging } from "firebase-admin/messaging";
import { getAuth } from "firebase-admin/auth";
import { getStorage } from "firebase-admin/storage";
import { env } from "./config.js";

const credential = env.FIREBASE_SERVICE_ACCOUNT_JSON
  ? cert(JSON.parse(env.FIREBASE_SERVICE_ACCOUNT_JSON))
  : applicationDefault();

export const firebaseApp = getApps()[0] ?? initializeApp({
  credential,
  projectId: env.FIREBASE_PROJECT_ID,
  storageBucket: env.FIREBASE_STORAGE_BUCKET
});

export const messaging = getMessaging(firebaseApp);
export const firebaseAuth = getAuth(firebaseApp);
export const bucket = getStorage(firebaseApp).bucket();
