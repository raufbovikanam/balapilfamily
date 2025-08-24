const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: "balapil-family-tree-8da8c"
});

const adminEmail = "raufbovikanam@gmail.com";

async function setAdmin() {
  try {
    const userRecord = await admin.auth().getUserByEmail(adminEmail);
    await admin.auth().setCustomUserClaims(userRecord.uid, { admin: true });
    console.log(`✅ ${adminEmail} is now Super Admin!`);
  } catch (error) {
    console.error("❌ Error:", error);
  }
}

setAdmin();
