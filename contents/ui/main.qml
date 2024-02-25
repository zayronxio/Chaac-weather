/*
    SPDX-FileCopyrightText: zayronxio
    SPDX-License-Identifier: GPL-3.0-or-later
*/
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore


Item {
    id: root
    width: 400
    height: 200

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.ConfigurableBackground

    property string useCoordinatesIp: plasmoid.configuration.useCoordinatesIp
    property bool boldfonts: plasmoid.configuration.boldfonts
    property string temperatureUnit: plasmoid.configuration.temperatureUnit

    property string latitudeC: plasmoid.configuration.latitudeC
    property string longitudeC: plasmoid.configuration.longitudeC

    property string latitude: (useCoordinatesIp === "true") ? "null" : (latitudeC === "0") ? "null" : latitudeC
    property string longitud: (useCoordinatesIp === "true") ? "null" : (longitudeC === "0") ? "null" : longitudeC


    property string textbycommand: (" "+latitude+" "+longitud+" ")

    property string temperatura: "0"
    property string temperaturaF: (temperatura*9 / 5)+ 32
    property int codeweather: 0
    property string loc: "null"
    property string command: "bash $HOME/.local/share/plasma/plasmoids/zayron.chaac.weather/contents/ui/lib/datos.sh"

    PlasmaCore.DataSource {
      id: executable
      engine: "executable"
      connectedSources: []
      onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName) // cmd finished
                  }
     function exec(cmd) {
            connectSource(cmd)
           }
     signal exited(int exitCode, int exitStatus, string stdout, string stderr)
       }

   Connections {
     target: executable
     onExited: {
                    temperatura = stdout
                }
          }


Component.onCompleted: {
            var cmd = command+textbycommand+"tem"
            var cmd1 = command+textbycommand+"ubi"+" "+(Qt.locale().name).replace("_", "-")
            var cmd2 = command+textbycommand+"codetem"
            executable.exec(cmd)
            executable2.exec(cmd1)
            executable3.exec(cmd2)
}

PlasmaCore.DataSource {
        id: executable2
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName) // cmd finished
                   }
function exec(cmd) {
            connectSource(cmd)
}
signal exited(int exitCode, int exitStatus, string stdout, string stderr)
}

Connections {
target: executable2
onExited: {
                    loc = stdout
}
}

PlasmaCore.DataSource {
        id: executable3
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName) // cmd finished
                   }
function exec(cmd) {
            connectSource(cmd)
}
signal exited(int exitCode, int exitStatus, string stdout, string stderr)
}

Connections {
target: executable3
onExited: {
                    codeweather = stdout
}
}

   function asingicon(){
            let wmocodes = {
              0 : "clear",
              1 : "few-clouds",
              2 : "few-clouds",
              3 : "clouds",
              51 : "showers-scattered",
              53 : "showers-scattered",
              55 : "showers-scattered",
              56 : "showers-scattered",
              57 : "showers-scattered",
              61 : "showers",
              63 : "showers",
              65 : "showers",
              66 : "showers-scattered",
              67 : "showers",
              71 : "snow-scattered",
              73 : "snow",
              75 : "snow",
              77 : "hail",
              80 : "showers",
              81 : "showers",
              82 : "showers",
              85 : "snow-scattered",
              86 : "snow",
              95 : "storm",
              96 : "storm",
              99 : "storm",
                     }

            var timeActual = Qt.formatDateTime(new Date(), "h")
            var isDay = timeActual > "6" && timeActual < "19"
            var cicloOfDay = isday()

            var iconName = "weather-" + (wmocodes[codeweather] || "unknown") + "-" + cicloOfDay

    return iconName
    }

  function isday() {
    var timeActual = Qt.formatDateTime(new Date(), "h")
    if (timeActual < 6) {
      if (timeActual > 19) {
        return "night"
      } else {
        return "day"
      }
    } else {
      if (timeActual > 19) {
        return "night"
      } else {
        return "day"
      }
    }
  }
   Column {
       id: base
       width: parent.width < parent.height*2 ? parent.width : parent.height*2
       height: width/2
       anchors.centerIn: parent

       Row {
           id: iconAndGrados
           width: base.height*2
           height: base.height

           PlasmaCore.IconItem {
                width: base.height
                height: base.height
                source: asingicon()
                roundToIconSize: false
           }
           Column {
               width: base.height
               height: width
               spacing: 0
               Row {
                   height: temOfCo.height
                   Text {
                      id: temOfCo
                      text: (temperatureUnit === "0") ? parseFloat(temperatura).toFixed(1) : parseFloat(temperaturaF).toFixed(1)
                      font.bold: boldfonts
                      color: "white"
                      font.pixelSize: iconAndGrados.height/2.5
                        }
                   Text {
                      text: (temperatureUnit === "0") ? "°C" : "°F"
                      font.bold: boldfonts
                      color: "white"
                      font.pixelSize: iconAndGrados.height/5
                      }

              }
              Text {
                  width: base.height
                  anchors.top: parent.top
                  anchors.topMargin: iconAndGrados.height/2.3
                  text: loc
                  color: "white"
                  wrapMode: Text.WordWrap
                  font.pixelSize: iconAndGrados.height/5.5
               }
             }
           }
        Timer {
            interval: 900000
            running: true
            repeat: true
            onTriggered: {
               var cmd = command+textbycommand+"tem"
               var cmd1 = command+textbycommand+"ubi"+" "+(Qt.locale().name).replace("_", "-")
               var cmd2 = command+textbycommand+"codetem"
               executable.exec(cmd)
               executable2.exec(cmd1)
               executable3.exec(cmd2)
                       }
        }
   }
}
