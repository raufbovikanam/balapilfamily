const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json"); // നിങ്ങളുടെ service account path

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const email = "raufbovikanam@gmail.com"; // Check ചെയ്യാൻ ആഗ്രഹിക്കുന്ന user email

async function checkSuperAdminClaim() {
  try {
    const user = await admin.auth().getUserByEmail(email);
    console.log("Custom Claims:", user.customClaims);
  } catch (error) {
    console.error("❌ Error:", error);
  }
}

checkSuperAdminClaim();
