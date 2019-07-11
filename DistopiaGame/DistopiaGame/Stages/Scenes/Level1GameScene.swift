//
//  StairsGameScene.swift
//  DistopiaGame
//
//  Created by Julia Conti Mestre on 01/07/19.
//  Copyright © 2019 anthony.gianeli. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Level1Colliders {
    static let None: UInt32 = 0
    static let Character: UInt32 = 1
    static let Ground: UInt32 = 2
    static let Stair: UInt32 = 4
    static let Lader1: UInt32 = 8
    static let Lader2: UInt32 = 16
}

class Level1GameScene: LevelGameScene, SKPhysicsContactDelegate {
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        moveCamera(rightScreenEdge: size.width * 2)
    }
 
}
