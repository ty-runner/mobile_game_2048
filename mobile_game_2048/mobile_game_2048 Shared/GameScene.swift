//  GameScene.swift
//  mobile_game_2048 Shared
//
//  Created by Ty Runner on 3/12/25.

import SpriteKit
import Foundation
import AVFoundation
import GoogleMobileAds

class GameScene: SKScene {
    
    weak var viewController: GameViewController?

    var board1: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    var board2: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    let tileSize: CGFloat = 60  // Tile size
    let spacing: CGFloat = 10   // Space between tiles
    var touchStart: CGPoint?
    var scoreRegion: ScoreRegion!
    var highScoreLabel: SKLabelNode! // Add this line
    var gameOverShown = false
    
    var watchAD: SKSpriteNode!
    var ReviveTitle: SKLabelNode!
    var countdownLabel: SKLabelNode!
    
    var RestartGame: SKNode?
    
    var countdownTimer: Timer?
    var countdownTime = 10
    var videoNode: SKVideoNode?
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

            // Reset current score for new game
            GameData.shared.score = 0

            // Setup ScoreRegion
            scoreRegion = ScoreRegion(score: GameData.shared.score)
            scoreRegion.position = CGPoint(x: size.width / 2.2, y: size.height - 140)
            scoreRegion.name = "scoreRegion"
            addChild(scoreRegion)

