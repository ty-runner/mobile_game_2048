//  GameScene.swift
//  mobile_game_2048 Shared
//
//  Created by Ty Runner on 3/12/25.

import SpriteKit
import Foundation
import AVFoundation

class GameScene: SKScene {
    
    weak var viewController: GameViewController?
    
    let background = SKSpriteNode(imageNamed: "background")
    var board1: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    var board2: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    let tileSize: CGFloat = 30  // Tile size
    let spacing: CGFloat = 10   // Space between tiles
    var touchStart: CGPoint?
    var scoreRegion: ScoreRegion!
    var gameOverShown = false

    // Called when the scene is first presented. Sets up audio, boards, tiles, and UI elements.
    override func didMove(to view: SKView) {
        GlobalSettings.shared.setupAudio()

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up AVAudioSession: \(error)")
        }
        //reset score
        GameData.shared.score = 0;
        scoreRegion = ScoreRegion(score: GameData.shared.score)
        scoreRegion.position = CGPoint(x: 100, y: size.height - 50)
        scoreRegion.position = CGPoint(x: size.width / 2.2, y: size.height - 100)

        scoreRegion.name = "scoreRegion"
        addChild(scoreRegion)
        // Positioning
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = -1
        addChild(background)

        setupBoards()
        spawnInitialTiles()
        redrawBoards()

