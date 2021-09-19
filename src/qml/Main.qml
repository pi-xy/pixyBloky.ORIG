import QtQuick 2.12
import PixyKit 1.0
import "Common.js" as Common

PixyStage {

    FontLoader {id:fontThin;source:"../resources/Montserrat-Thin.ttf" }
    FontLoader {id:fontMedium;source:"../resources/Montserrat-Medium.ttf" }

    property var component
    property var block

    property var blocks: []

    property var level: 1
    property var lineCount: 0
    property var score: 0
    
    id: mainStage
    focus: true

    Connections {
        target: loader
        function onLoaded() {
           updateHighScoreOnStart(false)
        }
    }

    Image {
        id: gameOver
        visible: false
        z: 256
        width: parent.width
        height: parent.height
        source: "../resources/game-over.png"
    }

    Image {
        id: gamePaused
        visible: false
        z: 256
        width: parent.width
        height: parent.height
        source: "../resources/game-paused.png"
    }

    Image {
        id: startImage
        width: parent.width
        height: parent.height
        source: "../resources/start.png"
    }

    Image {
        id: backgroundImage
        visible: false;
        width: parent.width
        height: parent.height
        source: "../resources/background.png"
    }

    Text {
        id: hudLevel
        font.family: fontThin.name
        visible: false
        text: "Level " + level
        color: "#ffffff"
        font.pointSize: 26
        x: 720-180
        y: (720 / 2) - 22
        width: 180
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: hudLines
        font.family: fontThin.name
        visible: false
        text: "0 lines"
        color: "#ffffff"
        font.pointSize: 26
        x: 720-180
        y: (720 / 2) + 22
        width: 180
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: hudScore
        font.family: fontThin.name
        visible: false
        text: score
        color: "#ffffff"
        font.pointSize: 26
        x: 0
        y: 720 / 2
        width: 180
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: hudHighScore
        z: 256
        font.family: fontMedium.name
        visible: true
        text: ""
        color: "#ffffff"
        font.pointSize: 16
        x: 0
        y: 720  * 0.95
        width: 720
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    function level() {
        return level
    }

    function spawnBlock() {
        var b = Common.createBlock()
        block = b
        blocks.push(b)
    }

    function pauseGame() {
        gamePaused.visible = !gamePaused.visible
        ticker.running = !ticker.running
    }

    function selectPressed() {
        if (startImage.visible == false && gameOver.visible == false) {
            pauseGame() 
        } else if (gamePaused.visible) {
            pauseGame()
        }
    }

    function startPressed() {
        if(gameOver.visible == true) {
            block.hideBlocks()
            gameOver.visible = false
            startImage.visible = true
            hudHighScore.visible = true
            backgroundImage.visible = false

            hudLines.visible = false
            hudLevel.visible = false
            hudScore.visible = false
        } else if (gamePaused.visible) {
            restartGame();
        } else if (startImage.visible == false) {          
        } else {
            hudHighScore.visible = false
            startImage.visible = false
            backgroundImage.visible = true

            level = 1
            lineCount = 0
            score = 0

            hudScore.text = score
            hudLevel.text = "Level " + level
            hudLines.text = lineCount + " lines"

            hudLines.visible = true
            hudLevel.visible = true
            hudScore.visible = true

            spawnBlock()

            ticker.running = true
        }
    }

    function rightPressed() {
        block.moveRight()
    }

    function leftPressed() {
        block.moveLeft()
    }

    function upPressed() {
        block.rotate()
    }

    function downPressed() {
        ticker.freq = 4
    }

    function downReleased() {
        ticker.freq = 60
    }

    function increaseScore(points) {
        score = score + points
        hudScore.text = score
    }

    function increaseLevel() {
        level = level + 1
        hudLevel.text = "Level " + level
    }
    
    function increaseLineCount() {
        lineCount = lineCount + 1
        hudLines.text = lineCount + " lines"
        
        if (lineCount % 10 == 0) {
            increaseLevel()
        }
    }

    function startTicker() {
        ticker.tick = ticker.freq
        ticker.running = true
    }

    function endGame() {
         gameOver.visible = true
         var highScore = dataStore.getObject("highScoreTable", "highestScore", "score");
         if ((typeof dataStore.getObject("highScoreTable", "highestScore", "score") == 'undefined' || score > highScore) && score != 0) {
            dataStore.setObject("highScoreTable", "highestScore", "level", level)
            dataStore.setObject("highScoreTable", "highestScore", "lines", lineCount)
            dataStore.setObject("highScoreTable", "highestScore", "score", score)
            updateHighScoreOnStart(true)
            hudHighScore.visible = true
         } else {
             updateHighScoreOnStart(false)
         }
    }

    function updateHighScoreOnStart(newHighScore) {
        if (typeof dataStore.getObject("highScoreTable", "highestScore", "score") == 'undefined') {
            return
        }
        var highScoreText = newHighScore ? "New High Score: " : "High Score: "
        highScoreText += dataStore.getObject("highScoreTable", "highestScore", "score")
        highScoreText += " · "
        highScoreText += dataStore.getObject("highScoreTable", "highestScore", "lines")
        highScoreText += " lines · Level "
        highScoreText += dataStore.getObject("highScoreTable", "highestScore", "level")
        hudHighScore.text = highScoreText
    }

    Timer {
        id: ticker
        running: false
        repeat: true
        interval: 1000 / 60
        property var tick: 0
        property var freq: 60
        onTriggered: {

            ticker.tick = ticker.tick + 1

            if (ticker.tick >= freq) {
                if (block.isResting()) {

                    if (block.y == 36) {
                        ticker.running = false
                        endGame()
                        return
                    }

                    ticker.running = false
                    ticker.tick = 0
                    spawnBlock()
                    ticker.running = true
                    return
                }
            }

           if (ticker.tick >= freq) {
                block.fallByOne()
                if (block.willRest())
                    if (block.flashCompletedTiles()) {
                        ticker.running = false
                        ticker.tick = 0
                    }
            }
                
            if (ticker.tick >= freq) {
                ticker.tick = 0
            } 
        }
    }
}