            // High score label
            highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            highScoreLabel.fontSize = 24
            highScoreLabel.fontColor = .white
            highScoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - 100)
            highScoreLabel.zPosition = 10
            addChild(highScoreLabel)

            // Load CloudKit data asynchronously
            Task {
                do {
                    try await CloudKitManager.shared.loadStatsIntoGameData()
                    await MainActor.run {
                        self.highScoreLabel.text = "HIGHSCORE: \(GameData.shared.highscore)"
                    }
                } catch {
                    print("Failed to load player data from CloudKit: \(error.localizedDescription)")
                    await MainActor.run {
                        self.highScoreLabel.text = "HIGHSCORE: 0"
                    }
                }
            }

            // Setup boards and spawn tiles
            setupBoards()
            spawnInitialTiles()
            redrawBoards()
        
        // 🔙 Global overlay back button (safe-area aware, consistent across scenes)
        if let vc = viewController {
            GlobalSettings.shared.showOverlayBackButton(in: vc, title: "Back") { [weak self] in
                guard let self, let vc = self.viewController else { return }
                let start = StartScene(size: self.size)
                start.viewController = vc
                start.scaleMode = self.scaleMode
                let t = SKTransition.fade(withDuration: 0.5)
                vc.presentScene(start, transition: t, transitionDuration: 0.5)
            }
        }

            // Setup background video
            let selectedVideoName = ThemeManager.selectedVideo
            Task { [weak self] in
                guard let self = self else { return }
                self.videoNode = await VideoHelper.playBackgroundVideo(on: self, named: selectedVideoName)
                if self.videoNode == nil {
                    let staticBackground = SKSpriteNode(imageNamed: selectedVideoName)
                    staticBackground.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
                    staticBackground.size = self.size
                    staticBackground.zPosition = -1
                    self.addChild(staticBackground)
                }
            }
        }

    // Called every frame. Checks if both boards are in a game over state.
    override func update(_ currentTime: TimeInterval) {
        if !gameOverShown && isGameOver(board1) && isGameOver(board2) {
            gameOverShown = true
            // Add coins based on final score
            let coinsEarned = Int(Double(GameData.shared.score) * 0.01)
            GameData.shared.coins += coinsEarned
            
            // Persist new coins + score to CloudKit
            Task {
                // Update high score if the current score is higher
                await CloudKitManager.shared.updateHighScoreIfNeeded(GameData.shared.score)
                await CloudKitManager.shared.saveAllFromGameData()
                
                await MainActor.run {
                    self.highScoreLabel.text = "HIGHSCORE: \(GameData.shared.highscore)"
                }
            }
            showGameOver()
        }
    }
    
    //KEEP FUNCTION FOR SKELETON GAME SET UP
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
        gameOverLabel.position = CGPoint(x: 0, y: 50)
        gameOverLabel.zPosition = 101
        overlay.addChild(gameOverLabel)
        
        let restartLabel = SKLabelNode(text: "Tap to Restart")
        restartLabel.fontName = "AvenirNext-Regular"
        restartLabel.fontSize = 18
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: 0, y: 10)
        restartLabel.zPosition = 101
        restartLabel.name = "restartButton"
        overlay.addChild(restartLabel)
        
        // Create the "watchAD" button
        watchAD = SKSpriteNode(imageNamed: "WatchAd.png")
        watchAD.size = CGSize(width: 75, height: 50)
        watchAD.position = CGPoint(x: 0, y: -60) // Adjust position as needed
        watchAD.name = "watchAD"
        watchAD.zPosition = 101
        overlay.addChild(watchAD)
        
        ReviveTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        ReviveTitle.text = "Revive?"
        ReviveTitle.position = CGPoint(x: -10, y: -30)
        ReviveTitle.fontSize = 16
        ReviveTitle.fontColor = .white
        ReviveTitle.zPosition = 101
        overlay.addChild(ReviveTitle)
        
        countdownLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        countdownLabel.text = "\(countdownTime)"
        countdownLabel.position = CGPoint(x: 30, y: -30) // Adjust position as needed
        countdownLabel.fontSize = 16
        countdownLabel.fontColor = .white
        countdownLabel.zPosition = 101
        overlay.addChild(countdownLabel)
        
        startCountdown()
        
        RestartGame = overlay
        
    }
    
    //KEEP FUNCTION FOR SKELETON GAME SETUP
    func startCountdown() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    //KEEP FUNCTION FOR SKELETON GAME SETUP
    @objc func updateCountdown() {
        countdownTime -= 1
        countdownLabel.text = "\(countdownTime)"
        
        // Disable the "watchAD" button if the countdown reaches 0
        if countdownTime <= 0 {
            countdownTimer?.invalidate() // Stop the timer
            countdownTimer = nil
            watchAD.removeFromParent()
            ReviveTitle.removeFromParent()
            countdownLabel.removeFromParent()
        }
    }
    
    //KEEP FUNCTION FOR SKELETON GAME SETUP
    // Call this function when the user presses the button for a rewarded ad
    func showRewardedAdButtonPressed(completion: @escaping () -> Void) {
        print("THE AD IS BEING SHOWN")
        if let vc = viewController {
            vc.showRewardedAd(completion: {
                
                completion()
            })
        } else {
            print("viewController is nil")
        }
    }
    
    var tileNodes: [[SKLabelNode?]] = Array(
        repeating: Array(repeating: nil, count: 4),
        count: 4
    )
    func reviveBoard1() {
        // 1. Get highest value from board2
        let maxValue = board1.flatMap { $0 }.max() ?? 0

        // 2. Clear the entire board2
        board1 = Array(repeating: Array(repeating: 0, count: 4), count: 4)

        // 3. Place the max value into a random tile
        let randomRow = Int.random(in: 0..<4)
        let randomCol = Int.random(in: 0..<4)
        board1[randomRow][randomCol] = maxValue
        
        //4.redraw the boards
        redrawBoards()

        // 5. Allow game to continue
        gameOverShown = false
    }

    
    func reviveBoard2() {
        // 1. Get highest value from board2
        let maxValue = board2.flatMap { $0 }.max() ?? 0

        // 2. Clear the entire board2
        board2 = Array(repeating: Array(repeating: 0, count: 4), count: 4)

        // 3. Place the max value into a random tile
        let randomRow = Int.random(in: 0..<4)
        let randomCol = Int.random(in: 0..<4)
        board2[randomRow][randomCol] = maxValue
        
        //4.redraw the boards
        redrawBoards()

        // 5. Allow game to continue
        gameOverShown = false
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
        let boardSpacing: CGFloat = 30 // Spacing between the two boards
        let boardX: CGFloat = size.width * 0.5
        let board1Y: CGFloat = size.height * 0.29 // Adjusted y-position for board 1
        let board2Y: CGFloat = board1Y + (tileSize * 4 + spacing * 3) + boardSpacing // Position board 2 above board 1
        
        drawBoard(board1, at: CGPoint(x: boardX, y: board1Y), boardName: "board1")
        drawBoard(board2, at: CGPoint(x: boardX, y: board2Y), boardName: "board2")
    }
    func countDigits(of number: Int) -> Int {
        let absNumber = abs(number)  // Handle negative numbers
        return max(1, Int(log10(Double(absNumber == 0 ? 1 : absNumber))) + 1)
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
                //tileBackground.fillColor = .darkGray
                tileBackground.fillColor = colorForValue(board[row][col])
                tileBackground.strokeColor = .gray
                
                tileBackground.position = CGPoint(x: xPos, y: yPos)
                boardNode.addChild(tileBackground)
                
                if board[row][col] != 0 {
                    let tileLabel = SKLabelNode(text: "\(board[row][col])")
                    tileLabel.fontName = "AvenirNext-Bold"
                    let digits = countDigits(of: board[row][col])
                    let fontSize = max(20, 36 - 4 * (digits - 1))  // Clamp to 24 min
                    tileLabel.fontSize = CGFloat(fontSize)
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
    func colorForValue(_ value: Int) -> UIColor {
        let packageName = ThemeManager.selectedPackage
        let package = colorPackages[packageName] ?? colorPackages["classic"]!
        return package[value] ?? UIColor.lightGray
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
    
    
    //Can Keep for Skeleton Game Set up
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
                // Restart game → reset score
                GameData.shared.score = 0
                scoreRegion.updateScore(to: 0)
                
                let newScene = GameScene(size: size)
                newScene.viewController = self.viewController //NECESSARY TO RESET VIEW CONTROLLER ANYTIME TRANSITIONING FROM SCENES FOR ADS
                newScene.scaleMode = scaleMode
                view?.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.5))
                return
            } else if let spriteNode = node as? SKSpriteNode {
                if spriteNode.name == "watchAD", countdownTime > 0 {
                    self.viewController?.showRewardedAd {
                        print(" Ad watched")
                        self.RestartGame?.removeFromParent()
                        self.reviveBoard1()
                        self.reviveBoard2()
                        self.countdownTimer?.invalidate()
                        self.countdownTime = 10

                    }
                }
            }
            
        }

        
        //NOT NECESSARY FOR SKELETON GAME
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
            let boardSpacing: CGFloat = 30 // This must match the spacing in setupBoards()
            let boardX: CGFloat = size.width * 0.5
            let board1Y: CGFloat = size.height * 0.29
            let board2Y: CGFloat = board1Y + (tileSize * 4 + spacing * 3) + boardSpacing
            
            drawBoard(board1, at: CGPoint(x: boardX, y: board1Y), boardName: "board1")
            drawBoard(board2, at: CGPoint(x: boardX, y: board2Y), boardName: "board2")
        }
    }