        let backButton = SKLabelNode(text: "⟵ Back")
        backButton.fontName = "AvenirNext-Bold"
        backButton.fontSize = 24
        backButton.fontColor = .white
        backButton.position = CGPoint(x: 60, y: size.height - 50)
        backButton.name = "backButton"
        backButton.zPosition = 10
        addChild(backButton)
    }

    // Called every frame. Checks if both boards are in a game over state.
    override func update(_ currentTime: TimeInterval) {
        if !gameOverShown && isGameOver(board1) && isGameOver(board2) {
            gameOverShown = true
            GameData.shared.coins += Int(Double(GameData.shared.score) * 0.01)
            GameData.shared.score = 0 //reset score
            showGameOver()
        }
    }

    // Displays the game over overlay with a message and restart option.
    func showGameOver() {
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 0.8, height: 200), cornerRadius: 20)
        overlay.fillColor = .black
        overlay.alpha = 0.8
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 100
        overlay.name = "gameOverOverlay"
        addChild(overlay)

        let gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 36
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint.zero
        gameOverLabel.zPosition = 101
        overlay.addChild(gameOverLabel)

        let restartLabel = SKLabelNode(text: "Tap to Restart")
        restartLabel.fontName = "AvenirNext-Regular"
        restartLabel.fontSize = 18
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: 0, y: -40)
        restartLabel.zPosition = 101
        restartLabel.name = "restartButton"
        overlay.addChild(restartLabel)
    }

    // Checks if a board has no valid moves left (game over condition).
    func isGameOver(_ board: [[Int]]) -> Bool {
        for row in 0..<4 {
            for col in 0..<4 {
                if board[row][col] == 0 {
                    return false
                }
                if row < 3 && board[row][col] == board[row + 1][col] {
                    return false
                }
                if col < 3 && board[row][col] == board[row][col + 1] {
                    return false
                }
            }
        }
        return true
    }

    // Initializes and draws both game boards.
    func setupBoards() {
        backgroundColor = .black
        let boardSpacing: CGFloat = size.width * 0.10
        let boardOffsetX: CGFloat = size.width * 0.3
        let boardY: CGFloat = size.height * 0.5

        drawBoard(board1, at: CGPoint(x: boardOffsetX - boardSpacing, y: boardY), boardName: "board1")
        drawBoard(board2, at: CGPoint(x: size.width - boardOffsetX + boardSpacing, y: boardY), boardName: "board2")
    }

    // Renders the given board and its tiles at a given position.
    func drawBoard(_ board: [[Int]], at position: CGPoint, boardName: String) {
        childNode(withName: boardName)?.removeFromParent()

        let boardNode = SKNode()
        boardNode.position = position
        boardNode.name = boardName
        addChild(boardNode)

        let gridSize: CGFloat = (tileSize * 4) + (spacing * 3)

        for row in 0..<4 {
            for col in 0..<4 {
                let xPos = CGFloat(col) * (tileSize + spacing) - (gridSize / 2) + (tileSize / 2)
                let yPos = CGFloat(row) * -(tileSize + spacing) + (gridSize / 2) - (tileSize / 2)

                let tileBackground = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize), cornerRadius: 8)
                tileBackground.fillColor = .darkGray
                tileBackground.strokeColor = .gray
                tileBackground.position = CGPoint(x: xPos, y: yPos)
                boardNode.addChild(tileBackground)

                if board[row][col] != 0 {
                    let tileLabel = SKLabelNode(text: "\(board[row][col])")
                    tileLabel.fontSize = 32
                    tileLabel.fontColor = .white
                    tileLabel.position = tileBackground.position
                    tileLabel.verticalAlignmentMode = .center
                    tileLabel.horizontalAlignmentMode = .center
                    tileLabel.name = "\(boardName)_tile_\(row)_\(col)"
                    boardNode.addChild(tileLabel)
                }
            }
        }
    }

    // Places two initial tiles on each board when the game starts.
    func spawnInitialTiles() {
        spawnTile(on: &board1)
        spawnTile(on: &board1)
        spawnTile(on: &board2)
        spawnTile(on: &board2)
    }

    // Randomly places a 2 or 4 tile on an empty cell in the board.
    func spawnTile(on board: inout [[Int]]) {
        let emptyTiles = board.enumerated().flatMap { row, cols in
            cols.enumerated().compactMap { col, value in value == 0 ? (row, col) : nil }
        }
        if let position = emptyTiles.randomElement() {
            board[position.0][position.1] = [2, 4].randomElement()!
        }
    }

    // Records the starting point of a touch.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchStart = touch.location(in: self)
        }
    }

    // Detects swipe gestures and button presses like restart or back.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchStart = touchStart, let touch = touches.first else { return }
        let touchEnd = touch.location(in: self)
        let dx = touchEnd.x - touchStart.x
        let dy = touchEnd.y - touchStart.y
        let swipeThreshold: CGFloat = 50

        let tappedNodes = nodes(at: touchEnd)
        for node in tappedNodes {
            if node.name == "restartButton" {
                let newScene = GameScene(size: size)
                newScene.scaleMode = scaleMode
                view?.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.5))
                return
            } else if node.name == "backButton" {
                let startScene = StartScene(size: size)
                startScene.scaleMode = scaleMode
                view?.presentScene(startScene, transition: SKTransition.fade(withDuration: 0.5))
                return
            }
        }

        var moved = false
        if abs(dx) > abs(dy) {
            if dx > swipeThreshold {
                moveTilesRight(on: &board1)
                moveTilesRight(on: &board2)
                moved = true
            } else if dx < -swipeThreshold {
                moveTilesLeft(on: &board1)
                moveTilesLeft(on: &board2)
                moved = true
            }
        } else {
            if dy > swipeThreshold {
                moveTilesUp(on: &board1)
                moveTilesUp(on: &board2)
                moved = true
            } else if dy < -swipeThreshold {
                moveTilesDown(on: &board1)
                moveTilesDown(on: &board2)
                moved = true
            }
        }

        if moved {
            spawnTile(on: &board1)
            spawnTile(on: &board2)
            redrawBoards()
        }
    }

    // Moves all tiles to the left and merges matching ones.
    func moveTilesLeft(on board: inout [[Int]]) {
        for row in 0..<4 {
            var merged = [false, false, false, false]
            for col in 1..<4 {
                if board[row][col] != 0 {
                    var newCol = col
                    while newCol > 0 && board[row][newCol - 1] == 0 {
                        board[row][newCol - 1] = board[row][newCol]
                        board[row][newCol] = 0
                        newCol -= 1
                    }
                    if newCol > 0 && board[row][newCol - 1] == board[row][newCol] && !merged[newCol - 1] {
                        board[row][newCol - 1] *= 2
                        scoreRegion.updateScore(to: GameData.shared.score + board[row][newCol-1])
                        board[row][newCol] = 0
                        merged[newCol - 1] = true
                    }
                }
            }
        }
    }

    // Moves all tiles to the right and merges matching ones.
    func moveTilesRight(on board: inout [[Int]]) {
        for row in 0..<4 {
            var merged = [false, false, false, false]
            for col in (0..<3).reversed() {
                if board[row][col] != 0 {
                    var newCol = col
                    while newCol < 3 && board[row][newCol + 1] == 0 {
                        board[row][newCol + 1] = board[row][newCol]
                        board[row][newCol] = 0
                        newCol += 1
                    }
                    if newCol < 3 && board[row][newCol + 1] == board[row][newCol] && !merged[newCol + 1] {
                        board[row][newCol + 1] *= 2
                        scoreRegion.updateScore(to: GameData.shared.score + board[row][newCol+1])
                        board[row][newCol] = 0
                        merged[newCol + 1] = true
                    }
                }
            }
        }
    }

    // Moves all tiles upward and merges matching ones.
    func moveTilesUp(on board: inout [[Int]]) {
        for col in 0..<4 {
            var merged = [false, false, false, false]
            for row in 1..<4 {
                if board[row][col] != 0 {
                    var newRow = row
                    while newRow > 0 && board[newRow - 1][col] == 0 {
                        board[newRow - 1][col] = board[newRow][col]
                        board[newRow][col] = 0
                        newRow -= 1
                    }
                    if newRow > 0 && board[newRow - 1][col] == board[newRow][col] && !merged[newRow - 1] {
                        board[newRow - 1][col] *= 2
                        scoreRegion.updateScore(to: GameData.shared.score + board[newRow-1][col])
                        board[newRow][col] = 0
                        merged[newRow - 1] = true
                    }
                }
            }
        }
    }

    // Moves all tiles downward and merges matching ones.
    func moveTilesDown(on board: inout [[Int]]) {
        for col in 0..<4 {
            var merged = [false, false, false, false]
            for row in (0..<3).reversed() {
                if board[row][col] != 0 {
                    var newRow = row
                    while newRow < 3 && board[newRow + 1][col] == 0 {
                        board[newRow + 1][col] = board[newRow][col]
                        board[newRow][col] = 0
                        newRow += 1
                    }
                    if newRow < 3 && board[newRow + 1][col] == board[newRow][col] && !merged[newRow + 1] {
                        board[newRow + 1][col] *= 2
                        scoreRegion.updateScore(to: GameData.shared.score + board[newRow+1][col])
                        board[newRow][col] = 0
                        merged[newRow + 1] = true
                    }
                }
            }
        }
    }

    // Redraws both boards after a move to reflect the current state.
    func redrawBoards() {
        drawBoard(board1, at: CGPoint(x: size.width * 0.25, y: size.height * 0.5), boardName: "board1")
        drawBoard(board2, at: CGPoint(x: size.width * 0.75, y: size.height * 0.5), boardName: "board2")
    }
}
