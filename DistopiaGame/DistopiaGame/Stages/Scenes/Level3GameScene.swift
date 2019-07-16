//
//  Level3GameScene.swift
//  DistopiaGame
//
//  Created by João Vitor Lopes Capi on 03/07/19.
//  Copyright © 2019 anthony.gianeli. All rights reserved.
//

import SpriteKit
import GameplayKit


class Level3GameScene: LevelGameScene, SKPhysicsContactDelegate{
    
    var spikes: SKSpriteNode?
    var stairs: SKSpriteNode?
    var crate: SKSpriteNode?
    var pressurePlate: SKSpriteNode?
    var door: SKSpriteNode?
    var lampLight: SKSpriteNode?
    var firstFloor: SKSpriteNode?
    var leftSecondFloor: SKSpriteNode?
    var rightSecondFloor: SKSpriteNode?
    var lastWall: SKSpriteNode?
    
    var playerIsTouchingPressurePlate = false
    var crateIsTouchingPressurePlate = false
    var isTouchingSpikes = false
    var isOnSecondFloor = false
    var isTouchingCrate = false
    var isTouchingFirstFloor = false
    
    var holdOrLeaveCrateGesture = UITapGestureRecognizer()
    
    var liftDoor = SKAction()
    var unliftDoor = SKAction()
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        moveCamera(rightScreenEdge: 1475)
//        if isMoving{
//            print(crate?.position)
//        }
//        if isPushing && (crate?.position.x)! < 0 && direction < 0 {
//            holdOrLeaveFunc()
//        }else if isPushing && (crate?.position.x)! < 0 && direction > 0{
//            holdOrLeaveFunc()
//        }
        if characterImage.position.x > (door?.frame.maxX)!  + 40 {
            restart(levelWithFileNamed: "Level2GameScene")
        }
    }
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
//        //Gestures
//        holdOrLeaveCrateGesture = UITapGestureRecognizer(target: self, action: #selector(holdOrLeaveCrate(_:)))
//        holdOrLeaveCrateGesture.numberOfTapsRequired = 1
//        holdOrLeaveCrateGesture.numberOfTouchesRequired = 1
        
        
        
        //Door Actions
        liftDoor = SKAction.moveBy(x: 0, y: 150, duration: 0.5)
        unliftDoor = SKAction.moveBy(x: 0, y: -150, duration: 0.5)
        
        
        //Scene Nodes
        self.spikes = self.childNode(withName: "spikes") as? SKSpriteNode
        self.stairs = self.childNode(withName: "stairs") as? SKSpriteNode
        self.crate = self.childNode(withName: "crate") as? SKSpriteNode
        self.pressurePlate = self.childNode(withName: "pressurePlate") as? SKSpriteNode
        self.door = self.childNode(withName: "door") as? SKSpriteNode
        self.lampLight = self.childNode(withName: "lampLight") as? SKSpriteNode
        self.firstFloor = self.childNode(withName: "floor") as? SKSpriteNode
        self.leftSecondFloor = self.childNode(withName: "leftPlataform") as? SKSpriteNode
        self.rightSecondFloor = self.childNode(withName: "rightPlataform") as?
            SKSpriteNode
        self.lastWall = self.childNode(withName: "lastWall") as? SKSpriteNode
        
        physicsWorld.contactDelegate = self
        let physicsBody =  SKPhysicsBody.init(rectangleOf: CGSize(width: 50, height: 50))
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = true
        physicsBody.allowsRotation = true
        physicsBody.pinned = false
        physicsBody.restitution = 0
        physicsBody.mass = 0.011
        physicsBody.friction = 0.01
        self.crate!.physicsBody = physicsBody
        
        super.stairHeight = (stairs?.frame.height)!
        
        //Category BitMask
        super.characterImage.physicsBody?.categoryBitMask = ColliderType.Character
        self.stairs!.physicsBody?.categoryBitMask = ColliderType.Stairs
        self.spikes!.physicsBody?.categoryBitMask = ColliderType.Spikes
        self.pressurePlate!.physicsBody?.categoryBitMask = ColliderType.PressurePlate
        self.crate!.physicsBody?.categoryBitMask = ColliderType.Crate
        self.firstFloor!.physicsBody?.categoryBitMask = ColliderType.Ground
        self.door!.physicsBody?.categoryBitMask = ColliderType.Door
        self.leftSecondFloor!.physicsBody?.categoryBitMask = ColliderType.Ground
        self.rightSecondFloor?.physicsBody?.categoryBitMask = ColliderType.Ground
        self.lastWall?.physicsBody?.categoryBitMask = ColliderType.Wall
        
        //Collision BitMask
        super.characterImage.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Crate | ColliderType.WinningFlag | ColliderType.Door | ColliderType.Wall
        self.door!.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Character | ColliderType.Crate
        self.crate!.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Character | ColliderType.Spikes
        
        //Contact BitMask
        super.characterImage.physicsBody?.contactTestBitMask = ColliderType.Spikes | ColliderType.Stairs | ColliderType.PressurePlate | ColliderType.Ground
        self.crate!.physicsBody?.contactTestBitMask = ColliderType.Character | ColliderType.PressurePlate
        
    }
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesMoved(touches, with: event)
//        for touch in touches {
//            if isCarrying && direction>0 {
//                print(1)
//                self.crate?.position =  CGPoint(x: characterImage.xScale * (self.characterImage.frame.maxX), y: characterImage.yScale * (self.characterImage.frame.minY))
//            }
//            else if isCarrying && direction<0 {
//                print(-1)
//                self.crate?.position = CGPoint(x: characterImage.xScale * (self.characterImage.frame.minX), y: characterImage.yScale * (self.characterImage.frame.minY))
//            }
//        }
//    }
    
    
    
    
    //Contact Handling
    func didBegin(_ contact: SKPhysicsContact) {
        
        if ((contact.bodyA==super.characterImage.physicsBody && contact.bodyB==self.spikes?.physicsBody) || (contact.bodyA==self.spikes?.physicsBody && contact.bodyB==super.characterImage.physicsBody)) && !isTouchingSpikes{
            isTouchingSpikes = true
            if isTouchingSpikes{
                super.restart(levelWithFileNamed: "Level3")
            }
        }
        
        
        if ((contact.bodyA==super.characterImage.physicsBody && contact.bodyB==self.pressurePlate?.physicsBody) || (contact.bodyA==self.pressurePlate?.physicsBody && contact.bodyB==super.characterImage.physicsBody)) && !playerIsTouchingPressurePlate{
            playerIsTouchingPressurePlate = true
            if playerIsTouchingPressurePlate && !crateIsTouchingPressurePlate{
                self.lampLight?.alpha = 1
                self.door?.run(liftDoor)
            }
        }
        
        if ((contact.bodyA==self.crate?.physicsBody && contact.bodyB==self.pressurePlate?.physicsBody) || (contact.bodyA==self.pressurePlate?.physicsBody && contact.bodyB==self.crate?.physicsBody)) && !crateIsTouchingPressurePlate{
            crateIsTouchingPressurePlate = true
            if crateIsTouchingPressurePlate && !playerIsTouchingPressurePlate{
                self.door?.run(liftDoor)
            }
        }
        
        if ((contact.bodyA==self.crate?.physicsBody && contact.bodyB==super.characterImage.physicsBody) || (contact.bodyA==super.characterImage.physicsBody && contact.bodyB==self.crate?.physicsBody)) && !isTouchingCrate{
            isTouchingCrate = true
            if isTouchingCrate{
                self.view?.addGestureRecognizer(holdOrLeaveCrateGesture)
            }
        }
        
        if ((contact.bodyA==super.characterImage.physicsBody && contact.bodyB==self.stairs?.physicsBody) || (contact.bodyA==self.stairs?.physicsBody &&
            contact.bodyB==super.characterImage.physicsBody)) && !isTouchingStairs{
            isTouchingStairs = true
            if isTouchingStairs{
                characterImage.physicsBody?.affectedByGravity = false
            }
        }
        
        
        if ((contact.bodyA==super.characterImage.physicsBody && contact.bodyB==self.firstFloor?.physicsBody) || (contact.bodyA==self.firstFloor?.physicsBody && contact.bodyB==super.characterImage.physicsBody)){
            super.characterImage.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Crate | ColliderType.WinningFlag | ColliderType.Door | ColliderType.Wall
            
            if isCharacterAboveStairs && !isTouchingStairs{
                restart(levelWithFileNamed: "Level3")
            }
            super.isCharacterAboveStairs = false
        }
        
    }
        
    
    func didEnd(_ contact: SKPhysicsContact) {
        
        if (contact.bodyA==super.characterImage.physicsBody && contact.bodyB==self.pressurePlate?.physicsBody) || (contact.bodyA==self.pressurePlate?.physicsBody && contact.bodyB==super.characterImage.physicsBody) && playerIsTouchingPressurePlate{
            playerIsTouchingPressurePlate = false
            self.lampLight?.alpha = 0
            
            if !playerIsTouchingPressurePlate && !crateIsTouchingPressurePlate{
                let unliftDoor = SKAction.moveBy(x: 0, y: -150, duration: 0.5)
                self.door?.run(unliftDoor)
            }
        }
        
        if (contact.bodyA==super.characterImage.physicsBody && contact.bodyB==self.stairs?.physicsBody) || (contact.bodyA==self.stairs?.physicsBody &&
            contact.bodyB==super.characterImage.physicsBody) && isTouchingStairs{
            isTouchingStairs = false
            
            if !isTouchingStairs{
                characterImage.physicsBody?.affectedByGravity = true
                
                if characterImage.position.y + characterImage.frame.height/2 >= (stairs?.position.y)! + (stairs?.size.height)!/2{
                    super.isCharacterAboveStairs = true
                    super.characterImage.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Crate | ColliderType.WinningFlag | ColliderType.Door | ColliderType.Wall | ColliderType.Stairs
                }
            }
        }
        
        if (contact.bodyA==self.crate?.physicsBody && contact.bodyB==self.pressurePlate?.physicsBody) || (contact.bodyA==self.pressurePlate?.physicsBody && contact.bodyB==self.crate?.physicsBody) && crateIsTouchingPressurePlate{
            crateIsTouchingPressurePlate = false
            
            if !crateIsTouchingPressurePlate && !playerIsTouchingPressurePlate{
                self.door?.run(unliftDoor)
            }
        }
        
        if ((contact.bodyA==self.crate?.physicsBody && contact.bodyB==super.characterImage.physicsBody) || (contact.bodyA==super.characterImage.physicsBody && contact.bodyB==self.crate?.physicsBody)) && isTouchingCrate{
            isTouchingCrate = false
            
            if !isTouchingCrate{
                self.view?.removeGestureRecognizer(holdOrLeaveCrateGesture)
            }
        }
    }
    
