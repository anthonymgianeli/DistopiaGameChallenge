//
//  LevelGameScene.swift
//  DistopiaGame
//
//  Created by Julia Conti Mestre on 04/07/19.
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
    static let Camera: UInt32 = 128
    static let Laser: UInt32 = 256
}


//COMMON CLASS TO EVERY SCENE - CHARACTER HANDLING
class LevelGameScene: SKScene{
    
    var swipeUpActionDelegate: SwipeUpActionExecutor!
    
    //MARK: Character variables
    
    //character state to animate
    enum CharacterState {
        case idle
        case running
        case jumping
        case walking
    }
    
    var characterImage = SKSpriteNode()
    var characterBody = SKSpriteNode()
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
    //Moviment direct and distance
    var direction = 1
    var dx: CGFloat = 0
    
    //MARK: Character state booleans
    var isMoving = false
    var isWalking = false
    var isRunning = false
    var isJumping = false
    
    //MARK: Touches variables
    var fingerLocation = CGPoint.zero
    var touchBeganLocation = CGPoint.zero
    var touchEndedLocation = CGPoint.zero
    var center = CGPoint.zero
    let screenSize: CGRect = UIScreen.main.bounds
    var maxDx: CGFloat = 1
    //Handle multiple touches
    var activeTouches = [UITouch: String]()
    var activeTouchesFirstScreen: Int = 0
    var middleScreen = UIScreen.main.bounds.width/2
    
    //Handle "secondHalfOfScreen" gestures
    var jump = UISwipeGestureRecognizer()
    var carry = UILongPressGestureRecognizer()
    
