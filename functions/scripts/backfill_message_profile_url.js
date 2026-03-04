"use strict";

const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const DOCUMENT_ID = admin.firestore.FieldPath.documentId();
const BATCH_SIZE = 400;
const READ_PAGE_SIZE = 500;

function parseArgs(argv) {
  return {
    dryRun: argv.includes("--dry-run"),
    limit: parsePositiveInt(argv, "--limit"),
  };
}

function parsePositiveInt(argv, key) {
  const idx = argv.indexOf(key);
  if (idx === -1) return null;

  const raw = argv[idx + 1];
  if (!raw) return null;

  const value = Number.parseInt(raw, 10);
  if (Number.isNaN(value) || value <= 0) return null;
  return value;
}

function hasProfileUrl(data) {
  return typeof data.profileUrl === "string" && data.profileUrl.length > 0;
}

async function loadUserProfileUrl(userId, cache) {
  if (!userId || typeof userId !== "string") return null;
  if (cache.has(userId)) return cache.get(userId);

  const userSnap = await db.collection("users").doc(userId).get();
  const profileUrl = userSnap.exists ? userSnap.get("profileUrl") : null;
  const normalized = typeof profileUrl === "string" && profileUrl.length > 0 ?
    profileUrl :
    null;

  cache.set(userId, normalized);
  return normalized;
}

async function run() {
  const {dryRun, limit} = parseArgs(process.argv.slice(2));
  const userProfileCache = new Map();

  let scanned = 0;
  let updated = 0;
  let skippedMissingUserId = 0;
  let skippedNoUserProfile = 0;
  let lastDoc = null;

  console.log(
      `Backfill started. dryRun=${dryRun} limit=${limit ?? "none"}`,
  );

  while (true) {
    let query = db
        .collectionGroup("messages")
        .orderBy(DOCUMENT_ID)
        .limit(READ_PAGE_SIZE);

    if (lastDoc) {
      query = query.startAfter(lastDoc);
    }

    const page = await query.get();
    if (page.empty) break;

    let batch = db.batch();
    let batchOps = 0;

    for (const doc of page.docs) {
      scanned += 1;

      const data = doc.data() || {};
      if (hasProfileUrl(data)) continue;

      const userId = data.userId;
      if (typeof userId !== "string" || userId.length === 0) {
        skippedMissingUserId += 1;
        continue;
      }

      const profileUrl = await loadUserProfileUrl(userId, userProfileCache);
      if (!profileUrl) {
        skippedNoUserProfile += 1;
        continue;
      }

      updated += 1;

      if (!dryRun) {
        batch.update(doc.ref, {profileUrl: profileUrl});
        batchOps += 1;

        if (batchOps >= BATCH_SIZE) {
          await batch.commit();
          batch = db.batch();
          batchOps = 0;
        }
      }

      if (limit && updated >= limit) break;
    }

    if (!dryRun && batchOps > 0) {
      await batch.commit();
    }

    lastDoc = page.docs[page.docs.length - 1];

    console.log(
        `Progress: scanned=${scanned}, updated=${updated}, ` +
        `missingUserId=${skippedMissingUserId}, noUserProfile=${skippedNoUserProfile}`,
    );

    if (limit && updated >= limit) break;
  }

  console.log("Backfill completed.");
  console.log(
      `Final: scanned=${scanned}, updated=${updated}, ` +
      `missingUserId=${skippedMissingUserId}, noUserProfile=${skippedNoUserProfile}`,
  );
}

run()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error("Backfill failed:", error);
      process.exit(1);
    });
