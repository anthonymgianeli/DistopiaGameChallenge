//
//  StairsGameScene.swift
//  DistopiaGame
//
//  Created by Julia Conti Mestre on 01/07/19.
//  Copyright © 2019 anthony.gianeli. All rights reserved.
//

import SpriteKit
import GameplayKit

class StairsGameScene: SKScene {
    
    var character: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        self.character = self.childNode(withName: "character") as? SKSpriteNode
        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(moveRight(_:)))
//        swipeRight.direction = .right
//        view.addGestureRecognizer(swipeRight)
//
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(moveLeft(_:)))
//        swipeLeft.direction = .left
//        view.addGestureRecognizer(swipeLeft)
    }
    
//    @objc func moveRight(_ sender: UISwipeGestureRecognizer) {
//        character?.run(SKAction.moveBy(x: 50, y: 0, duration: 0.5))
//    }
//
//    @objc func moveLeft(_ sender: UISwipeGestureRecognizer) {
//        character?.run(SKAction.moveBy(x: -10, y: 0, duration: 0.5))
//    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }

}
