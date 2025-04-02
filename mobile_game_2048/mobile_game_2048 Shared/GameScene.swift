//  GameScene.swift
//  mobile_game_2048 Shared
//
//  Created by Ty Runner on 3/12/25.
//

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
    
    override func didMove(to view: SKView) {
        
        GlobalSettings.shared.setupAudio() 
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up AVAudioSession: \(error)")
        }
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = -1
        addChild(background)
        
        setupBoards()
        spawnInitialTiles()
        redrawBoards()
    }
    
    func setupBoards() {
        backgroundColor = .black
        
        let boardSpacing: CGFloat = size.width * 0.10  // Adjust for better separation
        let boardOffsetX: CGFloat = size.width * 0.3  // More space between grids
        let boardY: CGFloat = size.height * 0.5       // Centered vertically

        drawBoard(board1, at: CGPoint(x: boardOffsetX - boardSpacing, y: boardY), boardName: "board1")
        drawBoard(board2, at: CGPoint(x: size.width - boardOffsetX + boardSpacing, y: boardY), boardName: "board2")
    }

    
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
                    tileLabel.name = "\(boardName)_tile_\(row)_\(col)" // Added boardName to avoid overlap
                    boardNode.addChild(tileLabel)
                }
            }
        }
    }
    
    func spawnInitialTiles() {
        spawnTile(on: &board1)
        spawnTile(on: &board1)
        spawnTile(on: &board2)
        spawnTile(on: &board2)
    }
    
    func spawnTile(on board: inout [[Int]]) {
        let emptyTiles = board.enumerated().flatMap { row, cols in
            cols.enumerated().compactMap { col, value in value == 0 ? (row, col) : nil }
        }
        if let position = emptyTiles.randomElement() {
            board[position.0][position.1] = [2, 4].randomElement()!
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchStart = touch.location(in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchStart = touchStart, let touch = touches.first else { return }
        let touchEnd = touch.location(in: self)
        
        let dx = touchEnd.x - touchStart.x
        let dy = touchEnd.y - touchStart.y
        
        let swipeThreshold: CGFloat = 50  // Minimum movement to consider a swipe
        
        var moved = false // Track if any movement occurred
        
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
            spawnTile(on: &board1) // Spawn a new tile after a successful move
            spawnTile(on: &board2)
            redrawBoards() // Update UI after moves and merges
        }
    }

    func moveTilesLeft(on board: inout [[Int]]) {
        // Implement logic similar to moveTilesUp but for leftward movement
    }
    
    func moveTilesRight(on board: inout [[Int]]) {
        // Implement logic similar to moveTilesUp but for rightward movement
    }
    
    func moveTilesUp(on board: inout [[Int]]) {
        for col in 0..<4 {
            var merged = [false, false, false, false]  // Track merged tiles
            
            for row in 1..<4 {  // Start from the second row
                if board[row][col] != 0 {
                    var newRow = row
                    
                    // Move tile up until it reaches a non-empty tile or the top
                    while newRow > 0 && board[newRow - 1][col] == 0 {
                        board[newRow - 1][col] = board[newRow][col]
                        board[newRow][col] = 0
                        newRow -= 1
                    }
                    
                    // Merge if the tile above has the same value and wasn't already merged
                    if newRow > 0 && board[newRow - 1][col] == board[newRow][col] && !merged[newRow - 1] {
                        board[newRow - 1][col] *= 2  // Merge
                        board[newRow][col] = 0  // Clear the original tile
                        merged[newRow - 1] = true  // Mark this tile as merged
                    }
                }
            }
        }
    }

    
    func moveTilesDown(on board: inout [[Int]]) {
        for col in 0..<4 {
            var merged = [false, false, false, false]  // Track merged tiles
            
            for row in (0..<3).reversed() {  // Start from the second-to-last row
                if board[row][col] != 0 {
                    var newRow = row
                    
                    // Move tile down until it reaches a non-empty tile or the bottom
                    while newRow < 3 && board[newRow + 1][col] == 0 {
                        board[newRow + 1][col] = board[newRow][col]
                        board[newRow][col] = 0
                        newRow += 1
                    }
                    
                    // Merge if the tile below has the same value and wasn't already merged
                    if newRow < 3 && board[newRow + 1][col] == board[newRow][col] && !merged[newRow + 1] {
                        board[newRow + 1][col] *= 2  // Merge
                        board[newRow][col] = 0  // Clear the original tile
                        merged[newRow + 1] = true  // Mark this tile as merged
                    }
                }
            }
        }
    }

    
    func redrawBoards() {
        drawBoard(board1, at: CGPoint(x: size.width * 0.25, y: size.height * 0.5), boardName: "board1")
        drawBoard(board2, at: CGPoint(x: size.width * 0.75, y: size.height * 0.5), boardName: "board2")
    }
}
