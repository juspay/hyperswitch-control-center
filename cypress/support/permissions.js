// cypress/permissions.js

// Define roles and permissions for each section
export const rolePermissions = {
  admin: {
    analytics: "write",
  },
  view_only: {
    analytics: "read",
  },
  support: {
    analytics: "read",
  },
};

// Define access levels for each user role
export const accessLevels = ["org", "merchant", "profile"];

// Permissions matrix to check role-access-level combinations
export const permissionsMatrix = {
  org: {
    analytics: ["admin", "view_only", "support"],
    workflow: ["admin", "support"],
    operations: ["admin", "support"],
  },
  merchant: {
    analytics: ["admin"],
    workflow: ["admin", "support"],
    operations: ["admin", "support"],
  },
  profile: {
    analytics: ["view_only", "support"],
    workflow: ["admin", "view_only", "support"],
    operations: ["admin", "view_only", "support"],
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
