module.exports = { generateUniqueEmail, generateDateTimeString };

function generateUniqueEmail() {
  const email = `cypress+${Math.floor(new Date().getTime() / 1000)}@gmail.com`;
  return email;
}

function generateDateTimeString() {
  const now = new Date();
  return now
    .toISOString()
    .replace(/[-:.T]/g, "")
    .slice(0, 14);
}