//    fileprivate func holdOrLeaveFunc() {
//        if !super.isPushing{
//            super.isPushing = true
//            if let crate = self.crate {
//                crate.removeFromParent()
//                self.characterImage.addChild(crate)
//
//                crate.position = CGPoint(x: 150.317, y: -82.865)
//
//
//                self.crate?.xScale = 1/characterImage.xScale
//                self.crate?.yScale = 1/characterImage.yScale
//                self.crate?.physicsBody?.pinned = true
//            }
//            if crateIsTouchingPressurePlate{
//                crateIsTouchingPressurePlate = false
//                self.door?.run(unliftDoor)
//            }
//        }
//
//        else {
//            super.isPushing = false
//            if let crate = self.crate {
//                crate.removeFromParent()
//                self.scene?.addChild(crate)
//
//                if direction<0{
//                    self.crate?.position = CGPoint(x: self.characterImage.position.x + self.characterImage.frame.width, y: characterImage.frame.midY)
//                }
//                else{
//                    self.crate?.position = CGPoint(x: self.characterImage.position.x - self.characterImage.frame.width, y: characterImage.frame.midY)
//                }
//                self.crate?.setScale(1)
//                self.crate?.physicsBody?.pinned = false
//            }
//        }
//    }
    
//    @objc func holdOrLeaveCrate(_ sender: UITapGestureRecognizer){
//
//        if (sender.location(in: view).x) > middleScreen{
//            holdOrLeaveFunc()
//        }
//    }
    
    
}
