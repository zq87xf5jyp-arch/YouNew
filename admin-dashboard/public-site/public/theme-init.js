(function () {
  var key = "younew.theme.v1";
  var stored;
  try {
    stored = window.localStorage.getItem(key);
  } catch (_) {
    stored = null;
  }
  var theme = stored === "light" || stored === "dark"
    ? stored
    : window.matchMedia("(prefers-color-scheme: light)").matches
      ? "light"
      : "dark";
  document.documentElement.dataset.theme = theme;
  document.documentElement.style.colorScheme = theme;
}());
