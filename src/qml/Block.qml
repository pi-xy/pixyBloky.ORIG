import QtQuick 2.12
import PixyKit 1.0

Item {
        id: block
        width: 36 * 3
        height: 36 * 3
  
        x: parent.width / 2.0 - 72
        y: -(72 * 1.25)
       
        property var matrixOriginX: 180
        property var matrixOriginY: 0

        property var rested: false

        function angle() {
            return rot.angle
        }

        function matrixXPos() {
            return block.x - matrixOriginX
        }

        function matrixYPos() {
            return block.y - matrixOriginY
        }

        function matrixXIndex() {
            return matrixXPos() / 36.0
        }

        function matrixYIndex() {
            return matrixYPos() / 36.0
        }
     
        function canMoveLeft() {
            for (var i = 0; i < invalidMovesLeft.length; i++) {
                var pair = invalidMovesLeft[i]
                if (angle() == pair[0] && matrixXIndex() == pair[1]) {
                    return false
                }
            }

            for (var i = 0; i < tiles.length; i++) {
                var tile = tiles[i]
                var globalCoordinares = tile.mapToItem(tile.parent.parent, 0, 0)
                for (var j = 0; j < block.parent.blocks.length; j++) {
                    var b = block.parent.blocks[j]
                    if (b == block) {
                        continue;
                    }
                    if (b.hasTileToLeft(globalCoordinares)) {
                        return false
                    }
                }
            }

            return true;
        }

        function canMoveRight() {
            for (var i = 0; i < invalidMovesRight.length; i++) {
                var pair = invalidMovesRight[i]
                if (angle() == pair[0] && matrixXIndex() == pair[1]) {
                    return false;
                }
            }

            for (var i = 0; i < tiles.length; i++) {
                var tile = tiles[i]
                var globalCoordinares = tile.mapToItem(tile.parent.parent, 0, 0)
                for (var j = 0; j < block.parent.blocks.length; j++) {
                    var b = block.parent.blocks[j]
                    if (b == block) {
                        continue;
                    }
                    if (b.hasTileToRight(globalCoordinares)) {
                        return false;
                    }
                }
            }

            return true;
        }

        function moveLeft() {
            if (!canMoveLeft()) return
            block.x -= 36;
        }

        function moveRight() {
            if (!canMoveRight()) return
            block.x += 36
        }

        function canRotate() {
            for (var i=0; i < invalidRotationsForXAxis.length; i++) {
                var pair = invalidRotationsForXAxis[i]
                if (angle() == pair[0] && matrixXIndex() == pair[1]) {
                    return false
                }
            }

            for (var i=0; i < invalidRotationsForYAxis.length; i++) {
                var pair = invalidRotationsForYAxis[i]
                if (angle() == pair[0] && matrixYIndex() == pair[1]) {
                    return false
                }
            }
            return true
        }

        function rotate() {   
            if (!canRotate()) {
                return
            }
            rot.angle += 90
            if (rot.angle == 360) {
                rot.angle = 0
            }

            for (var i=0; i < tiles.length; i++) {
                var tile = tiles[i]
                tile.rotation = - rot.angle
            }

            var overlaps = false
            for (var i = 0; i < tiles.length; i++) {
                var tile = tiles[i]
                var globalCoordinares = tile.mapToItem(tile.parent.parent, 0, 0)
                for (var j = 0; j < block.parent.blocks.length; j++) {
                    var b = block.parent.blocks[j]
                    if (b == block) {
                        continue
                    }
                    if (b.hasTileOverlapping(globalCoordinares)) {
                        overlaps = true
                        break
                    }
                }
            }

            if (overlaps) {
                rotateBack()
            }
        }

        function rotateBack() {   
            rot.angle -= 90
            for (var i=0; i < tiles.length; i++) {
                var tile = tiles[i]
                tile.rotation = - rot.angle
            }
        }

        function moveAllTilesDownByOneAbove(yy) {
             var tilesToMove = []
             for (var y=yy-36; y != 0; y-=36) {
                 for (var x=matrixOriginX; x != matrixOriginX + 720; x+=36) {
                     for (var j = 0; j < block.parent.blocks.length; j++) {
                        var b = block.parent.blocks[j]
                        var tile = b.tileExists(x, y)
                         if (tile != null && tile.visible) {
                             tilesToMove.push(tile)
                         }
                     }                    
                 }
             } 
            tilesToMove.forEach(function (tile) {
                if (tile.parent.angle() == 0)
                    tile.y += 36
                else if (tile.parent.angle() == 90)
                    tile.x += 36
                else if (tile.parent.angle() == 180)
                    tile.y -= 36
                else
                    tile.x -= 36
            });
        }

        function removeCompletedLines() {
            var linesRemoved = []
            for (var y=matrixOriginY + 720; y != 0; y-=36) {
                var completeLine = false
                var tiles = []
                for (var x=matrixOriginX; x != matrixOriginX + 720; x+=36) {
                    for (var j = 0; j < block.parent.blocks.length; j++) {
                       var b = block.parent.blocks[j]
                       var tile = b.tileExists(x, y)
                        if (tile != null) {
                            tiles.push(tile)
                        }
                    }                    
                }
                if (tiles.length == 10) {
                    tiles.forEach(tile => tile.visible = false)
                    var globalCoordinares = tiles[0].mapToItem(tiles[0].parent.parent, 0, 0)
                    linesRemoved.push(globalCoordinares.y)
                    break
                }
            } 
            linesRemoved.forEach(y => moveAllTilesDownByOneAbove(y));
            return linesRemoved.length > 0
        }

        function lookForCompletedLines() {
            while(removeCompletedLines()) {}
        }

        function tileExists(x, y) {
            for (var i=0; i < tiles.length; i++) {
                var tile = tiles[i]
                var globalCoordinares = tile.mapToItem(tile.parent.parent, 0, 0)
                if (tile.visible && globalCoordinares.y == y && globalCoordinares.x == x) {
                    return tile
                }
            }
            return null;
        }

        function fallByOne() {
            block.y += 36
        }

        function hasTileOverlapping(gc) {
            for (var i=0; i < tiles.length; i++) {
                var tile = tiles[i]
                var globalCoordinares = tile.mapToItem(tile.parent.parent, 0, 0)
                if (tile.visible && globalCoordinares.x == gc.x && globalCoordinares.y == gc.y) {
                    return true
                }
            }
            return false;
        }
        
        function hasTileBelow(gc) {
            for (var i=0; i < tiles.length; i++) {
                var tile = tiles[i]
                var globalCoordinares = tile.mapToItem(tile.parent.parent, 0, 0)
                if (tile.visible && globalCoordinares.x == gc.x && globalCoordinares.y == gc.y+36) {
                    return true
                }
            }
            return false;
        }

        function hasTileToRight(gc) {
            for (var i=0; i < tiles.length; i++) {
                var tile = tiles[i]
                var globalCoordinares = tile.mapToItem(tile.parent.parent, 0, 0)
                if (tile.visible && globalCoordinares.y == gc.y && globalCoordinares.x == gc.x+36) {
                    return true
                }
            }
            return false
        }

        function hasTileToLeft(gc) {
            for (var i=0; i < tiles.length; i++) {
                var tile = tiles[i]
                var globalCoordinares = tile.mapToItem(tile.parent.parent, 0, 0)
                if (tile.visible && globalCoordinares.y == gc.y && globalCoordinares.x == gc.x-36) {
                    return true
                }
            }
            return false
        }

        function flashCompletedTiles() {
            var linesRemoved = []
            var flashed = false
            var firstTileFlashed = true
            var completedLineCount = 0
            for (var y=matrixOriginY + 720; y != 0; y-=36) {
                var completeLine = false
                var tiles = []
                for (var x=matrixOriginX; x != matrixOriginX + 720; x+=36) {
                    for (var j = 0; j < block.parent.blocks.length; j++) {
                       var b = block.parent.blocks[j]
                       var tile = b.tileExists(x, y)
                        if (tile != null) {
                            tiles.push(tile)
                        }
                    }                    
                }
                if (tiles.length == 10) {
                    parent.increaseLineCount()
                    completedLineCount++
                    flashed = true
                    tiles.forEach(function (tile) {
                        tile.flash(firstTileFlashed)
                        firstTileFlashed = false
                    });
                }
            }

            var points = 0
            if (completedLineCount == 1) {
                points = 100 * parent.level
            }
            else if (completedLineCount == 2) {
                points = 300 * parent.level
            }
            else if (completedLineCount == 3) {
                points = 500 * parent.level
            }
            else if (completedLineCount == 4) {
                points = 800 * parent.level
            }
            parent.increaseScore(points)
            
            return flashed
        }

        function hideBlocks() {
            block.parent.block.visible = false
            for (var j = 0; j < block.parent.blocks.length; j++) {
                    var b = block.parent.blocks[j]
                    for (var i=0; i < tiles.length; i++) {
                    var tile = b.tiles[i]
                    if (tile.visible) {
                        tile.visible = false
                    }
                }   
            }
        }

        function isResting() {

            if (rested) {
                return true
            }

            for (var i=0; i < tiles.length; i++) {
                var tile = tiles[i]
                var globalCoordinares = tile.mapToItem(tile.parent.parent, 0, 0)
                if (globalCoordinares.y == 720-36)  {
                    rested = true
                    width = 720
                    height = 720
                    lookForCompletedLines()
                    return true
                }

                for (var j=0; j < block.parent.blocks.length; j++) {
                    var b = block.parent.blocks[j];
                    if (b == block) {
                        continue
                    }
                    if (b.hasTileBelow(globalCoordinares)) {
                        rested = true
                        width = 720
                        height = 720
                        lookForCompletedLines()
                        return true
                    }
                }
            }
            return false;
        }

        function willRest() {
            for (var i=0; i < tiles.length; i++) {
                var tile = tiles[i]
                var globalCoordinares = tile.mapToItem(tile.parent.parent, 0, 0)
                if (globalCoordinares.y == 720-36)  {
                    return true
                }

                for (var j=0; j < block.parent.blocks.length; j++) {
                    var b = block.parent.blocks[j]
                    if (b == block) {
                        continue;
                    }
                    if (b.hasTileBelow(globalCoordinares)) {
                        return true
                    }
                }
            }
            return false
        }
}