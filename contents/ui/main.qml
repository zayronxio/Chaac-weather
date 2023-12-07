/*
    SPDX-FileCopyrightText: zayronxio
    SPDX-License-Identifier: GPL-3.0-or-later
*/
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore


Item {
    id: root
    width: 400
    height: 200

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.ConfigurableBackground

    property string useCoordinatesIp: plasmoid.configuration.useCoordinatesIp
    property string temperatureUnit: plasmoid.configuration.temperatureUnit

    property string latitude: (useCoordinatesIp === "true") ? "null" : (plasmoid.configuration.latitudeC === 0) ? "null" : plasmoid.configuration.latitudeC
    property string longitud: (useCoordinatesIp === "true") ? "null" : (plasmoid.configuration.longitudeC === 0) ? "null" : plasmoid.configuration.longitudeC


    property string textbycommand: (" "+latitude+" "+longitud+" ")

    property string temperatura: "0"
    property int codeweather: 0
    property string loc: "null"
    property string command: "bash $HOME/.local/share/plasma/plasmoids/zayron.weater/contents/ui/lib/datos.sh"

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
            var cmd1 = command+textbycommand+"ubi"
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
           var timeActual = Qt.formatDateTime(new Date(), "h:mm")
           var cicloOfDay = "night"
           var nameicon = "null"

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

            if (timeActual > "06:00" && timeActual < "19:45") {
                         var cicloOfDay = "day"
                       } var cicloOfDay = "night"
           return "weather-"+wmocodes[codeweather]+"-"+cicloOfDay
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
                      text: (temperatureUnit === "0") ? temperatura : ((temperatura*9 / 5)+ 32)
                      font.bold: true
                      color: "white"
                      font.pixelSize: iconAndGrados.height/2.5
                        }
                   Text {
                      text: (temperatureUnit === "0") ? "°C" : "°F"
                      font.bold: true
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
               var cmd1 = command+textbycommand+"ubi"
               var cmd2 = command+textbycommand+"codetem"
               executable.exec(cmd)
               executable2.exec(cmd1)
               executable3.exec(cmd2)
                       }
        }
   }
}