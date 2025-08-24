const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: "balapil-family-tree-8da8c"
});

const adminEmail = "raufbovikanam@gmail.com";

async function checkAdminClaim(email) {
  try {
    const user = await admin.auth().getUserByEmail(email);
    console.log(user.customClaims);
  } catch (error) {
    console.error("❌ Error:", error);
  }
}

checkAdminClaim(adminEmail);
