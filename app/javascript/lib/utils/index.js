import { clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs) {
  return twMerge(clsx(inputs));
}

export function displayUrl(url) {
  try {
    const { hostname, pathname } = new URL(url);
    return `${hostname}${pathname}`.replace(/\/$/, "");
  } catch {
    return url;
  }
}
