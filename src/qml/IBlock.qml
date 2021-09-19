import QtQuick 2.12
import PixyKit 1.0

Block {
    id: block
    width : 36 * 4
    height: 36 * 4
    transform: Rotation { id: rot; origin.x: 72; origin.y: 72; angle: 0 }
    property var tiles: {
        var component = Qt.createComponent("Tile.qml")
        var tile1 = component.createObject(block, {x: 0, y: 36, color: "#05A89D"})
        var tile2 = component.createObject(block, {x: 36, y: 36, color: "#05A89D"})
        var tile3 = component.createObject(block, {x: 36 * 2, y: 36, color: "#05A89D"})
        var tile4 = component.createObject(block, {x: 36 * 3, y: 36, color: "#05A89D"})
        return [tile1, tile2, tile3, tile4]
    }

    property var invalidMovesLeft: {
        return [[0, 0], [90, -2], [180, 0], [270, -1]]
    }

    property var invalidMovesRight: {
        return [[0, 6], [90, 7], [180, 6], [270, 8]]
    }

    property var invalidRotationsForXAxis: {
        return [[90, -1], [90, -2], [270, -1], [270, 8], [90, 7], [270, 7]]
    }

    property var invalidRotationsForYAxis: {
        return [[0, 18], [0, 17], [180, 17]]
    }
}