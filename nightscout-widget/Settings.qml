import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  property var pluginApi: null
  readonly property var pluginSettings: pluginApi?.pluginSettings ?? pluginApi?.manifest?.metadata?.defaultSettings ?? ({})
  readonly property var main: pluginApi?.mainInstance ?? null

  // Defaults
  readonly property string insideColorDefault: Color.resolveColorKey("none")
  readonly property string outsideColorDefault: Color.resolveColorKey("tertiary")
  readonly property string urgentColorDefault: Color.resolveColorKey("error")
  readonly property string iconDefault: "droplet"
  readonly property string serverDefault: ""

  // Local state
  property string displayModeBuffer: root.pluginSettings.displayMode ?? "onhover"
  property string bgUnitBuffer: root.pluginSettings.bgUnit ?? "mgdl"
  property string insideColorBuffer: root.pluginSettings.insideColor ?? root.insideColorDefault
  property string outsideColorBuffer: root.pluginSettings.outsideColor ?? root.outsideColorDefault
  property string urgentColorBuffer: root.pluginSettings.urgentColor ?? root.urgentColorDefault
  property string iconBuffer: root.pluginSettings.icon ?? root.iconDefault
  property string serverBuffer: root.pluginSettings.server ?? root.serverDefault

  readonly property var displayModeModel: [
    {
      "key": "onhover",
      "name": I18n.tr("display-modes.on-hover")
    },
    {
      "key": "alwaysShow",
      "name": I18n.tr("display-modes.always-show")
    },
    {
      "key": "alwaysHide",
      "name": I18n.tr("display-modes.always-hide")
    }
  ]
  readonly property var bgUnitModel: [
    {
      "key": "mgdl",
      "name": "mg/dL"
    },
    {
      "key": "mmoll",
      "name": "mmol/L"
    }
  ]

  function saveSettings() {
    pluginApi.pluginSettings.displayMode = root.displayModeBuffer;
    pluginApi.pluginSettings.bgUnit = root.bgUnitBuffer;
    pluginApi.pluginSettings.insideColor = root.insideColorBuffer;
    pluginApi.pluginSettings.outsideColor = root.outsideColorBuffer;
    pluginApi.pluginSettings.urgentColor = root.urgentColorBuffer;
    pluginApi.pluginSettings.icon = root.iconBuffer;
    pluginApi.pluginSettings.server = root.serverBuffer;
    pluginApi.saveSettings();

    Logger.i("NightscoutWidget", "Settings saved successfully");
  }

  NComboBox {
    label: I18n.tr("common.display-mode")
    description: pluginApi?.tr("settings.display-mode-description")
    minimumWidth: 200
    model: root.displayModeModel
    currentKey: root.displayModeBuffer
    onSelected: key => {
      root.displayModeBuffer = key;
    }
  }

  NComboBox {
    label: pluginApi?.tr("settings.blood-glucose-unit-label")
    description: pluginApi?.tr("settings.blood-glucose-unit-description")
    minimumWidth: 200
    model: root.bgUnitModel
    currentKey: root.bgUnitBuffer
    onSelected: key => {
      root.bgUnitBuffer = key;
    }
  }

  ColorPickerRowItem {
    label: pluginApi?.tr("settings.in-range-color-label")
    description: pluginApi?.tr("settings.in-range-color-description")
    defaultValue: root.insideColorDefault
    currentValue: root.insideColorBuffer

    onSelected: value => {
      root.insideColorBuffer = value;
    }
  }

  ColorPickerRowItem {
    label: pluginApi?.tr("settings.out-of-range-color-label")
    description: pluginApi?.tr("settings.out-of-range-color-description")
    defaultValue: root.outsideColorDefault
    currentValue: root.outsideColorBuffer

    onSelected: value => {
      root.outsideColorBuffer = value;
    }
  }

  ColorPickerRowItem {
    label: pluginApi?.tr("settings.urgent-color-label")
    description: pluginApi?.tr("settings.urgent-color-description")
    defaultValue: root.urgentColorDefault
    currentValue: root.urgentColorBuffer

    onSelected: value => {
      root.urgentColorBuffer = value;
    }
  }

  RowLayout {
    spacing: Style.marginM

    NLabel {
      label: I18n.tr("common.icon")
      description: pluginApi?.tr("settings.icon-description")
      showIndicator: (root.iconDefault !== undefined) && (root.iconBuffer !== root.iconDefault)
      indicatorTooltip: {
        I18n.tr("panels.indicator.default-value", {
          "value": root.iconDefault === "" ? "(empty)" : String(root.iconDefault)
        });
      }
    }

    NIcon {
      Layout.alignment: Qt.AlignVCenter
      icon: root.iconBuffer
      pointSize: Style.fontSizeXXL * 1.5
    }

    NButton {
      text: pluginApi?.tr("actions.browse-library")
      onClicked: iconPicker.open()
    }
  }

  NIconPicker {
    id: iconPicker
    initialIcon: root.iconBuffer
    onIconSelected: iconName => {
      root.iconBuffer = iconName;
    }
  }

  NTextInput {
    label: pluginApi?.tr("settings.host-label")
    description: pluginApi?.tr("settings.host-description")
    placeholderText: pluginApi?.tr("settings.host-placeholder")
    text: root.serverBuffer
    onTextChanged: {
      root.serverBuffer = text;
    }
    defaultValue: root.serverDefault
  }
}
