//
//  StairsGameScene.swift
//  DistopiaGame
//
//  Created by Julia Conti Mestre on 01/07/19.
//  Copyright © 2019 anthony.gianeli. All rights reserved.
//

import SpriteKit
import GameplayKit

class Level1GameScene: SKScene {
    
    var character: SKSpriteNode?
    var fingerLocation: CGPoint!
    var firstTouch: CGPoint!
    var center: CGPoint!
    let screenSize: CGRect = UIScreen.main.bounds
    var maxDx: CGFloat!
    var isMoving = false
    
    override func didMove(to view: SKView) {
        self.character = self.childNode(withName: "character") as? SKSpriteNode
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMoving = true
        for touch in touches {
            firstTouch = touch.location(in: self)
            center = firstTouch
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            fingerLocation = touch.location(in: self)
            maxDx = screenSize.width/6
            let fingerDx = fingerLocation.x - firstTouch.x
            
            if fingerDx >= maxDx  {
                let difference = fingerDx - maxDx
                center.x = center.x + difference
            } else if fingerDx <= -maxDx {
                let difference = abs(fingerDx - maxDx)
                center.x = center.x - difference
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Stop node from moving to touch
        isMoving = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if isMoving {
            moveCharacterHorizontal()
        }
    }
    
    // Move the node to the location of the touch
    func moveCharacterHorizontal() {
        maxDx = screenSize.width/6
        // Compute vector components in direction of the touch
        var dx = fingerLocation.x - firstTouch.x
        // How fast to move the node. Adjust this as needed
        let speed: CGFloat = 0.01
        // Scale vector
        if dx >= maxDx {
            dx = maxDx
        } else if dx <= -maxDx {
            dx = -maxDx
        }
        dx = dx * speed
        character!.position = CGPoint(x: character!.position.x + dx, y: character!.position.y)
    }
    
}
