const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const email = "raufbovikanam@gmail.com";

async function checkAdminClaim() {
  try {
    const user = await admin.auth().getUserByEmail(email);
    console.log("Custom Claims:", user.customClaims);
  } catch (error) {
    console.error("❌ Error:", error);
  }
}

checkAdminClaim();
