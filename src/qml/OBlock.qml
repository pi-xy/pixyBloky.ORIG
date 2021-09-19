import QtQuick 2.12
import PixyKit 1.0

Block {
    id: block
    width : 36 * 2
    height: 36 * 2
    transform: Rotation { id: rot; origin.x: 36; origin.y: 36; angle: 0 }
    property var tiles: {
        var component = Qt.createComponent("Tile.qml")
        var tile1 = component.createObject(block, {x: 0, y: 0, color: "#F7BA00"})
        var tile2 = component.createObject(block, {x: 36, y: 0, color: "#F7BA00"})
        var tile3 = component.createObject(block, {x: 0, y: 36, color: "#F7BA00"})
        var tile4 = component.createObject(block, {x: 36, y: 36, color: "#F7BA00"})
        return [tile1, tile2, tile3, tile4]
    }

    function canMoveLeft() {
        if (matrixXIndex() == 0)
            return false
        return true
    }

    function canMoveRight() {
        if (matrixXIndex() == 8)
            return false
        return true
    }

    function canRotate() {
        return true
    }
}