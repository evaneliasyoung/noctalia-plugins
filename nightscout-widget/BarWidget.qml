import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.UI
import qs.Widgets

Item {
  id: root

  property var pluginApi: null

  property ShellScreen screen

  // Widget properties passed from Bar.qml for per-instance settings
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0
  readonly property var pluginSettings: pluginApi?.pluginSettings ?? ({})
  readonly property var main: pluginApi?.mainInstance ?? ({})

  readonly property string screenName: screen ? screen.name : ""
  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
  readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)
  readonly property string displayMode: root.pluginSettings.displayMode ?? "onhover"

  readonly property bool useMMOLL: root.pluginSettings.bgUnit === "mmoll"
  readonly property string insideColor: root.pluginSettings.insideColor ?? Color.resolveColorKey("none")
  readonly property string outsideColor: root.pluginSettings.outsideColor ?? Color.resolveColorKey("tertiary")
  readonly property string urgentColor: root.pluginSettings.urgentColor ?? Color.resolveColorKey("error")
  readonly property bool trendIcon: root.pluginSettings.trendIcon ?? false
  readonly property string icon: root.pluginSettings.icon ?? "droplet"

  readonly property real bg: main?.sgv
  readonly property real trend: main?.trend
  // TODO: Grab from https://$host/api/v1/status.json[thresholds][bgHigh]
  readonly property real bgHigh: 220
  // TODO: Grab from https://$host/api/v1/status.json[thresholds][bgTargetTop]
  readonly property real bgTargetTop: 180
  // TODO: Grab from https://$host/api/v1/status.json[thresholds][bgTargetBottom]
  readonly property real bgTargetBottom: 70
  // TODO: Grab from https://$host/api/v1/status.json[thresholds][bgLow]
  readonly property real bgLow: 55

  implicitWidth: pill.width
  implicitHeight: pill.height

  NPopupContextMenu {
    id: contextMenu

    model: [
      {
        "label": root.pluginApi?.tr("settings.settings-label"),
        "action": "plugin-settings",
        "icon": "settings"
      }
    ]
    onTriggered: action => {
      contextMenu.close();
      PanelService.closeContextMenu(root.screen);

      if (action === "plugin-settings")
        BarService.openPluginSettings(root.screen, root.pluginApi.manifest);
    }
  }

  BarPill {
    id: pill

    screen: root.screen
    oppositeDirection: BarService.getPillDirection(root)
    autoHide: false
    text: Number.isFinite(root.bg) ? (root.useMMOLL ? (root.bg / 18).toFixed(1) : Math.round(root.bg).toString()) : "--"
    icon: root.trendIcon ? (root.trend == 0 ? "arrows-horizontal" : root.trend == 1 ? "arrows-up" : root.trend == 2 ? "arrow-up" : root.trend == 3 ? "arrow-up-right" : root.trend == 4 ? "arrow-right" : root.trend == 5 ? "arrow-down-right" : root.trend == 6 ? "arrow-down" : root.trend == 7 ? "arrows-down" : root.trend == 8 ? "arrows-random" : "arrows-vertical") : root.icon

    // onClicked: {
    //     pluginApi.openPanel(root.screen, root);
    // }
    onRightClicked: {
      if (root.pluginApi)
        root.pluginApi.closePanel(root.screen);
      PanelService.showContextMenu(contextMenu, pill, root.screen);
    }

    customIconColor: root.bg > root.bgHigh || root.bg < root.bgLow ? root.urgentColor : root.bg > root.bgTargetTop || root.bg < root.bgTargetBottom ? root.outsideColor : root.insideColor
    customTextColor: root.bg > root.bgHigh || root.bg < root.bgLow ? root.urgentColor : root.bg > root.bgTargetTop || root.bg < root.bgTargetBottom ? root.outsideColor : root.insideColor
    forceOpen: root.displayMode === "alwaysShow"
    forceClose: root.displayMode === "alwaysHide"
  }
}
