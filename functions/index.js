const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
const crypto = require("crypto");

admin.initializeApp();
setGlobalOptions({ maxInstances: 10 });

const db = admin.firestore();

const OTP_LENGTH = 6;
const OTP_TTL_MINUTES = 10;
const MAX_ATTEMPTS = 5;
const RESEND_COOLDOWN_SECONDS = 60;

function generateOtp() {
  return crypto.randomInt(0, 1_000_000).toString().padStart(OTP_LENGTH, "0");
}

function hashOtp(otp, salt) {
  return crypto.createHash("sha256").update(`${salt}:${otp}`).digest("hex");
}

// Requests a one-time password be emailed to the given address, via the
// Firestore "mail" collection consumed by the Firebase "Trigger Email"
// extension. Always resolves successfully regardless of whether the account
// exists, so the response can't be used to enumerate registered emails.
exports.requestPasswordResetOtp = onCall(async (request) => {
  const email = (request.data && request.data.email || "").trim().toLowerCase();
  if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new HttpsError("invalid-argument", "A valid email is required.");
  }

  let userRecord;
  try {
    userRecord = await admin.auth().getUserByEmail(email);
  } catch (err) {
    if (err.code === "auth/user-not-found") {
      return { success: true };
    }
    throw new HttpsError("internal", "Could not process request.");
  }

  const docRef = db.collection("passwordResetOtps").doc(email);
  const existing = await docRef.get();
  const now = admin.firestore.Timestamp.now();

  if (existing.exists) {
    const createdAtSeconds = existing.data().createdAt
      ? existing.data().createdAt.seconds
      : 0;
    if (now.seconds - createdAtSeconds < RESEND_COOLDOWN_SECONDS) {
      throw new HttpsError(
        "resource-exhausted",
        "Please wait before requesting another code."
      );
    }
  }

  const otp = generateOtp();
  const salt = crypto.randomBytes(16).toString("hex");
  const otpHash = hashOtp(otp, salt);
  const expiresAt = admin.firestore.Timestamp.fromMillis(
    now.toMillis() + OTP_TTL_MINUTES * 60 * 1000
  );

  await docRef.set({
    uid: userRecord.uid,
    otpHash,
    salt,
    expiresAt,
    attempts: 0,
    createdAt: now,
  });

  await db.collection("mail").add({
    to: email,
    message: {
      subject: "Your AflAlert password reset code",
      text:
        `Your AflAlert password reset code is ${otp}. It expires in ` +
        `${OTP_TTL_MINUTES} minutes. If you didn't request this, you can ` +
        "ignore this email.",
      html:
        "<p>Your AflAlert password reset code is:</p>" +
        `<p style="font-size:28px;font-weight:bold;letter-spacing:4px;">${otp}</p>` +
        `<p>It expires in ${OTP_TTL_MINUTES} minutes. If you didn't request ` +
        "this, you can ignore this email.</p>",
    },
  });

  return { success: true };
});

// Verifies the OTP for the given email and, if valid, sets the account's new
// password directly via the Admin SDK (bypassing Firebase Auth's own email
// link flow, since we're issuing our own code instead).
exports.verifyPasswordResetOtp = onCall(async (request) => {
  const data = request.data || {};
  const email = (data.email || "").trim().toLowerCase();
  const otp = (data.otp || "").trim();
  const newPassword = data.newPassword || "";

  if (!email || !otp) {
    throw new HttpsError("invalid-argument", "Email and code are required.");
  }
  if (newPassword.length < 6) {
    throw new HttpsError(
      "invalid-argument",
      "Password must be at least 6 characters."
    );
  }

  const docRef = db.collection("passwordResetOtps").doc(email);
  const snap = await docRef.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "No pending code for this email.");
  }

  const otpRecord = snap.data();
  const now = admin.firestore.Timestamp.now();

  if (now.toMillis() > otpRecord.expiresAt.toMillis()) {
    await docRef.delete();
    throw new HttpsError("deadline-exceeded", "This code has expired.");
  }

  if (otpRecord.attempts >= MAX_ATTEMPTS) {
    await docRef.delete();
    throw new HttpsError(
      "resource-exhausted",
      "Too many incorrect attempts. Please request a new code."
    );
  }

  const candidateHash = hashOtp(otp, otpRecord.salt);
  if (candidateHash !== otpRecord.otpHash) {
    await docRef.update({ attempts: admin.firestore.FieldValue.increment(1) });
    throw new HttpsError("invalid-argument", "Incorrect code.");
  }

  await admin.auth().updateUser(otpRecord.uid, { password: newPassword });
  await docRef.delete();

  return { success: true };
});
