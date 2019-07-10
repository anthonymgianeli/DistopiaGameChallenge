//
//  Level3GameScene.swift
//  DistopiaGame
//
//  Created by João Vitor Lopes Capi on 03/07/19.
//  Copyright © 2019 anthony.gianeli. All rights reserved.
//

import SpriteKit
import GameplayKit


class Level3GameScene: LevelGameScene, SKPhysicsContactDelegate, SwipeUpActionExecutor{
    
    var spikes: SKSpriteNode?
    var stairs: SKSpriteNode?
    var crate: SKSpriteNode?
    var pressurePlate: SKSpriteNode?
    var door: SKSpriteNode?
    var lampLight: SKSpriteNode?
    
    var playerIsTouchingPressurePlate = false
    var crateIsTouchingPressurePlate = false
    var isTouchingSpikes = false
    var isTouchingStairs = false
    var isTouchingCrate = false
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.swipeUpActionDelegate = self
        
        self.spikes = self.childNode(withName: "spikes") as? SKSpriteNode
        self.stairs = self.childNode(withName: "stairs") as? SKSpriteNode
        self.crate = self.childNode(withName: "crate") as? SKSpriteNode
        self.pressurePlate = self.childNode(withName: "pressurePlate") as? SKSpriteNode
        self.door = self.childNode(withName: "door") as? SKSpriteNode
        self.lampLight = self.childNode(withName: "lampLight") as? SKSpriteNode
        
        physicsWorld.contactDelegate = self
        
        //Category BitMask
        characterBody.physicsBody?.categoryBitMask = ColliderType.Character
        self.stairs!.physicsBody?.categoryBitMask = ColliderType.Stairs
        self.spikes!.physicsBody?.categoryBitMask = ColliderType.Spikes
        self.pressurePlate!.physicsBody?.categoryBitMask = ColliderType.PressurePlate
        self.crate!.physicsBody?.categoryBitMask = ColliderType.Crate
        
        //Collision BitMask
        characterBody.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Crate
        self.door!.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Character | ColliderType.Crate
        self.crate!.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Character
        
        //Contact BitMask
        characterBody.physicsBody?.contactTestBitMask = ColliderType.Spikes | ColliderType.Stairs | ColliderType.PressurePlate
        self.crate!.physicsBody?.contactTestBitMask = ColliderType.Character | ColliderType.PressurePlate
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        if ((contact.bodyA==super.characterBody.physicsBody && contact.bodyB==self.spikes?.physicsBody) || (contact.bodyA==self.spikes?.physicsBody && contact.bodyB==super.characterBody.physicsBody)) && !isTouchingSpikes{
            isTouchingSpikes = true
            
            if isTouchingSpikes{
                super.restart(levelWithFileNamed: "Level3")
            }
        }
        
        
        if ((contact.bodyA==super.characterBody.physicsBody && contact.bodyB==self.pressurePlate?.physicsBody) || (contact.bodyA==self.pressurePlate?.physicsBody && contact.bodyB==super.characterBody.physicsBody)) && !playerIsTouchingPressurePlate{
            
            if !crateIsTouchingPressurePlate{
                playerIsTouchingPressurePlate = true
            }
            
            let liftDoor = SKAction.moveBy(x: 0, y: 150, duration: 0.5)
            
            if playerIsTouchingPressurePlate{
                self.lampLight?.alpha = 1
                self.door?.run(liftDoor)
            }
        }
        
        if ((contact.bodyA==super.characterBody.physicsBody && contact.bodyB==self.stairs?.physicsBody) || (contact.bodyA==self.stairs?.physicsBody &&
            contact.bodyB==super.characterBody.physicsBody)) && !isTouchingStairs{
            isTouchingStairs = true
            
            if isTouchingStairs{
                
                characterBody.physicsBody?.affectedByGravity = false
            }
        }
        
