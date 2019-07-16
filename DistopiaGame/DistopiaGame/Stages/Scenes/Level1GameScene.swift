//
//  Level1GameScene.swift
//  DistopiaGame
//
//  Created by Julia Conti Mestre on 01/07/19.
//  Copyright © 2019 anthony.gianeli. All rights reserved.
//

import SpriteKit
import GameplayKit

class Level1GameScene: LevelGameScene, SKPhysicsContactDelegate {
    
    var ground = SKSpriteNode()
    var platform1 = SKSpriteNode()
    var platform2 = SKSpriteNode()
    var platform3 = SKSpriteNode()
    var stairs1 = SKSpriteNode()
    var stairs2 = SKSpriteNode()
    var spikes = SKSpriteNode()
    var barrel = SKSpriteNode()
    var gear = SKSpriteNode()
    var tubes = SKSpriteNode()
    var door = SKSpriteNode()
    var winningFlag = SKSpriteNode()
    
    var isTouchingSpikes: Bool = false
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        moveCamera(rightScreenEdge: size.width * 2)
        
        
        if characterImage.position.x < scene?.size.width ?? 800 {
            //Adjust the isCharacterAboveStairs state
            if characterImage.position.y - characterImage.size.height/2 >= stairs1.position.y + stairs1.size.height/2 - 10 {
                isCharacterAboveStairs = true
            }
            
            //Adjust climbing animation
            if isClimbingUp && self.characterImage.position.y >= stairs1.position.y + stairs1.size.height/2 {
                setCharacterState = previousCharacterState
            }
            
        } else if characterImage.position.x > scene?.size.width ?? 800 {
            //Adjust the isCharacterAboveStairs state
            if characterImage.position.y - characterImage.size.height/2 >= stairs2.position.y + stairs2.size.height/2 - 10{
                isCharacterAboveStairs = true
            }
            
            //Adjust climbing animation
            if isClimbingUp && self.characterImage.position.y >= stairs2.position.y + stairs2.size.height/2 {
                setCharacterState = previousCharacterState
            }
        }

    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        view.isUserInteractionEnabled = true
        setCharacterState = .idle
        
        self.ground = childNode(withName: "ground") as! SKSpriteNode
        self.platform1 = childNode(withName: "platform1") as! SKSpriteNode
        self.platform2 = childNode(withName: "platform2") as! SKSpriteNode
        self.platform3 = childNode(withName: "platform3") as! SKSpriteNode
        self.stairs1 = childNode(withName: "stairs1") as! SKSpriteNode
        self.stairs2 = childNode(withName: "stairs2") as! SKSpriteNode
        self.spikes = childNode(withName: "spikes") as! SKSpriteNode
        self.barrel = childNode(withName: "barrel") as! SKSpriteNode
        self.gear = childNode(withName: "gear") as! SKSpriteNode
        self.tubes = childNode(withName: "tubes") as! SKSpriteNode
        self.door = childNode(withName: "door") as! SKSpriteNode
        self.winningFlag = childNode(withName: "winningFlag") as! SKSpriteNode
    
        let stairs1PhysicsBody =  SKPhysicsBody.init(rectangleOf: CGSize(width: 0.2 * stairs1.size.width, height: stairs1.size.height))
        stairs1PhysicsBody.isDynamic = false
        stairs1PhysicsBody.affectedByGravity = false
        stairs1PhysicsBody.allowsRotation = false
        stairs1PhysicsBody.pinned = false
        stairs1PhysicsBody.restitution = 0
    
        self.stairs1.physicsBody = stairs1PhysicsBody
        
        let stairs2PhysicsBody =  SKPhysicsBody.init(rectangleOf: CGSize(width: 0.2 * stairs2.size.width, height: stairs2.size.height))
        stairs2PhysicsBody.isDynamic = false
        stairs2PhysicsBody.affectedByGravity = false
        stairs2PhysicsBody.allowsRotation = false
        stairs2PhysicsBody.pinned = false
        stairs2PhysicsBody.restitution = 0
        
        self.stairs2.physicsBody = stairs2PhysicsBody
        
        //Rotate gear
        let rotateGear = SKAction.rotate(byAngle: .pi/2, duration: 0.7)
        let repeatRotation = SKAction.repeatForever(rotateGear)
        gear.run(repeatRotation)
        
        physicsWorld.contactDelegate = self
        characterImage.physicsBody?.categoryBitMask = ColliderType.Character
        ground.physicsBody?.categoryBitMask = ColliderType.Ground
        platform1.physicsBody?.categoryBitMask = ColliderType.Ground
        platform2.physicsBody?.categoryBitMask = ColliderType.Ground
        platform3.physicsBody?.categoryBitMask = ColliderType.Ground
        stairs1.physicsBody?.categoryBitMask = ColliderType.Stairs
        stairs2.physicsBody?.categoryBitMask = ColliderType.Stairs
        spikes.physicsBody?.categoryBitMask = ColliderType.Spikes
        barrel.physicsBody?.categoryBitMask = ColliderType.Barrel
        gear.physicsBody?.categoryBitMask = ColliderType.Spikes
        tubes.physicsBody?.categoryBitMask = ColliderType.Tubes
        winningFlag.physicsBody?.categoryBitMask = ColliderType.Wall
        
        //Contact
        characterImage.physicsBody?.contactTestBitMask = ColliderType.Stairs | ColliderType.Spikes | ColliderType.Wall | ColliderType.Ground
        
