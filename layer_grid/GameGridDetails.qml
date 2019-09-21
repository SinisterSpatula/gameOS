import QtQuick 2.8
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.0
import "../utils.js" as Utils

Item {
  id: root

  property bool issteam: false
  anchors.horizontalCenter: parent.horizontalCenter
  clip: true



  Text {
    id: gameTitle

    anchors {
      //verticalCenter: parent.verticalCenter
      fill: parent
      top: parent.top
      //topMargin: vpx(10)
    }
    width: vpx(1080) //vpx(850)
    text: gCurrentGame.title
    color: "white"
    font.pixelSize: vpx(100) //vpx(70)
    font.family: titleFont.name
    font.bold: true
    //font.capitalization: Font.AllUppercase
    elide: Text.ElideRight
    wrapMode: Text.WordWrap
    lineHeightMode: Text.FixedHeight
    lineHeight: vpx(90)
    //visible: (gCurrentGame.assets.logo == "") ? true : false
    //style: Text.Outline; styleColor: "#cc000000"
  }

  DropShadow {
      anchors.fill: gameTitle
      horizontalOffset: 0
      verticalOffset: 0
      radius: 8.0
      samples: 17
      color: "#ff000000"
      source: gameTitle
      //visible: (gCurrentGame.assets.logo == "") ? true : false
  }

  ColumnLayout {
    id: playinfo
    anchors {
      //top: gameTitle.top; topMargin: vpx(30);
      right: parent.right; rightMargin: vpx(60)
      verticalCenter: parent.verticalCenter
    }

    width: vpx(150)
    spacing: vpx(4)



    Item {
      id: spacerhack
      Layout.preferredHeight: vpx(5)
    }

    /*GameGridMetaBox {
      metatext: gCurrentGame.developerList[0]
    }*/

    GameGridMetaBox {
      metatext: if (gCurrentGame.players > 1)
        gCurrentGame.players + " players"
      else
        gCurrentGame.players + " player"
    }


  }

  RowLayout {
    id: metadata
    anchors {
      //top: (gCurrentGame.assets.logo == "") ? gameTitle.bottom : detailslogo.bottom;
      //topMargin: (gCurrentGame.assets.logo == "") ? vpx(-5) : vpx(10);
      top: gameTitle.bottom; topMargin: vpx(-5)
    }
    height: vpx(1)
    spacing: vpx(6)

    // Developer
    GameGridMetaBox {
      metatext: (gCurrentGame.developerList[0] != undefined) ? gCurrentGame.developerList[0] : "Unknown"
    }

    // Release year
    GameGridMetaBox {
      metatext: (gCurrentGame.release != "") ? gCurrentGame.release.getFullYear() : ""
    }


    // Spacer
    Item {
      Layout.preferredWidth: vpx(5)
    }
    Rectangle {
      id: spacer
      Layout.preferredWidth: vpx(2)
      Layout.fillHeight: true
      opacity: 0.5
    }
    Item {
      Layout.preferredWidth: vpx(5)
    }

    // Times played
    GameGridMetaBox {
      metatext: (gCurrentGame.playCount > 0) ? gCurrentGame.playCount + " times" : "Never played"
      icon: "../assets/images/gamepad.svg"
    }

    // Play time (if it has been played)
    GameGridMetaBox {
      metatext: Utils.formatPlayTime(gCurrentGame.playTime)
      icon: "../assets/images/clock.svg"
      visible: false //visible: (gCurrentGame.playTime > 0)
    }
  }

}
