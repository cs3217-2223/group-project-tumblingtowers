//
//  RaceTimeGameMode.swift
//  TumblingTowersGame
//
//  Created by Elvis on 29/3/23.
//

import Foundation

class RaceTimeGameMode: GameMode {

    static var name = Constants.GameModeTypes.RACECLOCK.rawValue
    static var description = "Place \(blocksToPlace) blocks in \(timeToPlaceBy) seconds!"

    var realTimeTimer = GameTimer()
    var eventMgr: EventManager

    // MARK: Constants for this game mode
    static let blocksToPlace = 30
    static let timeToPlaceBy = 30
    let scoreTimeLeftMultiplier = 10
    let scoreBlocksPlacedMultiplier = 10
    let scoreBlocksDroppedMultiplier = 25

    // MARK: Tracking State of Game
    var currBlocksPlaced = 0
    var currBlocksDropped = 0
    let playerId: UUID

    var isStarted = false
    var isGameEnded = false

    // MARK: Multiplayer States
    var isEndedByOtherPlayer = false
    var overwriteGameState: Constants.GameState?
    var otherPlayerRanOutOfTime = false

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
        if let overwriteGameState = overwriteGameState {
            return overwriteGameState
        }

        if currBlocksPlaced >= RaceTimeGameMode.blocksToPlace {
            return .WIN
        } else if realTimeTimer.count <= 0 {
            return .LOSE
        }

        if isStarted {
            return .RUNNING
        } else {
            return .NONE
        }
    }

    func getScore() -> Int {
        max(realTimeTimer.count * scoreTimeLeftMultiplier
            + currBlocksPlaced * scoreBlocksPlacedMultiplier
            - currBlocksDropped * scoreBlocksDroppedMultiplier, 0)
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
        currBlocksPlaced = 0
        currBlocksDropped = 0
        realTimeTimer = GameTimer()

        isEndedByOtherPlayer = false
        overwriteGameState = nil
        otherPlayerRanOutOfTime = false
    }

    func startGame() {
        isStarted = true
        realTimeTimer.start(timeInSeconds: RaceTimeGameMode.timeToPlaceBy, countsUp: false)
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
                otherPlayerRanOutOfTime = false
            } else if endState == .LOSE {
                overwriteGameState = .LOSE
                otherPlayerRanOutOfTime = true
            }

        }
    }

    func getGameEndMainMessage() -> String {
        if getGameState() == .WIN {
            return Constants.defaultWinMainString
        } else if getGameState() == .LOSE {
            return Constants.defaultLoseMainString
        }

        return ""
    }

    func getGameEndSubMessage() -> String {
        if getGameState() == .WIN {
            return "You beat the clock!"
        } else if getGameState() == .LOSE {
            if isEndedByOtherPlayer {
                if otherPlayerRanOutOfTime {
                    // Other player ran out of time
                    return "You ran out of time!."
                } else {
                    // Other player stacked enough blocks faster
                    return "You were too slow!."
                }
            } else {
                return "You ran out of time!."
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
}
