//
//  GyroInput.swift
//  Gyro
//
//  Created by Elvis on 13/3/23.
//

import Foundation
import CoreMotion

class GyroInput: InputSystem {
    static var description = """
Tilt Left / Right: Moves the block in the tilted direction.
Swipe Down: Speeds up the downward movement of the block.
"""

    private weak var mainGameMgr: MainGameManager?

    private var motionManager: CMMotionManager

    private var inputVal = InputType.NONE

    private var inputData = InputData.none

    private var yMultiplier: Double = 5.0

    private let sensitivity: Double = 5

    required init() {
        motionManager = CMMotionManager()

        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates()
        }

        if motionManager.isGyroAvailable {
            motionManager.startGyroUpdates()
        }

        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates()
        }
    }

    func calculateInput() -> InputData {

        if let rate = motionManager.accelerometerData?.acceleration.x {
            // prioritise down input
            if inputData.inputType != .NONE {
                return inputData
            } else if rate > 0.1 {
                // If want constant rate
                return InputData(inputType: .RIGHT, vector: CGVector(dx: rate * sensitivity, dy: 0))
            } else if rate < -0.1 {
                // If want constant rate
                return InputData(inputType: .LEFT, vector: CGVector(dx: rate * sensitivity, dy: 0))
            }
        }
        return InputData.none
    }

    func dragEvent(offset: CGSize) {
        if offset.height < 0 {
            // detected as a swipe down
            inputData = InputData(inputType: .DOWN, vector: InputData.unitDown * yMultiplier)
        }
    }

    func resetInput() {
        inputData = .none
    }
}
