// Run after npm run re:build: node --test tests/decision-engine-cutover.test.cjs
// Exercise the compiled hook with isolated React effect/Recoil/timer boundaries.
const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const path = require("node:path");
const source = fs
  .readFileSync(
    path.join(__dirname, "../src/screens/Routing/DecisionEngineHooks.res.js"),
    "utf8",
  )
  .replace(/^import \* as (\w+) from .*;$/gm, "const $1 = imports.$1;")
  .replace(/export \{[^}]*\}/, "");
const flush = () => new Promise((resolve) => setImmediate(resolve));
function harness(check) {
  let state,
    cleanup,
    deps,
    calls = 0;
  let session = { merchantId: "m", profileId: "p" };
  const timers = new Map(),
    listeners = new Set();
  let timerId = 0;
  const context = vm.createContext({
    imports: {
      React: {
        useContext: () => ({ getCommonSessionDetails: () => session }),
        useEffect: (effect, next) => {
          if (!deps || next.some((value, i) => value !== deps[i])) {
            cleanup?.();
            deps = next;
            cleanup = effect();
          }
        },
      },
      Recoil: {
        useSetRecoilState: () => (updater) => {
          state = updater(state);
        },
        useRecoilValue: () => state,
      },
      HyperswitchAtom: {},
      UserInfoProvider: {},
      LogicUtils: { isNonEmptyString: (value) => value.length > 0 },
      RoutingUtils: {
        useCheckRoutingEntryCutover: () => () => {
          calls++;
          return check();
        },
      },
      Caml_option: { some: (value) => value },
      Core__Option: {
        isNone: (value) => value === undefined,
        forEach: (value, fn) => {
          if (value !== undefined) fn(value);
        },
      },
    },
    setTimeout: (fn) => {
      timers.set(++timerId, fn);
      return timerId;
    },
    clearTimeout: (id) => timers.delete(id),
    window: {
      addEventListener: (_, fn) => listeners.add(fn),
      removeEventListener: (_, fn) => listeners.delete(fn),
    },
  });
  vm.runInContext(source, context);
  return {
    render: (enabled = true) => context.useSyncDecisionEngineCutover(enabled),
    read: (enabled = true) => context.useDecisionEngineCutover(enabled),
    switchProfile: (profileId) => {
      session = { ...session, profileId };
    },
    unmount: () => {
      cleanup?.();
      cleanup = undefined;
      deps = undefined;
    },
    focus: () => listeners.forEach((fn) => fn()),
    tick: () => {
      const pending = [...timers.values()];
      timers.clear();
      pending.forEach((fn) => fn());
    },
    get calls() {
      return calls;
    },
    get timers() {
      return timers.size;
    },
  };
}
test("flag off then on probes once, regardless of reader count", async () => {
  const h = harness(async () => true);
  h.render(false);
  assert.equal(h.calls, 0);
  assert.equal(h.read(false), false);
  h.render(true);
  await flush();
  for (let i = 0; i < 3; i++) assert.equal(h.read(), true);
  h.render(true);
  h.focus();
  assert.equal(h.calls, 1);
  h.render(false);
  h.render(true);
  await flush();
  assert.equal(h.calls, 2);
});
test("unknown and rejected results retry, and successful false is cached", async () => {
  let attempt = 0;
  const h = harness(async () => {
    if (++attempt === 1) return undefined;
    if (attempt === 2) throw Error("network");
    return false;
  });
  h.render();
  await flush();
  assert.equal(h.read(), undefined);
  h.tick();
  await flush();
  h.tick();
  await flush();
  assert.equal(h.calls, 3);
  assert.equal(h.read(), false);
  h.focus();
  assert.equal(h.calls, 3);
});
test("retries are bounded and focus can recover later", async () => {
  const h = harness(async () => undefined);
  h.render();
  await flush();
  h.tick();
  await flush();
  h.tick();
  await flush();
  assert.equal(h.calls, 3);
  assert.equal(h.timers, 0);
  h.focus();
  await flush();
  assert.equal(h.calls, 4);
  h.unmount();
  assert.equal(h.timers, 0);
  h.focus();
  assert.equal(h.calls, 4);
});
test("profile switches discard stale in-flight responses", async () => {
  const resolves = [];
  const h = harness(() => new Promise((resolve) => resolves.push(resolve)));
  h.render();
  h.switchProfile("p2");
  assert.equal(h.read(), undefined);
  h.render();
  resolves[1](true);
  await flush();
  resolves[0](false);
  await flush();
  assert.equal(h.read(), true);
  assert.equal(h.calls, 2);
});
test("unmount clears cached state and remount with the same profile probes again", async () => {
  const h = harness(async () => true);
  h.render();
  await flush();
  h.unmount();
  assert.equal(h.read(), undefined);
  h.render();
  await flush();
  assert.equal(h.calls, 2);
  assert.equal(h.read(), true);
});
test("independent roots do not share probe state; incomplete sessions do not probe", async () => {
  const a = harness(async () => true),
    b = harness(async () => false);
  a.render();
  b.switchProfile("");
  b.render();
  await flush();
  assert.equal(b.calls, 0);
  b.switchProfile("p");
  b.render();
  await flush();
  assert.equal(a.read(), true);
  assert.equal(b.read(), false);
});

test("focus does not overlap a pending probe and logout ignores its response", async () => {
  let resolve;
  const h = harness(
    () =>
      new Promise((done) => {
        resolve = done;
      }),
  );
  h.render();
  h.focus();
  h.focus();
  assert.equal(h.calls, 1);
  h.unmount();
  resolve(true);
  await flush();
  assert.equal(h.read(), undefined);
  assert.equal(h.timers, 0);
});
