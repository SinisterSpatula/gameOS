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
  property int currentsetting: 0
  
  // settings values
  // ----------------------------------- Orange ----- Red ----- Purple -- Green ----- Blue ---- Yellow -- Sky Blue --- Brown
  property var settingsHighlightColor: ["#FF9E12", "#CC0000", "#CC00CC", "#33CC33", "#3333FF", "#E6E600", "#66CCFF", "#996600"]
  property var settingsScrollSpeed: [200, 500, 300] //medium, fast, slow - used by flickable game description.
  property var settingsWheelArt: [0, 1] //show wheel art, 0 = no, 1 = yes.
  property var settingsFanart: [0, 1] //show fanart in backgrounds, 0 = no, 1 = yes.
  property var settingsUpdateCommand: "cd && cd /home/pi/.config/pegasus-frontend/themes/gameOS && git pull"
  property var settingsList: [0, 1, 2, 3, 4] //Color, Scrollspeed, WheelArt, Fanart, Update.
  property var settingsDescription: ["Change the highlight color", "Change the Game Description Scrolling speed", "Should wheel art be displayed on the game tiles?", "Should Fanart be displayed in the background?", "Do you want to update the theme?"]
  
  signal settingsCloseRequested

  onFocusChanged: {
    if(focus) {
      nextBtn.focus = true
      currentsetting = 0;
      refreshSetting();
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
    //Hack to check if it was the Gamepad Select button
    if (event.key.toString() == "1048586" && !event.isAutoRepeat) {
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
            text: "Theme Settings"
            color: "white"
            font.pixelSize: vpx(60)
            font.family: titleFont.name
            font.bold: true
            //font.capitalization: Font.AllUppercase
            elide: Text.ElideRight
            opacity: 1
          }

        
	Text {
            id: settingsDescBox

            anchors { top: settingsTitle.bottom; topMargin: vpx(60) }
            width: parent.width
            text: settingsDescription[currentsetting];
            color: "white"
            font.pixelSize: vpx(60)
            font.family: titleFont.name
            font.bold: true
            //font.capitalization: Font.AllUppercase
            elide: Text.ElideRight
            opacity: 1
        }

	Text {
            id: settingsValueBox

            anchors { top: settingsDescBox.bottom; topMargin: vpx(60) }
            width: parent.width
            text: "Current Value: " + currentsetting;
            color: "white"
            font.pixelSize: vpx(60)
            font.family: titleFont.name
            font.bold: true
            //font.capitalization: Font.AllUppercase
            elide: Text.ElideRight
            opacity: 1
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

              KeyNavigation.left: closeBtn
              KeyNavigation.right: prevBtn
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

              KeyNavigation.left: nextBtn
              KeyNavigation.right: minusBtn
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

            // Minus button
            GamePanelButton {
              id: minusBtn
              text: "Dec"
              width: parent.width/numbuttons
              height: parent.height

              onFocusChanged: {
                if (focus)
                  navSound.play()
              }

              KeyNavigation.left: prevBtn
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
	    
	    // Plus button
            GamePanelButton {
              id: plusBtn
              text: "Inc"
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
    
        //settings menu functions
        function nextSetting() {
	        if (currentsetting < (settingsList.length - 1)) {currentsetting++;}
		
		refreshSetting();
	}
        
        function prevSetting() {
	        if (currentsetting > 0) {currentsetting--;}

	        refreshSetting();
	}

	function refreshSetting() {
		settingsValueBox.text = "Current Value: " + currentsetting;
	        settingsDescBox.text = settingsDescription[currentsetting];
	}
	
	
}
