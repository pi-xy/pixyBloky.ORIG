import QtQuick 2.12
import PixyKit 1.0

Rectangle {
    id: tile
    width: 36
    height: 36
    color: "red"
    opacity: 0.85

    property alias text:text

    Text {
        id: text
        text: ""
        font.family: "Helvetica"
        font.pointSize: 8
        color: "white"
    }

    function flash(firstTileFlashed) {
        animateOpacity.firstTileFlashed = firstTileFlashed;
        animateOpacity.start();
    }

    SequentialAnimation {
        id: animateOpacity
        loops: 1
        property var firstTileFlashed : false

        onRunningChanged: {
            if (!animateOpacity.running) {
                if (firstTileFlashed) {
                    parent.parent.startTicker()
                }
            }
        }

        NumberAnimation {
            target: tile
            properties: "opacity"
            from: 1
            to: 0
            duration: 300
        }

        NumberAnimation {
            target: tile
            properties: "opacity"
            from: 0
            to: 1
            duration: 300
        }
    }
}