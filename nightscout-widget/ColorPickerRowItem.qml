import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

RowLayout {
  id: root

  property string label: ""
  property string description: ""
  property string defaultValue: ""
  property string currentValue: ""

  readonly property bool isValueChanged: (defaultValue !== undefined) && (currentValue !== defaultValue)
  readonly property string indicatorTooltip: {
    I18n.tr("panels.indicator.default-value", {
      "value": defaultValue === "" ? "(empty)" : String(defaultValue)
    });
  }

  signal selected(string value)

  NLabel {
    label: root.label
    description: root.description
    showIndicator: root.isValueChanged
    indicatorTooltip: root.indicatorTooltip
  }

  NColorPicker {
    selectedColor: root.currentValue

    onColorSelected: value => {
      root.selected(value);
    }
  }
}
