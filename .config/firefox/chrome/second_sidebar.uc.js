// ==UserScript==
// @name            Second Sidebar for Firefox
// @description     A Firefox userChrome.js script for adding a second sidebar with web panels like in Vivaldi/Floorp/Zen.
// @author          aminought
// @include         main
// @homepageURL     https://github.com/aminought/firefox-second-sidebar
// ==/UserScript==

if (location.href.startsWith("chrome://browser/content/browser.x")) {
  (async (url) => {
    (
      await ChromeUtils.compileScript(
        `data:,"use strict";import("${url}").catch(console.error)`,
      )
    ).executeInGlobal(window);
  })(
    Services.io
      .newURI(Components.stack.filename)
      .resolve("second_sidebar.uc.mjs"),
  );
}
