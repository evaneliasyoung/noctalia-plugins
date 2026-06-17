import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Services.UI

QtObject {
  id: root

  property var pluginApi: null
  readonly property var pluginSettings: pluginApi?.pluginSettings ?? ({})

  readonly property string server: root.pluginSettings.server ?? ""
  readonly property string apiURL: {
    if (!root.server)
      return "";

    const trimmed = root.server.trim();
    if (!trimmed)
      return "";

    const withScheme = trimmed.indexOf("://") === -1 ? `https://${trimmed}` : trimmed;
    const withoutTrailingPath = withScheme.replace(/\/+$/, "");
    return `${withoutTrailingPath}/api/v1`;
  }

  property real sgv: NaN
  property real trend: 0
  property var latestEntry: null
  property string lastError: ""

  property var _pollTimer: Timer {
    interval: 60000
    running: false
    repeat: true
    onTriggered: root.refresh()
  }

  property var _entriesProc: Process {
    property string apiURL: ""

    command: ["curl", "-sS", "-g", `${apiURL}/entries.json?count=1`]
    running: false

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const parsed = JSON.parse(text);
          if (!Array.isArray(parsed) || parsed.length === 0) {
            root.lastError = "Nightscout returned no entries.";
            Logger.w("NightscoutWidget", root.lastError);
            return;
          }

          const entry = parsed[0];
          root.sgv = Number(entry.sgv);
          root.trend = entry.trend;
          root.latestEntry = entry;
          root.lastError = "";
        } catch (error) {
          root.lastError = `Failed to parse Nightscout JSON: ${error}`;
          Logger.w("NightscoutWidget", root.lastError);
        }
      }
    }

    stderr: StdioCollector {
      onStreamFinished: {
        const message = text.trim();
        if (!message)
          return;

        root.lastError = message;
        Logger.w("NightscoutWidget", `curl stderr: ${message}`);
      }
    }

    onExited: (exitCode, exitStatus) => {
      if (exitCode !== 0)
        Logger.w("NightscoutWidget", `Fetch exited with code ${exitCode} and status ${exitStatus}`);
    }
  }

  function refresh() {
    if (!root.apiURL) {
      root.lastError = "Set the Nightscout server in plugin settings.";
      root._pollTimer.running = false;
      return;
    } else {
      root._pollTimer.running = true;
    }

    if (root._entriesProc.running)
      return;

    root._entriesProc.apiURL = root.apiURL;
    root._entriesProc.running = true;
  }

  function onLoad() {
    Logger.i("NightScoutWidget", "Started");
    root.refresh();
  }

  Component.onCompleted: root.onLoad()
  onApiURLChanged: root.refresh()
}
