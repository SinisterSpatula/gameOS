import QtQuick 2.8
import QtGraphicalEffects 1.0

Item {
  id: root
  property var gameData//: currentCollection.games.get(gameList.currentIndex)
  property real dimopacity: 0.96

  property string bgDefault: '../assets/images/defaultbg.png'
  property string bgSource: (gamesettings.fanArt && gameData.assets.background) ? gameData.assets.background : (!gamesettings.fanArt && gameData.assets.screenshots[0]) ? gameData.assets.screenshots[0] : bgDefault


  Item {
    id: bg

    anchors.fill: parent


    Image {
        id: rect
        anchors.fill: parent
        visible: gameData
        asynchronous: true
        source: bgDefault //bgSource
        sourceSize { width: 320; height: 240 }
        fillMode: Image.PreserveAspectCrop
        smooth: false
    }

    //state: "fadeInRect2"

  }



  LinearGradient {
    z: parent.z + 1
    width: parent.width
    height: parent.height
    anchors {
      top: parent.top; topMargin: vpx(200)
      right: parent.right
      bottom: parent.bottom
    }
    start: Qt.point(0, 0)
    end: Qt.point(0, height)
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#00000000" }
      GradientStop { position: 0.7; color: "#ff000000" }
    }
  }

  Rectangle {
    id: backgrounddim
    anchors.fill: parent
    color: "#697796" //15181e

    opacity: dimopacity

    Behavior on opacity { NumberAnimation { duration: 100 } }
  }



}