        //Collision
        characterImage.physicsBody?.collisionBitMask = ColliderType.Barrel | ColliderType.Platform | ColliderType.Ground | ColliderType.Wall
        
    }
    
    //Handle contact
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = characterImage.physicsBody
        let bodyB = spikes.physicsBody
        let bodyC = gear.physicsBody
        let bodyD = stairs1.physicsBody
        let bodyE = stairs2.physicsBody
        let bodyF = winningFlag.physicsBody
        let bodyG = ground.physicsBody
        let bodyH = platform3.physicsBody
        
        //Spike and gear contact - dead
        if (contact.bodyA == bodyA && (contact.bodyB == bodyB || contact.bodyB == bodyC)) || ((contact.bodyA == bodyB || contact.bodyA == bodyC) && contact.bodyB == bodyA) {
            
            isTouchingSpikes = true
            isDead = true
            view?.isUserInteractionEnabled = false
            isMoving = false
            isRunning = false
            isWalking = false
            isJumping = false
            
            let deadAnimation = SKAction.run {
                super.previousCharacterState = .dead
                super.setCharacterState = .dead
            }
            let wait = SKAction.wait(forDuration: 0.9)
            let restart = SKAction.run {
                super.restart(levelWithFileNamed: "Level1GameScene")
                self.isTouchingSpikes = false
            }
            
            let deadSequence = SKAction.sequence([deadAnimation, wait, restart])
            super.characterImage.run(deadSequence)
        }
        
        //Stairs contact - climb
        if (contact.bodyA == bodyA && (contact.bodyB == bodyD || contact.bodyB == bodyE) || (contact.bodyB == bodyA && (contact.bodyA == bodyD || contact.bodyA == bodyE)) && !isTouchingStairs) {
            //Stairs height
            if characterImage.position.x < scene?.frame.width ?? 800 {
                stairHeight = stairs1.frame.maxY - stairs1.frame.minY
            } else if characterImage.position.x > scene?.frame.width ?? 800 {
                stairHeight = stairs2.frame.maxY - stairs2.frame.minY
            }
            
            isTouchingStairs = true
            print("started stairs contact")
            
            if !isJumping && isTouchingStairs {
                characterImage.physicsBody?.affectedByGravity = false
            }
        }
        
        //Dead by height
        if ((contact.bodyA == bodyA && contact.bodyB == bodyG) ||
            (contact.bodyA == bodyG && contact.bodyB == bodyA)){
            
            if isCharacterAboveStairs && !isTouchingStairs {
                isDead = true
                view?.isUserInteractionEnabled = false
                isMoving = false
                isRunning = false
                isWalking = false
                isJumping = false
                
                let deadAnimation = SKAction.run {
                    super.previousCharacterState = .dead
                    super.setCharacterState = .dead
                }
                let wait = SKAction.wait(forDuration: 0.9)
                let restart = SKAction.run {
                    super.restart(levelWithFileNamed: "Level1GameScene")
                    self.isTouchingSpikes = false
                }
                
                let deadSequence = SKAction.sequence([deadAnimation, wait, restart])
                super.characterImage.run(deadSequence)
            }
            
            isCharacterAboveStairs = false
        }
        
        if (contact.bodyA == bodyA && contact.bodyB == bodyH) || (contact.bodyB == bodyA && contact.bodyA == bodyH) {
            isCharacterAboveStairs = false
        }
        
        //Winning Flag contact - Next level
        if (contact.bodyA == bodyA && contact.bodyB == bodyF) || (contact.bodyB == bodyA && contact.bodyA == bodyF) {
            restart(levelWithFileNamed: "Level2GameScene")
        }
    }
    
        
        func didEnd(_ contact: SKPhysicsContact) {
            let bodyA = characterImage.physicsBody
            let bodyD = stairs1.physicsBody
            let bodyE = stairs2.physicsBody
            
            
            // Stair end of contact
            if (contact.bodyA == bodyA && (contact.bodyB == bodyD || contact.bodyB == bodyE)) || ((contact.bodyA == bodyD || contact.bodyA == bodyE) &&
                contact.bodyB == bodyA) && isTouchingStairs {
                
                isTouchingStairs = false
                print("ended stairs contact")
                
                if !isTouchingStairs {
                    characterImage.physicsBody?.affectedByGravity = true
                    setCharacterState = previousCharacterState
                    
                    //Stairs 1
                    if characterImage.position.x < scene?.frame.width ?? 800 {
                        let characterYPosition = characterImage.position.y + characterImage.frame.height/2
                        let stair1TopPosition = (stairs1.position.y) + (stairs1.size.height)/2
                        
                        if characterYPosition >= stair1TopPosition {
                            isCharacterAboveStairs = true
                        }
                    }
                    
                    //Stairs 2
                    if characterImage.position.x > scene?.frame.width ?? 800 {
                        let characterYPosition = characterImage.position.y + characterImage.frame.height/2
                        let stair2TopPosition = (stairs2.position.y) + (stairs2.size.height)/2
                        
                        if characterYPosition >= stair2TopPosition {
                            isCharacterAboveStairs = true
                        }
                    }
                }
            }
    }
}


/*
 - Adicionar coletáveis
 - Fazer a alavanca
 - Fazer porta subir e passar para próximo level (adc winning flag na sks)
 
 */
