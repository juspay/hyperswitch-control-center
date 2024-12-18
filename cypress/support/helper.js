module.exports = { generateUniqueEmail };

function generateUniqueEmail() {
  const email = `cypress+${Math.floor(new Date().getTime() / 1000)}@gmail.com`;
  return email;
}
