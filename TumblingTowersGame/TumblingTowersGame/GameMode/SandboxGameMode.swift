//
//  SandboxGameMode.swift
//  TumblingTowersGame
//
//  Created by Elvis on 2/4/23.
//

import Foundation

class SandboxGameMode: GameMode {

    static var name = Constants.GameModeTypes.SANDBOX.rawValue
    static var description = "A chill, infinite game mode for you to do anything you want. Get creative!"

    var realTimeTimer = GameTimer()
    var eventMgr: EventManager

    // MARK: Constants for this game mode
    let scoreBlocksPlacedMultiplier = 10
    let scoreBlocksDroppedMultiplier = 25
    
    // MARK: Tracking State of Game
    var currBlocksPlaced = 0
    var currBlocksDropped = 0
    let playerId: UUID

    var isStarted = false
    var isGameEnded = false

    required init(eventMgr: EventManager, playerId: UUID) {
        self.eventMgr = eventMgr
        self.playerId = playerId

        // Register all events that affect game state
        eventMgr.registerClosure(for: BlockPlacedEvent.self, closure: blockPlaced)
        eventMgr.registerClosure(for: BlockDroppedEvent.self, closure: blockDropped)
    }

    func update() {
        let gameState = getGameState()

        if gameState != .RUNNING && gameState != .PAUSED {
            eventMgr.postEvent(GameEndedEvent(playerId: playerId, endState: getGameState()))
        }
    }

    func getGameState() -> Constants.GameState {
        if isStarted {
            return .RUNNING
        } else {
            return .NONE
        }
    }

    func getScore() -> Int {
        currBlocksPlaced * scoreBlocksPlacedMultiplier
        - currBlocksDropped * scoreBlocksDroppedMultiplier
    }

    func hasGameEnded() -> Bool {
        isGameEnded
    }

    func getTime() -> Int {
        realTimeTimer.count
    }

    func resetGame() {
        isStarted = false
        isGameEnded = false
        realTimeTimer = GameTimer()
    }

    func startGame() {
        isStarted = true
        realTimeTimer.start(timeInSeconds: 0, countsUp: true)
    }

    func pauseGame() {
        realTimeTimer.pause()
    }

    func resumeGame() {
        realTimeTimer.resume()
    }

    func endGame(endedBy: UUID, endState: Constants.GameState) {
        isGameEnded = true
        realTimeTimer.stop()
    }

    func getGameEndMainMessage() -> String {
        "Thank you for playing!"
    }

    func getGameEndSubMessage() -> String {
        "Please Try Again!"
    }

    private func blockPlaced(event: Event) {
        if let placedEvent = event as? BlockPlacedEvent, placedEvent.playerId == playerId {
            currBlocksPlaced = placedEvent.totalBlocksInLevel
        }
    }

    private func blockDropped(event: Event) {
        if let droppedEvent = event as? BlockDroppedEvent, droppedEvent.playerId == playerId {
            currBlocksDropped += 1
        }
    }

}
