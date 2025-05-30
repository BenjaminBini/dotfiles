// skip 1st line
debugger;
lockPref("extensions.install_origins.enabled", false);

try {
  const cmanifest = Services.dirsvc.get("UChrm", Ci.nsIFile);
  debugger;
  cmanifest.append("utils");
  cmanifest.append("chrome.manifest");
  Components.manager
    .QueryInterface(Ci.nsIComponentRegistrar)
    .autoRegister(cmanifest);

  Services.scriptloader.loadSubScript(
    "chrome://userchromejs/content/BootstrapLoader.js"
  );
} catch (ex) {}

try {
  Services.scriptloader.loadSubScript(
    "chrome://userchromejs/content/userChrome.js"
  );
} catch (ex) {}

// signing bypass by Dumby from forum.mozilla-russia.org
try {
  ((jsval) => {
    var dbg,
      gref,
      genv = (func) => {
        var sandbox = new Cu.Sandbox(g, { freshCompartment: true });
        Cc["@mozilla.org/jsdebugger;1"]
          .createInstance(Ci.IJSDebugger)
          .addClass(sandbox);
        (dbg = new sandbox.Debugger()).addDebuggee(g);
        gref = dbg.makeGlobalObjectReference(g);
        return (genv = (func) =>
          func && gref.makeDebuggeeValue(func).environment)(func);
      };
    var g = Cu.getGlobalForObject(jsval),
      o = g.Object,
      { freeze } = o,
      disleg;

    var lexp = () => lockPref("extensions.experiments.enabled", true);
    var MRS = "MOZ_REQUIRE_SIGNING",
      AC = "AppConstants",
      uac = `resource://gre/modules/${AC}.`;

    if (o.isFrozen(o)) {
      // Fx 102.0b7+
      lexp();
      disleg = true;
      genv();

      dbg.onEnterFrame = (frame) => {
        var { script } = frame;
        try {
          if (!script.url.startsWith(uac)) return;
        } catch {
          return;
        }
        dbg.onEnterFrame = undefined;

        if (script.isModule) {
          // ESM, Fx 108+
          var env = frame.environment;
          frame.onPop = () =>
            env.setVariable(
              AC,
              gref.makeDebuggeeValue(
                freeze(
                  o.assign(new o(), env.getVariable(AC).unsafeDereference(), {
                    [MRS]: false,
                  })
                )
              )
            );
        } else {
          // JSM
          var nsvo = frame.this.unsafeDereference();
          nsvo.Object = {
            freeze(ac) {
              ac[MRS] = false;
              delete nsvo.Object;
              return freeze(ac);
            },
          };
        }
      };
    } else
      o.freeze = (obj) => {
        if (!Components.stack.caller.filename.startsWith(uac))
          return freeze(obj);
        obj[MRS] = false;

        if ((disleg = "MOZ_ALLOW_ADDON_SIDELOAD" in obj)) lexp();
        else
          (obj.MOZ_ALLOW_LEGACY_EXTENSIONS = true),
            lockPref("extensions.legacy.enabled", true);

        return (o.freeze = freeze)(obj);
      };
    lockPref("xpinstall.signatures.required", false);
    lockPref("extensions.langpacks.signatures.required", false);

    var useDbg = true,
      xpii = "resource://gre/modules/addons/XPIInstall.";
    if (Ci.nsINativeFileWatcherService) {
      // Fx < 100
      jsval = Cu.import(xpii + "jsm", {});
      var shouldVerify = jsval.shouldVerifySignedState;
      if (shouldVerify.length == 1)
        (useDbg = false),
          (jsval.shouldVerifySignedState = (addon) =>
            !addon.id && shouldVerify(addon));
    }
    if (useDbg) {
      // Fx 99+
      try {
        var exp = ChromeUtils.importESModule(xpii + "sys.mjs");
      } catch {
        exp = g.ChromeUtils.import(xpii + "jsm");
      }
      jsval = o.assign({}, exp);

      var env = genv(jsval.XPIInstall.installTemporaryAddon);
      var ref = (name) => {
        try {
          return env.find(name).getVariable(name).unsafeDereference();
        } catch {}
      };
      jsval.XPIDatabase =
        (ref("XPIExports") || ref("lazy") || {}).XPIDatabase ||
        ref("XPIDatabase");

      var proto = ref("Package").prototype;
      var verify = proto.verifySignedState;
      proto.verifySignedState = function (id) {
        return id
          ? { cert: null, signedState: undefined }
          : verify.apply(this, arguments);
      };
      dbg.removeAllDebuggees();
    }
    if (disleg) jsval.XPIDatabase.isDisabledLegacy = () => false;
  })(
    "permitCPOWsInScope" in Cu
      ? Cu.import("resource://gre/modules/WebRequestCommon.jsm", {})
      : Cu
  );
} catch (ex) {
  Cu.reportError(ex);
}

try {
  // Sandbox needs to be disabled in release and Beta versions
  lockPref("general.config.sandbox_enabled", false);

  // Allow userChrome.css to be loaded
  lockPref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

  // Rounded content next to sidebar
  lockPref("sidebar.revamp.round-content-area", true);

  // No tools in the sidebar

  // Disable warning when opening browser toolblox
  lockPref("devtools.debugger.prompt-connection", false);

  // Setting default language to English
  lockPref("intl.locale.requested", "en-GB, fr-FR");
  lockPref("pluralRule", 1);

  // Allow browser transparency
  lockPref("browser.tabs.allow_transparent_browser", true);
  lockPref("widget.macos.titlebar-blend-mode.behind-window", true);
  lockPref("browser.theme.native-theme", true);

  lockPref("browser.newtabpage.activity-stream.showSponsored", false);
  lockPref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
  lockPref(
    "bservices.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsored",
    false
  );
  lockPref(
    "bservices.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsoredTopSite",
    false
  );
  lockPref("layout.css.backdrop-filter.force-enabled", true);

  // No auto update
  lockPref("app.update.auto", false);

  // Show image infos
  lockPref("browser.menu.showViewImageInfo", true);

  lockPref("userChromeJS.persistent_domcontent_callback", true);

  lockPref("security.browser_xhtml_csp.enabled", false);

  //Test
  lockPref("toto", "tata");
} catch (ex) {
  console.error("Error loading config.js:", ex);
}
