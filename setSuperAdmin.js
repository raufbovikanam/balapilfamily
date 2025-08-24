const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: "balapil-family-tree-8da8c"
});

const superAdminEmail = "raufbovikanam@gmail.com";

async function setSuperAdmin() {
  try {
    const userRecord = await admin.auth().getUserByEmail(superAdminEmail);
    await admin.auth().setCustomUserClaims(userRecord.uid, { superAdmin: true });
    console.log(`${superAdminEmail} is now Super Admin!`);
  } catch (error) {
    console.error("Error:", error);
  }
}

setSuperAdmin();
