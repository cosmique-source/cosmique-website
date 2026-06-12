/* Cosmique theme toggle — shared across all pages.
   - Applies the saved theme immediately (no flash) when loaded in <head>.
   - Wires every .theme-toggle button to flip + persist light/dark.
   Usage: <script src="…/design-system/js/theme.js"></script> in <head>. */
(function () {
  var KEY = "cosmique-theme";
  var root = document.documentElement;

  // Apply saved choice as early as possible.
  try { if (localStorage.getItem(KEY) === "dark") root.setAttribute("data-theme", "dark"); } catch (e) {}

  function setTheme(dark) {
    if (dark) root.setAttribute("data-theme", "dark");
    else root.removeAttribute("data-theme");
    try { localStorage.setItem(KEY, dark ? "dark" : "light"); } catch (e) {}
  }

  function wire() {
    var buttons = document.querySelectorAll(".theme-toggle");
    for (var i = 0; i < buttons.length; i++) {
      buttons[i].addEventListener("click", function () {
        setTheme(root.getAttribute("data-theme") !== "dark");
      });
    }
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", wire);
  else wire();
})();
