import { atom as recoilAtom } from "recoil";

export function atom(key, defaultVal) {
  return recoilAtom({ key, default: defaultVal });
}
