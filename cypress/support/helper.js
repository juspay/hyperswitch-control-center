module.exports = { generateUniqueEmail, generateDateTimeString };

function generateUniqueEmail() {
  const email = `cypress+org_admin_${Math.floor(new Date().getTime() / 1000)}@test.com`;
  return email;
}

function generateDateTimeString() {
  const now = new Date();
  return now
    .toISOString()
    .replace(/[-:.T]/g, "")
    .slice(0, 14);
}
