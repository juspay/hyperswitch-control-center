// Define roles and permissions for each section
export const rolePermissions = {
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
export const permissionsMatrix = {
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
export const hasPermission = (role, section, permission) => {
  return rolePermissions[role] && rolePermissions[role][section] === permission;
};

// Function to check if role has access to the section at a certain access level
export const hasAccessLevelPermission = (accessLevel, role, section) => {
  return (
    permissionsMatrix[accessLevel] &&
    permissionsMatrix[accessLevel][section]?.includes(role)
  );
};