    //MARK: Did Move Function
    override func didMove(to view: SKView) {
        self.characterImage = childNode(withName: "CharacterImage") as! SKSpriteNode
        self.characterBody = characterImage.childNode(withName: "CharacterBody") as! SKSpriteNode
        buildCharacter()
        
        
        jump = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        jump.direction = .up
        self.view!.addGestureRecognizer(jump)
        
        carry = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:isInContact:)))
        self.view!.addGestureRecognizer(carry)
    }
    
    //MARK: Handle Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            //Handle character moviment when touches began
            setBeganCharacterMoviment(touch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            //Handle character moviment when touches moved
            let movingTouchOnScreen = activeTouches[touch]
            
            if movingTouchOnScreen == "firstHalfOfScreen" {
                isMoving = true
                setCharacterHorizontalMoviment(touch)
            } else if movingTouchOnScreen == "secondHalfOfScreen" {
                //handle jump and interation
            } else if movingTouchOnScreen == "notValidTouch" {
                break
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            //Handle character moviment when touches ended
            let endedTouchOnScreen = activeTouches[touch]
            
            if endedTouchOnScreen == "firstHalfOfScreen" {
                isMoving = false
                isRunning = false
                isWalking = false
                isJumping = false
                center = CGPoint.zero
                
                activeTouchesFirstScreen -= 1
                
                setCharacterState = .idle
            } else if endedTouchOnScreen == "secondHalfOfScreen" {

            } else if endedTouchOnScreen == "notValidTouch" {
                break
            }
            
            activeTouches.removeValue(forKey: touch)
        }
        
    }
    
    @objc func longPress(_ gesture: UILongPressGestureRecognizer, isInContact:Bool) {
        if gesture.location(in: self.view).x > middleScreen && !isInContact {
            //Colocar acao aqui!
        }
    }
    
    @objc func swipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.location(in: self.view).x > middleScreen {
            swipeUpActionDelegate.executeSwipeUpAction(gesture)
        }
    }
    
    //MARK: Update
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if isMoving {
            moveCharacterHorizontal()
        }
        //handle jump and interaction
    }
    
    //MARK: Character Moviments
    fileprivate func setBeganCharacterMoviment(_ touch: UITouch) {
        touchBeganLocation = touch.location(in: self)
        
        //Character horizontal moviment - First touch in the left side of the screen
        if touchBeganLocation.x < middleScreen && activeTouchesFirstScreen == 0 {
            activeTouches[touch] = "firstHalfOfScreen"
            center = touch.location(in: self)
            activeTouchesFirstScreen += 1
            
            //Start with the previous character state
            if isWalking {
                previousCharacterState = .walking
            } else if isRunning {
                previousCharacterState = .running
            } else if !isMoving {
                previousCharacterState = .idle
            } else if isJumping {
                previousCharacterState = .jumping
            }
            //Second touch in the left side of the screen - Invalid!
        } else if touchBeganLocation.x < middleScreen && activeTouchesFirstScreen != 0 {
            activeTouches[touch] = "notValidTouch"
            
            //Character jump or interation with objects - second half of the screen
        } else if touchBeganLocation.x > middleScreen {
            activeTouches[touch] = "secondHalfOfScreen"
        }
    }
    
    fileprivate func setCharacterHorizontalMoviment(_ touch: UITouch) {
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
            characterImage.removeAllActions()
            
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
        characterImage.xScale = abs(characterImage.xScale) * CGFloat(direction)
    }
    
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
        
        characterImage.position = CGPoint(x: characterImage.position.x + (dx * speed), y: characterImage.position.y)
    }
    
    //MARK: Animations & Frames
    func buildCharacter() {
        var frames: [SKTexture] = []
        
        switch setCharacterState {
        case .idle:
            idleCharacter(&frames)
        case .jumping:
            jumpingCharacter(&frames)
        case .running:
            runningCharacter(&frames)
        case .walking:
            walkingCharacter(&frames)
        }
        
        characterFrames = frames
        let firstFrameTexture = characterFrames[0]
        characterImage.texture = firstFrameTexture
        
        //Animate character
        characterImage.run(SKAction.repeatForever(SKAction.animate(with: characterFrames,
                                                              timePerFrame: 0.1,
                                                              resize: false,
                                                              restore: true)), withKey:"animateCharacter")
    }
    
    fileprivate func idleCharacter(_ frames: inout [SKTexture]) {
        let characterTexture = SKTextureAtlas(dictionary: [
            "Idle1": UIImage(named: "Idle_01")!,
            "Idle2": UIImage(named: "Idle_02")!,
            "Idle3": UIImage(named: "Idle_03")!,
            "Idle4": UIImage(named: "Idle_04")!,
            "Idle5": UIImage(named: "Idle_05")!,
            "Idle6": UIImage(named: "Idle_06")!,
            "Idle7": UIImage(named: "Idle_07")!,
            "Idle8": UIImage(named: "Idle_08")!,
            "Idle9": UIImage(named: "Idle_09")!,
            "Idle10": UIImage(named: "Idle_010")!,
            "Idle11": UIImage(named: "Idle_011")!,
            "Idle12": UIImage(named: "Idle_012")!])
        
        let numImages = characterTexture.textureNames.count
        for i in 1...numImages {
            let characterTextureName = "Idle\(i)"
            frames.append(characterTexture.textureNamed(characterTextureName))
        }
    }
    
    fileprivate func jumpingCharacter(_ frames: inout [SKTexture]) {
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
    }
    
    fileprivate func runningCharacter(_ frames: inout [SKTexture]) {
        let characterTexture = SKTextureAtlas(dictionary: [
            "Run1": UIImage(named: "Running_01")!,
            "Run2": UIImage(named: "Running_02")!,
            "Run3": UIImage(named: "Running_03")!,
            "Run4": UIImage(named: "Running_04")!,
            "Run5": UIImage(named: "Running_05")!,
            "Run6": UIImage(named: "Running_06")!,
            "Run7": UIImage(named: "Running_07")!])
        
        let numImages = characterTexture.textureNames.count
        for i in 1...numImages {
            let characterTextureName = "Run\(i)"
            frames.append(characterTexture.textureNamed(characterTextureName))
        }
    }
    
    fileprivate func walkingCharacter(_ frames: inout [SKTexture]) {
        let characterTexture = SKTextureAtlas(dictionary: [
            "Walk1": UIImage(named: "Walking_01")!,
            "Walk2": UIImage(named: "Walking_02")!,
            "Walk3": UIImage(named: "Walking_03")!,
            "Walk4": UIImage(named: "Walking_04")!,
            "Walk5": UIImage(named: "Walking_05")!,
            "Walk6": UIImage(named: "Walking_06")!,
            "Walk7": UIImage(named: "Walking_07")!,
            "Walk8": UIImage(named: "Walking_08")!,
            "Walk9": UIImage(named: "Walking_09")!])
        
        let numImages = characterTexture.textureNames.count
        for i in 1...numImages {
            let characterTextureName = "Walk\(i)"
            frames.append(characterTexture.textureNamed(characterTextureName))
        }
    }
    
    func restart(levelWithFileNamed: String){
        if let view = self.view as SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: levelWithFileNamed) {
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

