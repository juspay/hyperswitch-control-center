module.exports = {
  generateUniqueEmail,
  generateDateTimeString,
  getInvalidEmails,
};

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

function getInvalidEmails() {
  return [
    "username", // Missing @ and domain
    "@test.com", // Missing username part
    "missing@test", // Incomplete domain
    "multiple@domains@test.com", // Multiple @ symbols
    "spaces in@test.com", // Contains spaces
    "dots..in@test.com", // Consecutive dots
    ".starts.with.dot@test.com", // Starts with dot
    "ends.with.dot.@test.com", // Ends with dot
    "special#chars@test.com", // Invalid special characters
    "!username@test.com", // Invalid special characters
    "", // Empty string
    " ", // Only whitespace
    " @test.com", // Only whitespace in username
    "username@.com", // Missing domain part
    "username@test..com", // Consecutive dots in domain
    "username@-test.com", // Domain starts with hyphen
    "username@test-.com", // Domain ends with hyphen
  ];
}
