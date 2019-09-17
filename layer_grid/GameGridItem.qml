import QtQuick 2.8
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

Item {

  id: root

  property bool selected: false
  property var game
  property int cornerradius: vpx(3)
  property var collection//: api.currentCollection
  property bool steam: false

  signal details
  signal clicked


  // Border
  Rectangle {
    id: itemcontainer
    state: selected ? "SELECTED" : "UNSELECTED"

    width: root.gridItemWidth
    height: root.gridItemHeight
    anchors {
      fill: parent
      margins: gridItemSpacing
    }
    color: "transparent"
    radius: cornerradius + vpx(3)
    
    //border.color: (selected) ? "white" : "transparent"
    //border.width: vpx(6)

    scale: selected ? 1.14 : 1.0
    Behavior on scale { PropertyAnimation { duration: 200; easing.type: Easing.OutQuart; easing.amplitude: 2.0; } }

    // DropShadow
    layer.enabled: selected


    // Animation layer
//    Rectangle {
//      id: rectAnim
//      width: parent.width
//      height: parent.height
//      visible: selected
//      color: gamesettings.highlight
//      opacity: 0.3
//      radius: cornerradius + vpx(3)
//
//    }


    // Background for transparent images (to hide the border transition)
    Rectangle {
      width: root.gridItemWidth
      height: root.gridItemHeight
      anchors {
        fill: parent
        margins: vpx(3)
      }
      color: "#1a1a1a"
      radius: cornerradius
      opacity: (gamelogo.source == "") ? 1.0 : 0.0
    }

    // Actual art

    // Logo
    Image {
      id: gamelogo

      property bool showtext

      width: root.gridItemWidth
      height: root.gridItemHeight
      anchors {
        fill: parent
        margins: vpx(4)
      }

      asynchronous: true

      source: (gamesettings.gridart == "Tile") ? game.assets.steam || game.assets.tile || game.assets.logo || game.assets.screenshots[0] || game.assets.boxFront || "" : (gamesettings.gridart == "Wheel") ? game.assets.logo || game.assets.steam || game.assets.tile || game.assets.screenshots[0] || game.assets.boxFront || "" : (gamesettings.gridart == "Cartridge") ? game.assets.cartridge || game.assets.boxFront || game.assets.logo || game.assets.tile || game.assets.screenshots[0] || "" : (gamesettings.gridart == "Screenshot") ? game.assets.screenshots[0] || game.assets.boxFront || game.assets.tile || game.assets.logo || "" : (gamesettings.gridart == "BoxArt") ? game.assets.boxFront || game.assets.cartridge || game.assets.logo || game.assets.tile || game.assets.screenshots[0] || "" : "";
      sourceSize { width: 256; height: 256 }
      fillMode: (source == game.assets.logo || source == game.assets.boxFront || source == game.assets.cartridge) ? Image.PreserveAspectFit : Image.PreserveAspectCrop
      showtext: !(source == game.assets.steam || source == game.assets.logo) || progress < 1
      smooth: true
      visible: true
      z:5
    }
    //For the logo/screenshot/boxart/cartridge, a dimming effect.
    ColorOverlay {
          anchors.fill: gamelogo
          source: gamelogo
          color: "#80000000"
          z: gamelogo.z + 1
          visible: (selected) ? false : true
      }

    // Favourite tag
    Item {
      id: favetag
      anchors { top: parent.top; right: gamelogo.paintedWidth; margins: vpx(4); }
      opacity: game.favorite ? 1 : 0
      Behavior on opacity { NumberAnimation { duration: 100 } }
      //width: parent.width
      //height: parent.height

      Image {
        id: favebg
        source: "../assets/images/favebg.svg"
        width: vpx(64) //vpx(32)
        height: vpx(64) //vpx(32)
        sourceSize { width: vpx(32); height: vpx(32)}
        anchors { top: parent.top; topMargin: vpx(0); right: parent.right; rightMargin: vpx(0) }
        visible: false

      }
      ColorOverlay {
          anchors.fill: favebg
          source: favebg
          color: gamesettings.highlight
          z: 10
      }

      Image {
        id: star
        source: "../assets/images/star.svg"
        width: vpx(26) //vpx(13)
        height: vpx(26) //vpx(13)
        sourceSize { width: vpx(32); height: vpx(32)}
        anchors { top: parent.top; topMargin: vpx(3); right: parent.right; rightMargin: vpx(3) }
        smooth: true
        z: 11
      }
      z: 12

      layer.enabled: true
      layer.effect: OpacityMask {
        maskSource: Item {
          width: favetag.width
          height: favetag.height
          Rectangle {
            anchors.centerIn: parent
            width: favetag.width
            height: favetag.height
            radius: cornerradius - vpx(1)
          }
        }
      }
    }


    //////////////////////////
    // States for animation //
    //////////////////////////
    states: [
      State {
        name: "SELECTED"
        PropertyChanges { target: gamelogo; opacity: 1 }
        //PropertyChanges { target: itemcontainer; color: gamesettings.highlight}
        //PropertyChanges { target: rectAnim; opacity: 0.3 }
        //PropertyChanges { target: dimoverlay; opacity: 0.0 } //0.4
      },
      State {
        name: "UNSELECTED"
        PropertyChanges { target: gamelogo; opacity: 1 }
        //PropertyChanges { target: itemcontainer; color: "transparent"}
        //PropertyChanges { target: rectAnim; opacity: 0 }
        PropertyChanges { target: gamelogo; opacity: 0.6 }
        //PropertyChanges { target: dimoverlay; opacity: 0.5 }
      }
    ]

    transitions: [
      Transition {
        from: "SELECTED"
        to: "UNSELECTED"
        //PropertyAnimation { target: rectAnim; duration: 100 }
        //ColorAnimation { target: itemcontainer; duration: 100 }
        //PropertyAnimation { target: rectAnim; duration: 100 }
        PropertyAnimation { target: gamelogo; duration: 100 }
        //PropertyAnimation { target: dimoverlay; duration: 100 }
      },
      Transition {
        from: "UNSELECTED"
        to: "SELECTED"
        //PropertyAnimation { target: rectAnim; duration: 100 }
        //ColorAnimation { target: itemcontainer; duration: 100 }
        //PropertyAnimation { target: rectAnim; duration: 1000 }
        PropertyAnimation { target: gamelogo; duration: 100 }
        //PropertyAnimation { target: dimoverlay; duration: 100 }
      }
    ]
  }

  Image {
    anchors.centerIn: parent

    visible: gamelogo.status === Image.Loading
    source: "../assets/images/loading.png"
    width: vpx(50)
    height: vpx(50)
    smooth: true
    RotationAnimator on rotation {
        loops: Animator.Infinite;
        from: 0;
        to: 360;
        duration: 500
    }
  }

  MouseArea {
      anchors.fill: itemcontainer
      hoverEnabled: true
      onEntered: {}
      onExited: {}
      onClicked: {
        if (selected)
          root.details()
        else
          root.clicked()
      }
  }



  Text {
    text: game.title
    width: itemcontainer.width - vpx(10)
    anchors {
      left: parent.left; leftMargin: vpx(16);
      bottom: parent.bottom; bottomMargin: vpx(14)
    }
    color: selected ? "white" : "gray"
    font.pixelSize: vpx(60)
    font.family: titleFont.name
    font.bold: true
    visible: gamelogo.showtext
    style: Text.Outline; styleColor: "black"
    elide: Text.ElideRight
    wrapMode: Text.WordWrap
  }
}
