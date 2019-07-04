//
//  StairsGameScene.swift
//  DistopiaGame
//
//  Created by Julia Conti Mestre on 01/07/19.
//  Copyright © 2019 anthony.gianeli. All rights reserved.
//

import SpriteKit
import GameplayKit

enum CharacterState {
    case idle
    case running
    case jumping
    case walking
}

class Level1GameScene: SKScene {
    
    var character = SKSpriteNode()
    var setCharacterState = CharacterState.idle {
        didSet {
            buildCharacter()
        }
    }
    //Current state
    var currentCharacterState = CharacterState.idle
    //Previous state
    var previousCharacterState = CharacterState.idle
    var characterFrames: [SKTexture] = []
    
    var fingerLocation = CGPoint.zero
    var firstTouch = CGPoint.zero
    var center = CGPoint.zero
    let screenSize: CGRect = UIScreen.main.bounds
    var maxDx: CGFloat = 1
    
    var isMoving = false
    var isWalking = false
    var isRunning = false
    var direction = 1
    var dx: CGFloat = 0 //moviment distance
    
    override func didMove(to view: SKView) {
        self.character = self.childNode(withName: "character") as! SKSpriteNode
        
        buildCharacter()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            firstTouch = touch.location(in: self)
            center = touch.location(in: self)
            
            //Start with the previous character state
            if isWalking {
                previousCharacterState = .walking
            } else if isRunning {
                previousCharacterState = .running
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMoving = true
        
        for touch in touches {
            setCharacterFeatures(touch)
        }
    }
    
    func setCharacterFeatures(_ touch: UITouch) {
        fingerLocation = touch.location(in: self)
        maxDx = screenSize.width/6
        
        let fingerDx = abs(fingerLocation.x - center.x)
        
        //To move the "joystick" center
        if fingerDx >= maxDx  {
            let difference = fingerDx - maxDx
            //Move right
            if fingerLocation.x > center.x {
                center.x = center.x + difference
                //Move Left
            } else if fingerLocation.x < center.x {
                center.x = center.x - difference
            }
        }
        
        //Moviment distance
        dx = fingerLocation.x - center.x
        
        //To set the current state
        if isWalking {
            currentCharacterState = .walking
        } else if isRunning {
            currentCharacterState = .running
        }
        
        //Compare previous and current state
        if currentCharacterState != previousCharacterState {
            character.removeAllActions()
            
            if currentCharacterState == .walking {
                setCharacterState = .walking
            } else if currentCharacterState == .running {
                setCharacterState = .running
            }
            
            previousCharacterState = currentCharacterState
        }
        
        //To set the character direction
        if dx > 0 {
            direction = 1
        } else if dx < 0 {
            direction = -1
        }
        character.xScale = abs(character.xScale) * CGFloat(direction)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Stop node from moving to touch
        isMoving = false
        center = CGPoint.zero
        
        //Set the state when the character is not moving
        setCharacterState = .idle
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if isMoving && abs(dx) > 3 {
            moveCharacterHorizontal()
        }
    }
    
    // Move the character according to the touch
    func moveCharacterHorizontal() {
        maxDx = screenSize.width/6
        // How fast to move the node. Adjust as needed
        let speed: CGFloat = 0.018
        
        // Compute vector components in direction of the touch
        dx = fingerLocation.x - center.x
        //Ajust max velocity
        if dx >= maxDx {
            dx = maxDx
        } else if dx <= -maxDx {
            dx = -maxDx
        }
        
        //Set the character state
        if abs(dx) < maxDx/3 {
            isWalking = true
            isRunning = false
        } else if abs(dx) > maxDx/3 {
            isWalking = false
            isRunning = true
        }
        
        
        character.position = CGPoint(x: character.position.x + (dx * speed), y: character.position.y)
    }
    
    func buildCharacter() {
        var frames: [SKTexture] = []
        
        switch setCharacterState {
        case .idle:
            let characterTexture = SKTextureAtlas(dictionary: [
                "Idle1": UIImage(named: "Idle-hero01_001")!,
                "Idle2": UIImage(named: "Idle-hero01_002")!,
                "Idle3": UIImage(named: "Idle-hero01_003")!,
                "Idle4": UIImage(named: "Idle-hero01_004")!,
                "Idle5": UIImage(named: "Idle-hero01_005")!,
                "Idle6": UIImage(named: "Idle-hero01_006")!,
                "Idle7": UIImage(named: "Idle-hero01_007")!,
                "Idle8": UIImage(named: "Idle-hero01_008")!,
                "Idle9": UIImage(named: "Idle-hero01_009")!,
                "Idle10": UIImage(named: "Idle-hero01_010")!,
                "Idle11": UIImage(named: "Idle-hero01_011")!,
                "Idle12": UIImage(named: "Idle-hero01_012")!])
            
            let numImages = characterTexture.textureNames.count
            for i in 1...numImages {
                let characterTextureName = "Idle\(i)"
                frames.append(characterTexture.textureNamed(characterTextureName))
            }
        case .jumping:
            let characterTexture = SKTextureAtlas(dictionary: [
                "Jump1": UIImage(named: "Jump-hero01_001")!,
                "Jump2": UIImage(named: "Jump-hero01_002")!,
                "Jump3": UIImage(named: "Jump-hero01_003")!,
                "Jump4": UIImage(named: "Jump-hero01_004")!,
                "Jump5": UIImage(named: "Jump-hero01_005")!,
                "Jump6": UIImage(named: "Jump-hero01_006")!,
                "Jump7": UIImage(named: "Jump-hero01_007")!,
                "Jump8": UIImage(named: "Jump-hero01_008")!,
                "Jump9": UIImage(named: "Jump-hero01_009")!])
            
            let numImages = characterTexture.textureNames.count
            for i in 1...numImages {
                let characterTextureName = "Jump\(i)"
                frames.append(characterTexture.textureNamed(characterTextureName))
            }
        case .running:
            let characterTexture = SKTextureAtlas(dictionary: [
                "Run1": UIImage(named: "Run-hero01_001")!,
                "Run2": UIImage(named: "Run-hero01_002")!,
                "Run3": UIImage(named: "Run-hero01_003")!,
                "Run4": UIImage(named: "Run-hero01_004")!,
                "Run5": UIImage(named: "Run-hero01_005")!,
                "Run6": UIImage(named: "Run-hero01_006")!,
                "Run7": UIImage(named: "Run-hero01_007")!])

            let numImages = characterTexture.textureNames.count
            for i in 1...numImages {
                let characterTextureName = "Run\(i)"
                frames.append(characterTexture.textureNamed(characterTextureName))
            }
            
        case .walking:
        let characterTexture = SKTextureAtlas(dictionary: [
            "Walk1": UIImage(named: "Walk-hero01_001")!,
            "Walk2": UIImage(named: "Walk-hero01_002")!,
            "Walk3": UIImage(named: "Walk-hero01_003")!,
            "Walk4": UIImage(named: "Walk-hero01_004")!,
            "Walk5": UIImage(named: "Walk-hero01_005")!,
            "Walk6": UIImage(named: "Walk-hero01_006")!,
            "Walk7": UIImage(named: "Walk-hero01_007")!,
            "Walk8": UIImage(named: "Walk-hero01_008")!,
            "Walk9": UIImage(named: "Walk-hero01_009")!])
        
        let numImages = characterTexture.textureNames.count
        for i in 1...numImages {
            let characterTextureName = "Walk\(i)"
            frames.append(characterTexture.textureNamed(characterTextureName))
            }
        }
        
        characterFrames = frames
        
        let firstFrameTexture = characterFrames[0]
//        character.xScale = abs(character.xScale) * CGFloat(direction)
        character.texture = firstFrameTexture
        
        //Animate character
        character.run(SKAction.repeatForever(SKAction.animate(with: characterFrames,
                                                               timePerFrame: 0.1,
                                                               resize: false,
                                                               restore: true)), withKey:"animateCharacter")
    }

    
}
