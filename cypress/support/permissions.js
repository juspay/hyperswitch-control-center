const rolePermissions = {
  admin: {
    users: "write",
    //   analytics: 'write',
    //   workflow: 'write',
    //   operations: 'write',
  },
  view_only: {
    users: "read",
    //   analytics: 'read',
    //   workflow: 'read',
    //   operations: 'read',
  },
  support: {
    users: "write",
    //   analytics: 'read',
    //   workflow: 'read',
    //   operations: 'write',
  },
};

const accessLevels = ["org", "merchant", "profile"];

export { rolePermissions, accessLevels };
