//
//  SurvivalGameMode.swift
//  TumblingTowersGame
//
//  Created by Elvis on 29/3/23.
//

import Foundation

class SurvivalGameMode: GameMode {
    let eventMgr: EventManager
    // Place N blocks wo dropping more than M blocks in shortest time possible (Score is time taken?)
    static var name = Constants.GameModeTypes.SURVIVAL.rawValue

    static var description = "Place \(blocksToPlace) blocks without dropping more than \(blocksDroppedThreshold) blocks! Score decays over time! Bonus Score Time: \(scoreTimeWithBonusScore)s"


    var realTimeTimer = GameTimer()

    // MARK: Constants for this game mode
    static let blocksToPlace = 30
    static let blocksDroppedThreshold = 3
    let scoreBlocksPlacedMultiplier = 10
    let scoreBlocksDroppedMultiplier = 25
    static let scoreTimeWithBonusScore = 90

    // MARK: Tracking State of Game
    var currBlocksInserted = 0
    var currBlocksPlaced = 0
    var currBlocksDropped = 0
    let playerId: UUID

    var isStarted = false
    var isGameEnded = false

    // MARK: Multiplayer States
    var isEndedByOtherPlayer = false
    var overwriteGameState: Constants.GameState?

    required init(eventMgr: EventManager, playerId: UUID, levelHeight: CGFloat) {
        self.eventMgr = eventMgr
        self.playerId = playerId
        
        eventMgr.registerClosure(for: BlockPlacedEvent.self, closure: blockPlaced)
        eventMgr.registerClosure(for: BlockDroppedEvent.self, closure: blockDropped)
        eventMgr.registerClosure(for: BlockInsertedEvent.self, closure: blockInserted)
    }

    func update() {
        if gameState != .RUNNING && gameState != .PAUSED {
            eventMgr.postEvent(GameEndedEvent(playerId: playerId, endState: gameState))
        }
    }

    var gameState: Constants.GameState {
        if let overwriteGameState = overwriteGameState {
            return overwriteGameState
        }

        if currBlocksDropped >= SurvivalGameMode.blocksDroppedThreshold {
            return .LOSE
        }

        if currBlocksPlaced >= SurvivalGameMode.blocksToPlace {
            return .WIN
        }

        if isStarted {
            return .RUNNING
        } else {
            return .NONE
        }
    }

    var score: Int {
        max(SurvivalGameMode.scoreTimeWithBonusScore - realTimeTimer.count
            + currBlocksPlaced * scoreBlocksPlacedMultiplier
            - currBlocksDropped * scoreBlocksDroppedMultiplier, 0)
    }

    var time: Int {
        realTimeTimer.count
    }

    func resetGame() {
        isStarted = false
        isGameEnded = false
        currBlocksInserted = 0
        currBlocksPlaced = 0
        currBlocksDropped = 0
        realTimeTimer = GameTimer()

        isEndedByOtherPlayer = false
        overwriteGameState = nil
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

        if endedBy != playerId {
            isEndedByOtherPlayer = true

            if endState == .WIN {
                overwriteGameState = .LOSE
            } else if endState == .LOSE {
                overwriteGameState = .WIN
            }

        }
    }

    var gameEndMainMessage: String {
        if gameState == .WIN {
            return Constants.defaultWinMainString
        } else if gameState == .LOSE {
            return Constants.defaultLoseMainString
        }

        return ""
    }

    var gameEndSubMessage: String {
        if gameState == .WIN {
            if isEndedByOtherPlayer {
                // Opponent dropped too many blocks out of the screen
                return "You beat your opponent!"
            } else {
                return "You stacked enough blocks!"
            }
        } else if gameState == .LOSE {
            if isEndedByOtherPlayer {
                // Opponent stacked enough blocks faster than you
                return "You opponent beat you at stacking blocks!"
            } else {
                return "You dropped too many blocks!."
            }
        }

        return ""
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

    private func blockInserted(event: Event) {
        if let insertedEvent = event as? BlockInsertedEvent, insertedEvent.playerId == playerId {
            currBlocksInserted += 1
        }
    }
}
