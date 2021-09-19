import QtQuick 2.12
import PixyKit 1.0

Block {
    id: block
    transform: Rotation { id: rot; origin.x: 54; origin.y: 54; angle: 0 }
    property var tiles: {
        var component = Qt.createComponent("Tile.qml")
        var tile1 = component.createObject(block, {x: 36, y: 0, color: "#1EB100"})
        var tile2 = component.createObject(block, {x: 36 * 2, y: 0, color: "#1EB100"})
        var tile3 = component.createObject(block, {x: 0, y: 36, color: "#1EB100"})
        var tile4 = component.createObject(block, {x: 36, y: 36, color: "#1EB100"})
        return [tile1, tile2, tile3, tile4]
    }

    property var invalidMovesLeft: {
        return [[0, 0], [90, -1], [180, 0], [270, 0]]
    }

    property var invalidMovesRight: {
        return [[0, 7], [90, 7], [180, 7], [270, 8]]
    }

    property var invalidRotationsForXAxis: {
        return [[90, -1], [270, 8]]
    }

    property var invalidRotationsForYAxis: {
        return [[0, 18]]
    }
}