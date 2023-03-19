//
//  MockFiziksSceneDelegate.swift
//  TumblingTowersGameTests
//
//  Created by Taufiq Abdul Rahman on 19/3/23.
//

import Foundation

class MockFiziksSceneUpdateDelegate: FiziksSceneUpdateDelegate {
    var updatedFiziksScene: Bool = false;
    func didUpdateFiziksScene() {
        updatedFiziksScene = true;
    }
}