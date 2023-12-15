import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.11
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: configRoot

    QtObject {
        id: unidWeatherValue
        property var value
    }

    signal configurationChanged

    property alias cfg_temperatureUnit: unidWeatherValue.value
    property alias cfg_latitudeC: latitude.text
    property alias cfg_longitudeC: longitude.text
    property alias cfg_useCoordinatesIp: autamateCoorde.checked

    ColumnLayout {
        spacing: units.smallSpacing * 2


RowLayout{
             CheckBox {
            id: autamateCoorde
            text: i18n('use geographic coordinates established by IP address')
            Layout.columnSpan: 2
        }
}
ColumnLayout {
    Item{
        width: configRoot.width
        height: instructions.height*2.5
        Label {
            id: instructions
           visible: (autamateCoorde.checked === true) ? false : true
           wrapMode: Text.WordWrap
           width: parent.width
           text:  i18n("To know your geographic coordinates, I recommend using the following website https://open-meteo.com/en/docs")
       }
    }
  RowLayout{
            visible: (autamateCoorde.checked === true) ? false : true
            Label {
                text: i18n("latitude")
            }
             TextField {
            id: latitude
            width: 200
              }

        }
        RowLayout{
            visible: (autamateCoorde.checked === true) ? false : true
            Label {
                text: i18n("longitude")
            }
             TextField {
            id: longitude
            width: 200
              }

        }
   }
       ColumnLayout {
        spacing: units.smallSpacing * 2

        Label {
            text: i18n("temperature unit:")
        }
        ComboBox {
            textRole: "text"
            valueRole: "value"
			id: positionComboBox
			model: [
                {text: i18n("Celsius (°C)"), value: 0},
                {text: i18n("Fahrenheit (°F)"), value: 1},
            ]
            onActivated: unidWeatherValue.value = currentValue
            Component.onCompleted: currentIndex = indexOfValue(unidWeatherValue.value)
		}

   }
}

}
