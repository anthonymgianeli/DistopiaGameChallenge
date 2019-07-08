//
//  Level3GameScene.swift
//  DistopiaGame
//
//  Created by João Vitor Lopes Capi on 03/07/19.
//  Copyright © 2019 anthony.gianeli. All rights reserved.
//

import SpriteKit
import GameplayKit

struct ColliderType {
    static let None: UInt32 = 0
    static let Character: UInt32 = 1
    static let Crate: UInt32 = 2
    static let Ground: UInt32 = 4
    static let Stairs: UInt32 = 8
    static let Spikes: UInt32 = 16
    static let PressurePlate: UInt32 = 32
    static let Door: UInt32 = 64
}

class Level3GameScene: SKScene, SKPhysicsContactDelegate {
    
    var character: SKSpriteNode?
    var spikes: SKSpriteNode?
    var stairs: SKSpriteNode?
    var crate: SKSpriteNode?
    var pressurePlate: SKSpriteNode?
    var door: SKSpriteNode?
    var lampLight: SKSpriteNode?
    
    var movingTouch: CGPoint!
    var firstTouch: CGPoint!
    var movingCenter: CGPoint!
    var movimentConstant: CGFloat = 50
    let screenSize: CGRect = UIScreen.main.bounds
    
    var playerIsTouchingPressurePlate = false
    var crateIsTouchingPressurePlate = false
    var isTouchingSpikes = false
    var isTouchingStairs = false
    var isTouchingCrate = false
    
    
    override func didMove(to view: SKView) {
        self.character = self.childNode(withName: "character") as? SKSpriteNode
        self.spikes = self.childNode(withName: "spikes") as? SKSpriteNode
        self.stairs = self.childNode(withName: "stairs") as? SKSpriteNode
        self.crate = self.childNode(withName: "crate") as? SKSpriteNode
        self.pressurePlate = self.childNode(withName: "pressurePlate") as? SKSpriteNode
        self.door = self.childNode(withName: "door") as? SKSpriteNode
        self.lampLight = self.childNode(withName: "lampLight") as? SKSpriteNode
        
        physicsWorld.contactDelegate = self
        
        let jumpGesture = UISwipeGestureRecognizer(target: self, action: #selector(goUp(_:)))
        jumpGesture.direction = .up
        view.addGestureRecognizer(jumpGesture)
        
        //Category BitMask
        self.character!.physicsBody?.categoryBitMask = ColliderType.Character
        self.stairs!.physicsBody?.categoryBitMask = ColliderType.Stairs
        self.spikes!.physicsBody?.categoryBitMask = ColliderType.Spikes
        self.pressurePlate!.physicsBody?.categoryBitMask = ColliderType.PressurePlate
        self.crate!.physicsBody?.categoryBitMask = ColliderType.Crate
        
        //Collision BitMask
        self.character!.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Crate
        self.door!.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Character | ColliderType.Crate
        self.crate!.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Character
        
        //Contact BitMask
        self.character!.physicsBody?.contactTestBitMask = ColliderType.Spikes | ColliderType.Stairs | ColliderType.PressurePlate
        self.crate!.physicsBody?.contactTestBitMask = ColliderType.Character | ColliderType.PressurePlate
        
        
        //self.character?.physicsBody?.applyForce(CGVector(dx: 100, dy: 0))
        
    }
    
    var count = 0
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        if ((contact.bodyA==self.character?.physicsBody && contact.bodyB==self.spikes?.physicsBody) || (contact.bodyA==self.spikes?.physicsBody && contact.bodyB==self.character?.physicsBody)) && !isTouchingSpikes{
            
            isTouchingSpikes = true
            
            if isTouchingSpikes{
                //Restart level
                if let view = self.view as! SKView? {
                    // Load the SKScene from 'GameScene.sks'
                    if let scene = SKScene(fileNamed: "Level3") {
                        // Set the scale mode to scale to fit the window
                        scene.scaleMode = .aspectFill
                        let animation = SKTransition.fade(withDuration: 1.0)
                        // Present the scene
                        view.presentScene(scene, transition: animation)
                    }
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
        
        
        if ((contact.bodyA==self.character?.physicsBody && contact.bodyB==self.pressurePlate?.physicsBody) || (contact.bodyA==self.pressurePlate?.physicsBody && contact.bodyB==self.character?.physicsBody)) && !playerIsTouchingPressurePlate{
            
            playerIsTouchingPressurePlate = true
            let liftDoor = SKAction.moveBy(x: 0, y: 150, duration: 0.5)
            
            if playerIsTouchingPressurePlate{
                self.lampLight?.alpha = 1
                self.door?.run(liftDoor)
            }
        }
        
        if ((contact.bodyA==self.character?.physicsBody && contact.bodyB==self.stairs?.physicsBody) || (contact.bodyA==self.stairs?.physicsBody &&
            contact.bodyB==self.character?.physicsBody)) && !isTouchingStairs{
            isTouchingStairs = true
            
            if isTouchingStairs{
                
                character?.physicsBody?.affectedByGravity = false
            }
        }
        
        if ((contact.bodyA==self.crate?.physicsBody && contact.bodyB==self.pressurePlate?.physicsBody) || (contact.bodyA==self.pressurePlate?.physicsBody && contact.bodyB==self.crate?.physicsBody)) && !crateIsTouchingPressurePlate{
            
            crateIsTouchingPressurePlate = true
            let liftDoor = SKAction.moveBy(x: 0, y: 150, duration: 0.5)
            
            if crateIsTouchingPressurePlate{
                self.door?.run(liftDoor)
            }
        }
        
        if ((contact.bodyA==self.crate?.physicsBody && contact.bodyB==self.character?.physicsBody) || (contact.bodyA==self.character?.physicsBody && contact.bodyB==self.crate?.physicsBody)) && !isTouchingCrate{
            
            isTouchingCrate = true
            
            if isTouchingCrate{
                let holdCrateGesture = UILongPressGestureRecognizer(target: self, action: #selector(holdCrate(_:)))
                view?.addGestureRecognizer(holdCrateGesture)
                print("Aqui ele segura a caixa (anexar 2 spriteNodes talvez?)")
            }
        }
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
//        if (contact.bodyA==self.character?.physicsBody && contact.bodyB==self.spikes?.physicsBody) || (contact.bodyA==self.spikes?.physicsBody && contact.bodyB==self.character?.physicsBody) && isTouchingSpikes == false{
//            isTouchingSpikes = false
//            if isTouchingSpikes{
//                print("Devia morrer")
//            }
//        }
        
        if (contact.bodyA==self.character?.physicsBody && contact.bodyB==self.pressurePlate?.physicsBody) || (contact.bodyA==self.pressurePlate?.physicsBody && contact.bodyB==self.character?.physicsBody) && playerIsTouchingPressurePlate{
            playerIsTouchingPressurePlate = false
            if !playerIsTouchingPressurePlate{
                let unliftDoor = SKAction.moveBy(x: 0, y: -150, duration: 0.5)
                
                self.lampLight?.alpha = 0
                self.door?.run(unliftDoor)
            }
        }
        
        if (contact.bodyA==self.character?.physicsBody && contact.bodyB==self.stairs?.physicsBody) || (contact.bodyA==self.stairs?.physicsBody &&
            contact.bodyB==self.character?.physicsBody) && isTouchingStairs{
            isTouchingStairs = false
            if !isTouchingStairs{
                
//                view!.removeGestureRecognizer(climbStairsGesture)
//                view!.addGestureRecognizer(jumpGesture)
                character?.physicsBody?.affectedByGravity = true
            }
        }
        
        if (contact.bodyA==self.crate?.physicsBody && contact.bodyB==self.pressurePlate?.physicsBody) || (contact.bodyA==self.pressurePlate?.physicsBody && contact.bodyB==self.crate?.physicsBody) && crateIsTouchingPressurePlate{
            
            crateIsTouchingPressurePlate = false
            if !crateIsTouchingPressurePlate{
                let unliftDoor = SKAction.moveBy(x: 0, y: -150, duration: 0.5)
                
                self.door?.run(unliftDoor)
            }
        }
        
        if ((contact.bodyA==self.crate?.physicsBody && contact.bodyB==self.character?.physicsBody) || (contact.bodyA==self.character?.physicsBody && contact.bodyB==self.crate?.physicsBody)) && isTouchingCrate{
            
            isTouchingCrate = false
            
            if !isTouchingCrate{
                print("Aqui é quando ele perde o contato com a caixa, se funcionar o print o de hj ta pago")
            }
        }
        
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            firstTouch = touch.location(in: self)
            movingCenter = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            movingTouch = touch.location(in: self)
            
            if Double(movingTouch.x) > Double(movingCenter.x) {
                moveRight()
                movingCenter.x = movingTouch.x - 0.1
            } else if Double(movingTouch.x) < Double(movingCenter.x) {
                moveLeft()
                movingCenter.x = movingTouch.x + 0.1
            }
        }
    }
    
    func moveRight() {
        let maxFingerMoviment = screenSize.width/4
        let fingerDistance = movingTouch.x - movingCenter.x
        let velocityConstant = fingerDistance/maxFingerMoviment
        
        let moveRight = SKAction.moveBy(x: movimentConstant * velocityConstant, y: 0, duration: 0.5)
        character?.run(moveRight)
    }
    
    func moveLeft() {
        let moveLeft = SKAction.moveBy(x: -movimentConstant, y: 0, duration: 1)
        character?.run(moveLeft)
    }
     
    
    @objc func goUp(_ sender: UISwipeGestureRecognizer) {
        if !isTouchingStairs{
            let jump = SKAction.moveBy(x: 0, y: 200, duration: 1)
            character?.run(jump)
        }
        else{
            let maxFingerMoviment = screenSize.height/4
            let fingerDistance = movingTouch.y - movingCenter.y
            let velocityConstant = fingerDistance/maxFingerMoviment
            
            let climb = SKAction.moveBy(x: 0, y: 3*movimentConstant * velocityConstant, duration: 0.5)
            character?.run(climb)
        }
    }
    
    @objc func holdCrate(_ sender: UILongPressGestureRecognizer){
        character?.addChild(crate!)
        crate?.removeFromParent()
    }
    
}
