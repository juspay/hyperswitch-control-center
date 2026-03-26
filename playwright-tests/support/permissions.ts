export const rolePermissions: Record<string, Record<string, string>> = {
  admin: {
    operations: "write",
    connectors: "write",
    analytics: "read",
    workflows: "write",
    reconOps: "write",
    reconReports: "write",
    users: "write",
    account: "write",
  },
  customer_support: {
    operations: "read",
    connectors: "read",
    analytics: "read",
    reconOps: "read",
    reconReports: "read",
    users: "read",
    account: "read",
  },
  developer: {
    operations: "read",
    connectors: "read",
    analytics: "read",
    reconOps: "read",
    reconReports: "read",
    users: "read",
    account: "write",
  },
  iam_admin: {
    operations: "read",
    connectors: "read",
    analytics: "read",
    users: "write",
    account: "read",
  },
  operator: {
    operations: "write",
    connectors: "read",
    analytics: "read",
    workflows: "read",
    reconOps: "write",
    reconReports: "read",
    users: "read",
    account: "read",
  },
  view_only: {
    operations: "read",
    connectors: "read",
    analytics: "read",
    workflows: "read",
    reconOps: "read",
    reconReports: "read",
    users: "read",
    account: "read",
  },
};

// Define access levels for each user role
export const accessLevels = ["org", "merchant", "profile"];

// Permissions matrix to check role-access-level combinations
export const permissionsMatrix: Record<string, Record<string, string[]>> = {
  org: {
    operations: ["admin"],
    connectors: ["admin"],
    analytics: ["admin"],
    workflows: ["admin"],
    reconOps: ["admin"],
    reconReports: ["admin"],
    users: ["admin"],
    account: ["admin"],
  },
  merchant: {
    operations: [
      "admin",
      "customer_support",
      "developer",
      "iam_admin",
      "operator",
      "view_only",
    ],
    connectors: [
      "admin",
      "customer_support",
      "developer",
      "iam_admin",
      "operator",
      "view_only",
    ],
    analytics: [
      "admin",
      "customer_support",
      "developer",
      "iam_admin",
      "operator",
      "view_only",
    ],
    workflows: ["admin", "operator", "view_only"],
    reconOps: [
      "admin",
      "customer_support",
      "developer",
      "operator",
      "view_only",
    ],
    reconReports: [
      "admin",
      "customer_support",
      "developer",
      "operator",
      "view_only",
    ],
    users: [
      "admin",
      "customer_support",
      "developer",
      "iam_admin",
      "operator",
      "view_only",
    ],
    account: [
      "admin",
      "customer_support",
      "developer",
      "iam_admin",
      "operator",
      "view_only",
    ],
  },
  profile: {
    operations: [
      "admin",
      "customer_support",
      "developer",
      "iam_admin",
      "operator",
      "view_only",
    ],
    connectors: [
      "admin",
      "customer_support",
      "developer",
      "iam_admin",
      "operator",
      "view_only",
    ],
    analytics: [
      "admin",
      "customer_support",
      "developer",
      "iam_admin",
      "operator",
      "view_only",
    ],
    workflows: ["admin", "operator", "view_only"],
    users: [
      "admin",
      "customer_support",
      "developer",
      "iam_admin",
      "operator",
      "view_only",
    ],
    account: [
      "admin",
      "customer_support",
      "developer",
      "iam_admin",
      "operator",
      "view_only",
    ],
  },
};

// Function to check if a role has permission to access a section
export const hasPermission = (
  role: string,
  section: string,
  permission: string,
): boolean => {
  return rolePermissions[role] && rolePermissions[role][section] === permission;
};

// Function to check if role has access to the section at a certain access level
export const hasAccessLevelPermission = (
  accessLevel: string,
  role: string,
  section: string,
): boolean => {
  return (
    permissionsMatrix[accessLevel] &&
    permissionsMatrix[accessLevel][section]?.includes(role)
  );
};

// Check permissions from test name and return whether test should be skipped
export const checkPermissionsFromTestName = (testName: string): boolean => {
  const rbac = process.env.RBAC?.split(",") || ["", ""];
  const userAccessLevel = rbac[0] || "org"; // "Access Level"
  const userRole = rbac[1] || "admin"; // "Role"

  // Extract tags from the test name using a regex
  const regex = /@([a-zA-Z0-9_-]+)/g;
  const tags = [...testName.matchAll(regex)].map((match) => match[1]);

  // Parse the tags from test case name and get "section" and "accessLevel"
  const sectionTag = tags.find((tag) =>
    [
      "operations",
      "connectors",
      "analytics",
      "workflows",
      "reconOps",
      "reconReports",
      "users",
      "account",
    ].includes(tag),
  );
  const accessLevelTag = tags.find((tag) =>
    ["org", "merchant", "profile"].includes(tag),
  );
  const permissionTag =
    rolePermissions[userRole] && rolePermissions[userRole][sectionTag || ""];

  // Default values if no tags are found in the name
  const requiredSection = sectionTag || "users"; // Default to 'users'
  const requiredAccessLevel = accessLevelTag || "org"; // Default to 'org'
  const requiredPermission = permissionTag || "write"; // Default to 'write'

  // Check access level and run the test based on the user's access level
  if (userAccessLevel === "profile") {
    // If the user is at 'profile' access level, run tests with the 'profile' tag only
    if (!tags.includes("profile")) {
      console.log(
        `Test skipped: User access level is 'profile' and this test is not tagged with 'profile'`,
      );
      return true; // Skip the test
    }
  } else if (userAccessLevel === "merchant") {
    // If the user is at 'merchant' access level, run tests with 'merchant' or 'profile' tag
    if (!tags.includes("merchant") && !tags.includes("profile")) {
      console.log(
        `Test skipped: User access level is 'merchant' and this test is not tagged with 'merchant' or 'profile'`,
      );
      return true; // Skip the test
    }
  } else if (userAccessLevel === "org") {
    // If the user is at 'org' access level, run tests with 'org', 'merchant', or 'profile' tag
    if (
      !tags.includes("org") &&
      !tags.includes("merchant") &&
      !tags.includes("profile")
    ) {
      console.log(
        `Test skipped: User access level is 'org' and this test is not tagged with 'org', 'merchant', or 'profile'`,
      );
      return true; // Skip the test
    }
  }

  // Validate if user has access level permission to the section
  const canAccess = hasAccessLevelPermission(
    userAccessLevel,
    userRole,
    requiredSection,
  );
  if (!canAccess) {
    console.log(
      `Test skipped: Insufficient access level for "${requiredSection}" section`,
    );
    return true; // Skip the test
  }

  // Validate if user has the correct permission (read/write)
  const hasCorrectPermission = hasPermission(
    userRole,
    requiredSection,
    requiredPermission,
  );
  if (!hasCorrectPermission) {
    console.log(
      `Test skipped: Insufficient permissions (${requiredPermission}) for "${requiredSection}" section`,
    );
    return true; // Skip the test
  }

  return false; // Don't skip the test
};
