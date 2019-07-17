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
    var paper1 = SKSpriteNode()
    var paper2 = SKSpriteNode()
    var paper3 = SKSpriteNode()
    var button = SKSpriteNode()
    var lever = SKSpriteNode()
    var secretDoor = SKSpriteNode()
    
    var isTouchingSpikes: Bool = false
    var isTouchingPaper1: Bool = false
    var isTouchingPaper2: Bool = false
    var isTouchingPaper3: Bool = false
    var isTouchingLever: Bool = false
    var isLeverUP: Bool = false
    
    var collectItem = UITapGestureRecognizer()
    var numItemsCollected = 0
    var liftDoor = SKAction()
    var isDoorLifted = false
    
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
        self.paper1 = childNode(withName: "paper1") as! SKSpriteNode
        self.paper2 = childNode(withName: "paper2") as! SKSpriteNode
        self.paper3 = childNode(withName: "paper3") as! SKSpriteNode
        self.button = childNode(withName: "button") as! SKSpriteNode
        self.lever = childNode(withName: "lever") as! SKSpriteNode
        self.secretDoor = childNode(withName: "secretDoor") as! SKSpriteNode
    
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
        
        let spikesPhysicsBody =  SKPhysicsBody.init(rectangleOf: CGSize(width: spikes.size.width, height: spikes.size.height))
        spikesPhysicsBody.isDynamic = false
        spikesPhysicsBody.affectedByGravity = false
        spikesPhysicsBody.allowsRotation = false
        spikesPhysicsBody.pinned = false
        spikesPhysicsBody.restitution = 0
        self.spikes.physicsBody = spikesPhysicsBody
        
        let leverPhysicsBody =  SKPhysicsBody.init(rectangleOf: CGSize(width: lever.size.width, height: lever.size.height))
        leverPhysicsBody.isDynamic = false
        leverPhysicsBody.affectedByGravity = false
        leverPhysicsBody.allowsRotation = false
        leverPhysicsBody.pinned = false
        leverPhysicsBody.restitution = 0
        self.lever.physicsBody = leverPhysicsBody
        
        let paper3PhysicsBody =  SKPhysicsBody.init(circleOfRadius: CGFloat(paper3.size.width/2 - 0.25))
        paper3PhysicsBody.isDynamic = false
        paper3PhysicsBody.affectedByGravity = false
        paper3PhysicsBody.allowsRotation = false
        paper3PhysicsBody.pinned = false
        self.paper3.physicsBody = paper3PhysicsBody
        self.paper3.isHidden = true
        
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
        paper1.physicsBody?.categoryBitMask = ColliderType.Collectable
        paper2.physicsBody?.categoryBitMask = ColliderType.Collectable
        paper3.physicsBody?.categoryBitMask = ColliderType.Collectable
        lever.physicsBody?.categoryBitMask = ColliderType.Lever
        
        //Contact
        characterImage.physicsBody?.contactTestBitMask = ColliderType.Stairs | ColliderType.Spikes | ColliderType.Wall | ColliderType.Ground | ColliderType.Barrel | ColliderType.Collectable | ColliderType.Lever
        paper3.physicsBody?.contactTestBitMask = ColliderType.Ground
        
        //Collision
        characterImage.physicsBody?.collisionBitMask = ColliderType.Barrel | ColliderType.Platform | ColliderType.Ground | ColliderType.Wall
        
        //Collect items with double tap
        numItemsCollected = 0
        isLeverUP = false
        collectItem = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        collectItem.numberOfTapsRequired = 2
        self.view!.addGestureRecognizer(collectItem)
        
        liftDoor = SKAction.moveBy(x: 0, y: 1.5 * characterImage.size.height, duration: 2.0)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        moveCamera(rightScreenEdge: size.width * 2)
        
        if numItemsCollected == 3 && !isDoorLifted {
            door.run(liftDoor)
            button.color = .green
            isDoorLifted = true
        }
        
        if characterImage.position.x > door.position.x {
            restart(levelWithFileNamed: "Level3")
        }
        
        //DECIDE IF IT WILL BE USED
        //        if characterImage.position.x < scene?.size.width ?? 800 {
        //            //Adjust the isCharacterAboveStairs state
        //            if characterImage.position.y >= stairs1.position.y + stairs1.size.height/2 {
        //                isCharacterAboveStairs = true
        //            }
        //
        //            //Adjust climbing animation
        //            if isClimbingUp && self.characterImage.position.y >= stairs1.position.y + stairs1.size.height/2 {
        //                setCharacterState = previousCharacterState
        //            }
        //
        //        } else if characterImage.position.x > scene?.size.width ?? 800 {
        //            //Adjust the isCharacterAboveStairs state
        //            if characterImage.position.y >= stairs2.position.y + stairs2.size.height/2 {
        //                isCharacterAboveStairs = true
        //            }
        //
        //            //Adjust climbing animation
        //            if isClimbingUp && self.characterImage.position.y >= stairs2.position.y + stairs2.size.height/2 {
        //                setCharacterState = previousCharacterState
        //            }
        //        }
        
    }
    
    //Handle contact
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = characterImage.physicsBody
        let bodyB = spikes.physicsBody
        let bodyC = gear.physicsBody
        let bodyD = stairs1.physicsBody
        let bodyE = stairs2.physicsBody
        let bodyF = barrel.physicsBody
        let bodyG = ground.physicsBody
        let bodyH = platform3.physicsBody
        let bodyI = paper1.physicsBody
        let bodyJ = paper2.physicsBody
        let bodyK = paper3.physicsBody
        let bodyL = lever.physicsBody
        
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
                self.characterImage.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: 60, height: 15))
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

            if !isJumping && isTouchingStairs {
                characterImage.physicsBody?.affectedByGravity = false
            }
            
            if isCharacterAboveStairs && !isClimbing {
                characterImage.physicsBody?.collisionBitMask = ColliderType.Barrel | ColliderType.Platform | ColliderType.Ground | ColliderType.Wall | ColliderType.Stairs
                stairs1.physicsBody?.collisionBitMask = ColliderType.Character
                stairs2.physicsBody?.collisionBitMask = ColliderType.Character
            }
        }
        
        //Dead by height
        if ((contact.bodyA == bodyA && contact.bodyB == bodyG) ||
            (contact.bodyA == bodyG && contact.bodyB == bodyA)) {
            
            characterImage.physicsBody?.collisionBitMask = ColliderType.Barrel | ColliderType.Platform | ColliderType.Ground | ColliderType.Wall
            
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
                let waitToCorectPhysicsBody = SKAction.wait(forDuration: 0.5)
                let changePhysicsBody = SKAction.run {
                    self.characterImage.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: 60, height: 15))
                }
                let wait = SKAction.wait(forDuration: 0.9)
                let restart = SKAction.run {
                    super.restart(levelWithFileNamed: "Level1GameScene")
                    self.isTouchingSpikes = false
                }
                
                let deadSequence = SKAction.sequence([deadAnimation, waitToCorectPhysicsBody, changePhysicsBody, wait, restart])
                super.characterImage.run(deadSequence)
            }
            
            isCharacterAboveStairs = false
        }
        
        //Barrel and biggest stair contact
        if (contact.bodyA == bodyA && (contact.bodyB == bodyF || contact.bodyB == bodyH) || (contact.bodyB == bodyA && (contact.bodyA == bodyF || contact.bodyA == bodyF))) {
            
            characterImage.physicsBody?.collisionBitMask = ColliderType.Barrel | ColliderType.Platform | ColliderType.Ground | ColliderType.Wall
            
            isCharacterAboveStairs = false
        }
        
        //Collectable contact - paper 1
        if ((contact.bodyA == bodyA && contact.bodyB == bodyI) || (contact.bodyB == bodyA && contact.bodyA == bodyI)) {
            isTouchingPaper1 = true
        }
        
        //Collectable contact - paper 2
        if ((contact.bodyA == bodyA && contact.bodyB == bodyJ) || (contact.bodyB == bodyA && contact.bodyA == bodyJ)) {
            isTouchingPaper2 = true
        }
        
        //Collectable contact - paper 3
        if ((contact.bodyA == bodyA && contact.bodyB == bodyK) || (contact.bodyB == bodyA && contact.bodyA == bodyK)) {
            isTouchingPaper3 = true
        }
        
        //Paper 3 and ground/stairs 2
        if ((contact.bodyA == bodyK && (contact.bodyB == bodyG || contact.bodyB == bodyE)) || (contact.bodyB == bodyK && (contact.bodyA == bodyG || contact.bodyA == bodyE))) {
            paper3.physicsBody?.isDynamic = false
            paper3.physicsBody?.affectedByGravity = false
            paper3.physicsBody?.allowsRotation = false
            paper3.physicsBody?.restitution = 0
        }
        
        //Lever
        if ((contact.bodyA == bodyA && contact.bodyB == bodyL) || (contact.bodyB == bodyA && contact.bodyA == bodyL)) {
            isTouchingLever = true
        }
        
    }
    
        
    func didEnd(_ contact: SKPhysicsContact) {
        let bodyA = characterImage.physicsBody
        let bodyD = stairs1.physicsBody
        let bodyE = stairs2.physicsBody
        let bodyI = paper1.physicsBody
        let bodyJ = paper2.physicsBody
        let bodyK = paper3.physicsBody
        let bodyL = lever.physicsBody
        
        
        // Stair end of contact
        if (contact.bodyA == bodyA && (contact.bodyB == bodyD || contact.bodyB == bodyE)) || ((contact.bodyA == bodyD || contact.bodyA == bodyE) &&
            contact.bodyB == bodyA) && isTouchingStairs {
            
            isTouchingStairs = false
            
            if !isTouchingStairs {
                characterImage.physicsBody?.affectedByGravity = true
                setCharacterState = previousCharacterState
                
                //Stairs 1
                if characterImage.position.x < scene?.frame.width ?? 800 {
                    let characterYPosition = characterImage.position.y + characterImage.frame.height/2
                    let stair1TopPosition = (stairs1.position.y) + (stairs1.size.height)/2
                    
                    if characterYPosition >= stair1TopPosition {
                        isCharacterAboveStairs = true
                        characterImage.physicsBody?.collisionBitMask = ColliderType.Barrel | ColliderType.Platform | ColliderType.Ground | ColliderType.Wall | ColliderType.Stairs
                    }
                }
                
                //Stairs 2
                if characterImage.position.x > scene?.frame.width ?? 800 {
                    let characterYPosition = characterImage.position.y + characterImage.frame.height/2
                    let stair2TopPosition = (stairs2.position.y) + (stairs2.size.height)/2
                    
                    if characterYPosition >= stair2TopPosition {
                        isCharacterAboveStairs = true
                        characterImage.physicsBody?.collisionBitMask = ColliderType.Barrel | ColliderType.Platform | ColliderType.Ground | ColliderType.Wall | ColliderType.Stairs
                    }
                }
            }
        }
        
        //Collectable contact - paper 1
        if ((contact.bodyA == bodyA && contact.bodyB == bodyI) || (contact.bodyB == bodyA && contact.bodyA == bodyI)) && isTouchingPaper1 {
            isTouchingPaper1 = false
        }
        
        //Collectable contact - paper 2
        if ((contact.bodyA == bodyA && contact.bodyB == bodyJ) || (contact.bodyB == bodyA && contact.bodyA == bodyJ)) && isTouchingPaper2 {
            isTouchingPaper2 = false
        }
        
        //Collectable contact - paper 3
        if ((contact.bodyA == bodyA && contact.bodyB == bodyK) || (contact.bodyB == bodyA && contact.bodyA == bodyK)) && isTouchingPaper3 {
            isTouchingPaper3 = false
        }
        
        //Lever
        if ((contact.bodyA == bodyA && contact.bodyB == bodyL) || (contact.bodyB == bodyA && contact.bodyA == bodyL)) && isTouchingLever {
            isTouchingLever = false
        }
    }
    
    @objc func doubleTap(_ sender: UITapGestureRecognizer) {
        
        if isTouchingPaper1 {
            paper1.isHidden = true
            numItemsCollected += 1
        } else if isTouchingPaper2 {
            paper2.isHidden = true
            numItemsCollected += 1
        } else if isTouchingPaper3 {
            paper3.isHidden = true
            numItemsCollected += 1
        }
        
        if isTouchingLever && !isLeverUP {
            lever.texture = SKTexture(imageNamed: "Level 1 Assets/leverUp")
            isLeverUP = true
            
            paper3.physicsBody?.isDynamic = true
            paper3.physicsBody?.affectedByGravity = true
            paper3.physicsBody?.allowsRotation = true
            paper3.isHidden = false
            
            let rotateSecretDoor = SKAction.rotate(byAngle: -(.pi/6), duration: 2.0)
            secretDoor.run(rotateSecretDoor)
        }
 
    }
}

