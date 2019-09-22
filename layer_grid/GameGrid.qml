import QtQuick 2.8
import QtMultimedia 5.9
import SortFilterProxyModel 0.2

FocusScope {
  id: root

  // Options
  property int numColumns: 2

  property alias gridWidth: grid.width
  property int gridItemSpacing: (numColumns == 2) ? vpx(14) : vpx(10) // it will double this
  property int currentGameIdx
  property string jumpToPattern: ''

  signal launchRequested
  signal menuRequested
  signal detailsRequested
  signal settingsRequested
  //signal filtersRequested
  signal collectionNext
  signal collectionPrev
  signal gameChanged(int currentIdx)


    SortFilterProxyModel {
        id: filteredGames
        sourceModel: gCurrentCollection.games
        filters: ValueFilter {
            roleName: "favorite"
            value: true
            enabled: (gamesettings.Filters == "Favorites")
        }
        sorters: RoleSorter {
            roleName: "lastPlayed"
            enabled: (gamesettings.Filters == "LastPlayed")
        }
    }
    
  
  Keys.onPressed: {
      if (event.isAutoRepeat)
          return;

      if (api.keys.isDetails(event)) {
          event.accepted = true;
          toggleFav();
          return;
      }
      if (api.keys.isCancel(event)) {
          event.accepted = true;
          menuRequested();
          return;
        }
      if (api.keys.isFilters(event)) {
          event.accepted = true;
          toggleFilters()

          //filtersRequested();
          return;
      }
  }



  //property bool isFavorite: (gCurrentGame && gCurrentGame.favorite) || false
  function toggleFav() {
      if (gCurrentGame)
          gCurrentGame.favorite = !gCurrentGame.favorite;

      toggleSound.play()

  }

  function toggleFilters() {
    if (api.filters.favorite) {
      api.filters.playerCount = 1
      api.filters.favorite = false
      api.filters.current.enabled = false
    } else {
      api.filters.playerCount = 1
      api.filters.favorite = true
      api.filters.current.enabled = true
    }

    //api.filters.index = 0

  }

  onCurrentGameIdxChanged: {
    grid.currentIndex = gCurrentGameIndex
  }



  GridView {
    id: grid

    focus: true

    anchors {
      top: parent.top; topMargin: 0 //- gridItemSpacing  vpx(28)
      bottom: parent.bottom
    }

    anchors.horizontalCenter: parent.horizontalCenter

    cellWidth: grid.width/numColumns
    cellHeight: vpx(325)

    preferredHighlightBegin: vpx(0); preferredHighlightEnd: vpx(325)
    highlightRangeMode: GridView.StrictlyEnforceRange
    displayMarginBeginning: 325

    model: (filteredGames) ? filteredGames : []
    onCurrentIndexChanged: {

      gCalculatedIndex = filteredGames.mapToSource(currentIndex)
      gCurrentGame = gCurrentCollection.games.get(gCalculatedIndex)
      gameChanged(currentIndex)

    }

    Component.onCompleted: {
      positionViewAtIndex(currentIndex, GridView.Contain);
    }

    Keys.onPressed: {
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            root.detailsRequested()
        }
        //Hack to check if it was the Gamepad Select button
        if (event.key.toString() == "1048586" && !event.isAutoRepeat) {
            event.accepted = true;
            root.settingsRequested()
        }
        if (api.keys.isPageUp(event) || api.keys.isPageDown(event)) {
            event.accepted = true;
            var rows_to_skip = Math.max(1, Math.round(grid.height / cellHeight));
            var games_to_skip = rows_to_skip * numColumns;
            if (api.keys.isPageUp(event))
                currentIndex = Math.max(currentIndex - games_to_skip, 0);
            else
                currentIndex = Math.min(currentIndex + games_to_skip, model.count - 1);
        }
        else if (event.key == Qt.Key_Home) {
            currentIndex = 0
        }
        else if (event.key == Qt.Key_End) {
            currentIndex = model.count  - 1
        }
        if (api.keys.isPrevPage(event)) {
            collectionPrev()
        }
        if (api.keys.isNextPage(event)) {
            collectionNext()
        }
        if (event.key == Qt.Key_Alt) { // single Alt key
          jumpToPattern = ''
        }
        if ((event.modifiers & Qt.AltModifier) && event.text) {
          event.accepted = true;
          jumpToPattern += event.text.toLowerCase();
          var match = false;
          for (var idx = 0; idx < model.count; idx++) { // search title starting-with pattern
            var lowTitle = model.get(idx).title.toLowerCase();
            if (lowTitle.indexOf(jumpToPattern) == 0) {
              currentIndex = idx;
              match = true;
              break;
            }
          }
          if (!match) { // no match - try to search title containing pattern
            for (var idx = 0; idx < model.count; idx++) {
              var lowTitle = model.get(idx).title.toLowerCase();
              if (lowTitle.indexOf(jumpToPattern) != -1) {
                currentIndex = idx;
                break;
              }
            }
          }
        }
    }



    delegate: GameGridItem {
      width: GridView.view.cellWidth
      height: GridView.view.cellHeight
      selected: GridView.isCurrentItem

      game: modelData
      z: (selected) ? 100 : 1

      onDetails: detailsRequested();
      onClicked: GridView.view.currentIndex = index

    }

    // Removal animation
    remove: Transition {
      NumberAnimation { property: "opacity"; to: 0; duration: 100 }
    }
  }
}
