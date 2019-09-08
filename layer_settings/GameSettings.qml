import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import QtQuick.Layouts 1.11
import "qrc:/qmlutils" as PegasusUtils
import "../layer_grid"
import "../utils.js" as Utils

Item {
  id: root

  property int padding: vpx(50)
  property int cornerradius: vpx(8)
  property int numbuttons: 5

  signal settingsCloseRequested

  onFocusChanged: {
    if(focus) {
      prevBtn.focus = true
    }
  }

  visible: (backgroundbox.opacity == 0) ? false : true

  // Empty area for closing out of bounds
  Item {
    anchors.fill: parent
    PegasusUtils.HorizontalSwipeArea {
        anchors.fill: parent
        onClicked: closesettings()
    }

  }

  Keys.onPressed: {
    
    if (event.isAutoRepeat)
      return;

    if (api.keys.isCancel(event)) {
      event.accepted = true;
      closesettings();
      return;
    }   
    
  }


  function closesettings() {
    settingsCloseRequested();
  }

    Rectangle {
      id: backgroundbox
      anchors {
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
      }
      width: parent.width - vpx(182)
      height: vpx(700)
      color: "#1a1a1a"//"#ee1a1a1a"
      radius: cornerradius
      opacity: 0
      Behavior on opacity { NumberAnimation { duration: 100 } }

      scale: 1.03
      Behavior on scale { NumberAnimation { duration: 100 } }
      // DropShadow
      layer.enabled: true
      layer.effect: DropShadow {
          horizontalOffset: 0
          verticalOffset: 0
          radius: 20.0
          samples: 17
          color: "#80000000"
          transparentBorder: true
      }

	
        // NOTE: Settings section
        Item {
          id: settings
          anchors {
            top: parent.top; topMargin: vpx(0)
            left: parent.left;
            leftMargin: vpx(5)
            bottom: parent.bottom; right: parent.right
          }

          Text {
            id: settingsTitle

            anchors { top: parent.top; topMargin: vpx(15) }
            width: parent.width
            text: "Settings"
            color: "white"
            font.pixelSize: vpx(60)
            font.family: titleFont.name
            font.bold: true
            //font.capitalization: Font.AllUppercase
            elide: Text.ElideRight
            opacity: 1
          }

        }

      }

      // NOTE: Navigation
      Item {
        id: navigation
        anchors.fill: parent
        width: parent.width
        height: parent.height

        Rectangle {
          id: navigationbox
          anchors {
            bottom: parent.bottom;
            left: parent.left; right: parent.right;
          }
          color: "#16ffffff"
          width: parent.width
          height: vpx(80)

          // Buttons
          Row {
            id: panelbuttons
            width: parent.width
            height: parent.height
            anchors.fill: parent

            // Previous button
            GamePanelButton {
              id: prevBtn
              text: "Previous"
              width: parent.width/numbuttons
              height: parent.height

              onFocusChanged: {
                if (focus) {
                  navSound.play()
                }
              }

              KeyNavigation.left: closeBtn
              KeyNavigation.right: nextBtn
              Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                  event.accepted = true;
                  prevSetting();
                }
              }
              onClicked: {
                focus = true;
                prevSetting();
              }
            }

            Rectangle {
              width: vpx(1)
              height: parent.height
              color: "#1a1a1a"
            }

            // Next button
            GamePanelButton {
              id: nextBtn
              text: "Next"
              width: parent.width/numbuttons
              height: parent.height

              onFocusChanged: {
                if (focus)
                  navSound.play()
              }

              KeyNavigation.left: prevBtn
              KeyNavigation.right: increaseBtn
              Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                  event.accepted = true;
                  nextSetting();
                }
              }
              onClicked: {
                focus = true
                nextSetting();
              }
            }
            Rectangle {
              width: vpx(1)
              height: parent.height
              color: "#1a1a1a"
            }

            // Minus button
            GamePanelButton {
              id: minusBtn
              text: "-"
              width: parent.width/numbuttons
              height: parent.height

              onFocusChanged: {
                if (focus)
                  navSound.play()
              }

              KeyNavigation.left: nextBtn
              KeyNavigation.right: plusBtn
              Keys.onPressed: {
                  if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                      event.accepted = true;
                      decreaseSetting();
                  }
              }

              onClicked: {
                  focus = true;
                  decreaseSetting();
              }

            }

            Rectangle {
              width: vpx(1)
              height: parent.height
              color: "#1a1a1a"
            }
	    
	    // Pluse button
            GamePanelButton {
              id: plusBtn
              text: "+"
              width: parent.width/numbuttons
              height: parent.height

              onFocusChanged: {
                if (focus)
                  navSound.play()
              }

              KeyNavigation.left: minusBtn
              KeyNavigation.right: closeBtn
              Keys.onPressed: {
                  if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                      event.accepted = true;
                      increaseSetting();
                  }
              }

              onClicked: {
                  focus = true;
                  increaseSetting();
              }

            }

            Rectangle {
              width: vpx(1)
              height: parent.height
              color: "#1a1a1a"
            }

            // Close button
            GamePanelButton {
              id: closeBtn
              text: "Close"
              width: parent.width/numbuttons
              height: parent.height
              onFocusChanged: {
                if (focus)
                  navSound.play()
              }

              KeyNavigation.left: plusBtn
              KeyNavigation.right: nextBtn
              Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                  event.accepted = true;
                  closesettings();
                }
              }
              onClicked: {
                focus = true;
                closesettings();
              }
            }

          }
        }



        // Round those corners!
        layer.enabled: true
        layer.effect: OpacityMask {
          maskSource: Item {
            width: navigation.width
            height: navigation.height
            Rectangle {
              anchors.centerIn: parent
              width: navigation.width
              height: navigation.height
              radius: cornerradius
            }
          }
        }
      }

      // Empty area for swiping on touch
      Item {
        anchors.fill: parent
        PegasusUtils.HorizontalSwipeArea {
            anchors { top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: vpx(60) }
            //visible: root.focus
            //onSwipeRight: if (showVideo) { toggleVideo() }
            //onSwipeLeft: if (!showVideo) { toggleVideo() }
            //onClicked: toggleVideo()
        }

      }

    }

    function intro() {
        backgroundbox.opacity = 1;
        backgroundbox.scale = 1;
        menuIntroSound.play()
    }

    function outro() {
        backgroundbox.opacity = 0;
        backgroundbox.scale = 1.03;
        menuIntroSound.play()
    }
}