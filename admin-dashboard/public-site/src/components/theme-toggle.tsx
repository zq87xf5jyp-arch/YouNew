"use client";

import { Moon, Sun } from "lucide-react";
import { useEffect, useState } from "react";

const STORAGE_KEY = "younew.theme.v1";

type Theme = "light" | "dark";

function currentTheme(): Theme {
  return document.documentElement.dataset.theme === "light" ? "light" : "dark";
}

function applyTheme(theme: Theme) {
  const root = document.documentElement;
  root.dataset.theme = theme;
  root.style.colorScheme = theme;
  document.querySelector<HTMLMetaElement>('meta[name="theme-color"]')?.setAttribute(
    "content",
    theme === "dark" ? "#050c1b" : "#eef3f8"
  );
}

export function ThemeToggle({ locale = "en" }: { locale?: "en" | "nl" }) {
  const [theme, setTheme] = useState<Theme | null>(null);

  useEffect(() => {
    setTheme(currentTheme());
  }, []);

  function toggleTheme() {
    const nextTheme: Theme = currentTheme() === "dark" ? "light" : "dark";
    applyTheme(nextTheme);
    window.localStorage.setItem(STORAGE_KEY, nextTheme);
    setTheme(nextTheme);
  }

  const nextTheme = theme === "light" ? "dark" : "light";
  const nextThemeLabel = nextTheme === "dark" ? "donkere" : "lichte";
  const label = locale === "nl"
    ? theme ? `Schakel naar ${nextThemeLabel} modus` : "Kleurthema wijzigen"
    : theme ? `Switch to ${nextTheme} mode` : "Change color theme";
  const localizedAria = locale === "nl" ? { "aria-label": label } : {};

  return (
    <button
      className="theme-toggle"
      type="button"
      aria-label={theme ? `Switch to ${nextTheme} mode` : "Change color theme"}
      {...localizedAria}
      aria-pressed={theme === "light"}
      title={label}
      onClick={toggleTheme}
    >
      <Sun className="theme-toggle-sun" aria-hidden />
      <Moon className="theme-toggle-moon" aria-hidden />
      <span className="visually-hidden">{locale === "nl" ? "Kleurthema" : theme ? `${theme} mode active` : "Color theme"}</span>
    </button>
  );
}
