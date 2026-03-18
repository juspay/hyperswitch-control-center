import { atom as jotaiAtom } from "jotai";

export function atom(key, defaultVal) {
  const a = jotaiAtom(defaultVal);
  a.debugLabel = key;
  return a;
}
