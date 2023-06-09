//
//  MainGameManager.swift
//  Gyro
//
//  Created by Elvis on 11/3/23.
//

import Foundation

class MainGameManager: ObservableObject {
    var storageManager = StorageManager()

    var deviceHeight: CGFloat = 1_920
    var deviceWidth: CGFloat = 1_080

    private var eventManager: EventManager?

    var gameEngineMgrs: [GameInstanceController] = []

    var playersMode: PlayersMode?

    var inputSystem = Constants.GameInputTypes.GYRO

    var gameMode: Constants.GameModeTypes?

    func createGameInstanceController(height: CGFloat, width: CGFloat) -> GameInstanceController {
        if eventManager == nil {
            eventManager = TumblingTowersEventManager()
        }

        guard let eventManager = eventManager else {
            assert(false)
        }

        SoundSystem.shared.registerSoundEvents(eventMgr: eventManager)

        var inputClass: InputSystem.Type = TapInput.self

        if playersMode == .singleplayer {
            inputClass = Constants.getGameInputType(fromGameInputType: inputSystem) ?? GyroInput.self
        }

        let gameEngineMgr = GameInstanceController(levelDimensions: CGRect(x: 0,
                                                                           y: 0,
                                                                           width: width,
                                                                           height: height),
                                                   eventManager: eventManager,
                                                   inputType: inputClass,
                                                   storageManager: storageManager,
                                                   playersMode: playersMode)
        self.gameEngineMgrs.append(gameEngineMgr)
        self.eventManager = eventManager

        eventManager.registerClosure(for: GameEndedEvent.self, closure: refresh)

        return gameEngineMgr
    }

    func changeInput(to inputType: Constants.GameInputTypes) {
        inputSystem = inputType
    }

    func countGEM() -> Bool {
        true
    }

    func pauseGame() {
        for gameEngineMgr in gameEngineMgrs {
            gameEngineMgr.pause()
        }
    }

    func unpauseGame() {
        for gameEngineMgr in gameEngineMgrs {
            gameEngineMgr.unpause()
        }
    }

    func refresh(event: Event) {
        objectWillChange.send()
    }

    func stopGames() {
        gameEngineMgrs.forEach({ $0.stopGame() })
    }

    func resetGames() {
        gameEngineMgrs.forEach({ $0.resetGame() })
    }

    func removeAllGameEngineMgrs() {
        for gameEngineMgr in gameEngineMgrs {
            gameEngineMgr.eventManager?.removeAllClosures()
        }

        gameEngineMgrs.removeAll()
    }
}