        if ((contact.bodyA==self.crate?.physicsBody && contact.bodyB==self.pressurePlate?.physicsBody) || (contact.bodyA==self.pressurePlate?.physicsBody && contact.bodyB==self.crate?.physicsBody)) && !crateIsTouchingPressurePlate{
            
            if !playerIsTouchingPressurePlate{
                crateIsTouchingPressurePlate = true
            }
            
            let liftDoor = SKAction.moveBy(x: 0, y: 150, duration: 0.5)
            
            if crateIsTouchingPressurePlate{
                self.door?.run(liftDoor)
            }
        }
        
        if ((contact.bodyA==self.crate?.physicsBody && contact.bodyB==super.characterBody.physicsBody) || (contact.bodyA==super.characterBody.physicsBody && contact.bodyB==self.crate?.physicsBody)) && !isTouchingCrate{
            
            isTouchingCrate = true
            
            if isTouchingCrate{
                let holdCrateGesture = UILongPressGestureRecognizer(target: self, action: #selector(holdCrate(_:)))
                view?.addGestureRecognizer(holdCrateGesture)
                print("Aqui ele segura a caixa (anexar 2 spriteNodes talvez?)")
            }
        }
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
        if (contact.bodyA==super.characterBody.physicsBody && contact.bodyB==self.pressurePlate?.physicsBody) || (contact.bodyA==self.pressurePlate?.physicsBody && contact.bodyB==super.characterBody.physicsBody) && playerIsTouchingPressurePlate{
            playerIsTouchingPressurePlate = false
            if !playerIsTouchingPressurePlate{
                let unliftDoor = SKAction.moveBy(x: 0, y: -150, duration: 0.5)
                
                self.lampLight?.alpha = 0
                self.door?.run(unliftDoor)
            }
        }
        
        if (contact.bodyA==super.characterBody.physicsBody && contact.bodyB==self.stairs?.physicsBody) || (contact.bodyA==self.stairs?.physicsBody &&
            contact.bodyB==super.characterBody.physicsBody) && isTouchingStairs{
            isTouchingStairs = false
            if !isTouchingStairs{
                characterBody.physicsBody?.affectedByGravity = true
            }
        }
        
        if (contact.bodyA==self.crate?.physicsBody && contact.bodyB==self.pressurePlate?.physicsBody) || (contact.bodyA==self.pressurePlate?.physicsBody && contact.bodyB==self.crate?.physicsBody) && crateIsTouchingPressurePlate{
            crateIsTouchingPressurePlate = false
            
            if !crateIsTouchingPressurePlate{
                let unliftDoor = SKAction.moveBy(x: 0, y: -150, duration: 0.5)
                
                self.door?.run(unliftDoor)
            }
        }
        
        if ((contact.bodyA==self.crate?.physicsBody && contact.bodyB==super.characterBody.physicsBody) || (contact.bodyA==super.characterBody.physicsBody && contact.bodyB==self.crate?.physicsBody)) && isTouchingCrate{
            
            isTouchingCrate = false
            
            if !isTouchingCrate{
                print("Aqui é quando ele perde o contato com a caixa, se funcionar o print o de hj ta pago")
            }
        }
    }
     
    
    @objc func executeSwipeUpAction(_ sender: UISwipeGestureRecognizer) {
        if !isTouchingStairs{
//            super.characterBody.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 250))
            let jumpUpAction = SKAction.moveBy(x: 0, y:20, duration:0.4)
            let jumpDownAction = SKAction.moveBy(x: 0, y:-20, duration:0.4)
            
            // sequence of move yup then down
            let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction])
            
            // make player run sequence
            characterImage.run(jumpSequence)
            super.setCharacterState = .jumping
            
        }
        else{
            super.characterBody.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
            super.characterBody.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -20))
        }
    }
    
    @objc func holdCrate(_ sender: UILongPressGestureRecognizer){
        crate?.removeFromParent()
        characterBody.addChild(crate!)
    }
    
}
