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
    //Moviment direct, distance and velocity
    var direction = 1
    var dx: CGFloat = 0
    var characterMoviment: CGFloat = 0
    
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
    
    //MARK: Background variables
    var background1 = SKSpriteNode()
    var background2 = SKSpriteNode()
    var background3 = SKSpriteNode()
    var background4 = SKSpriteNode()
    
    var backgrounds = [SKSpriteNode()]
    
    //Camera variables
    let cameraNode = SKCameraNode()
    var previousCameraPosition = CGPoint.zero
    var currentCameraPosition = CGPoint.zero

    
    //MARK: Did Move Function
    override func didMove(to view: SKView) {
        self.characterImage = childNode(withName: "CharacterImage") as! SKSpriteNode
        let physicsBody =  SKPhysicsBody.init(rectangleOf: CGSize(width: 30, height: 85))
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = true
        physicsBody.allowsRotation = false
        physicsBody.pinned = false
        physicsBody.restitution = 0
        self.characterImage.physicsBody = physicsBody
        
        buildCharacter() //first image and character state
        setUpCamera() //camera to move in the screen
        setUpBackground() //backgrounds to form the parallax

        self.view?.isMultipleTouchEnabled = true
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
            
            //Character horizontal moviment
            if movingTouchOnScreen == "firstHalfOfScreen" {
                isMoving = true
                setCharacterHorizontalMoviment(touch)
            //Character jump and interation
            } else if movingTouchOnScreen == "secondHalfOfScreen" {
            //Handle jump and interation
            } else if movingTouchOnScreen == "notValidTouch" {
                break
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchEndedLocation = touch.location(in: self.view)
            //Handle character moviment when touches ended
            let endedTouchOnScreen = activeTouches[touch]
            //Character horizontal moviment
            if endedTouchOnScreen == "firstHalfOfScreen" {
                isMoving = false
                isRunning = false
                isWalking = false
                isJumping = false
                center = CGPoint.zero
                
                activeTouchesFirstScreen -= 1
                
                setCharacterState = .idle
            //Character jump and interaction
            } else if endedTouchOnScreen == "secondHalfOfScreen" {
                //CORRECT JUMP - THIS IS JUST FOR SCREEN TEST
                if touchBeganLocation.y - touchEndedLocation.y > screenSize.height / 4 {
                    let jumpStart = SKAction.run {
                        self.isJumping = true
                        self.setCharacterState = .jumping
                    }
                    let jumpAction = SKAction.run {
                        self.characterImage.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 70))
                    }
                    let wait = SKAction.wait(forDuration: 1.0)
                    let jumpEnd = SKAction.run {
                        self.isJumping = false
                        self.setCharacterState = self.previousCharacterState
                    }
                    let jump = SKAction.sequence([jumpStart, jumpAction, wait, jumpEnd])
                    characterImage.run(jump)

                }
                
//                let deltaX = touchEndedLocation.x - touchBeganLocation.x
//                let deltaY = touchEndedLocation.y - touchBeganLocation.y
                

                
            } else if endedTouchOnScreen == "notValidTouch" {
                break
            }
            
            activeTouches.removeValue(forKey: touch)
        }
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    //MARK: Update
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if isMoving {
            moveCharacterHorizontal()
        }
        
        moveCamera(rightScreenEdge: size.width)
        
        /* The rightScreenEdge variable represents the size of the level
         If the rightScreenEdge is different than size.width, then to add parallax and camera moviment, in every level the uptade func must be overriten as follow:
         
        override func update(_ currentTime: TimeInterval) {
            super.update(currentTime)
            moveCamera(rightScreenEdge: LEVEL SIZE)
        }

        */
        
    }
    
    //MARK: Character Moviments
    fileprivate func setBeganCharacterMoviment(_ touch: UITouch) {
        touchBeganLocation = touch.location(in: self.view)
        
        //Character horizontal moviment - First touch in the left side of the screen
        if touchBeganLocation.x < middleScreen && activeTouchesFirstScreen == 0 {
            activeTouches[touch] = "firstHalfOfScreen"
            center = touch.location(in: self.view)
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
            
        }
    }
    
    fileprivate func setCharacterHorizontalMoviment(_ touch: UITouch) {
        fingerLocation = touch.location(in: self.view)
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

        characterMoviment = dx * speed
        characterImage.position = CGPoint(x: characterImage.position.x + (characterMoviment), y: characterImage.position.y)
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
        
    //MARK: Background/Parallax Functions
    func setUpCamera() {
        addChild(cameraNode)
        camera = cameraNode
        camera?.position.x = size.width / 2
        camera?.position.y = size.height / 2
        previousCameraPosition.x = camera?.position.x ?? 0
        previousCameraPosition.y = camera?.position.y ?? 0
    }
    
    func setUpBackground() {
        background1 = SKSpriteNode(imageNamed: "background1")
        background2 = SKSpriteNode(imageNamed: "background2")
        background3 = SKSpriteNode(imageNamed: "background3")
        background4 = SKSpriteNode(imageNamed: "background4")
        
        background1.position = CGPoint(x: background1.size.width / 2, y: background1.size.height / 2)
        background2.position = CGPoint(x: background2.size.width / 2, y: background2.size.height / 2)
        background3.position = CGPoint(x: background3.size.width / 2, y: background3.size.height / 2)
        background4.position = CGPoint(x: background4.size.width / 2, y: background4.size.height / 2)
        
        background1.zPosition = -10
        background2.zPosition = -9
        background3.zPosition = -8
        background4.zPosition = -7
        
        addChild(background1)
        addChild(background2)
        addChild(background3)
        addChild(background4)
        
        backgrounds = [background1, background2, background3, background4]
    }
    
    func moveCamera(rightScreenEdge: CGFloat) {
        //Left screen edge
        if characterImage.position.x < size.width / 2 { //don't move camera
            camera?.position.x = size.width / 2
            
            //Right screen edge - Depends on the level size
        } else if characterImage.position.x > rightScreenEdge - size.width / 2 { //stop moving camera
            camera?.position.x = rightScreenEdge - size.width / 2
            
            //Move camera according to character position
        } else {
            camera?.position.x = characterImage.position.x
            currentCameraPosition.x = camera?.position.x ?? 0
            
            parallaxInXDirection()
            
            previousCameraPosition.x = currentCameraPosition.x
        }
        
        //Move camera in Y direction
        if characterImage.position.y > screenSize.height / 2 {
            camera?.position.y = characterImage.position.y
            currentCameraPosition.y = camera?.position.y ?? 0
            
            let background1Speed: CGFloat = 0.3
            let background2Speed: CGFloat = 0.5
            let background3Speed: CGFloat = 0.7
            let background4Speed: CGFloat = 0.9
            
            let backgroundsSpeed = [background1Speed, background2Speed, background3Speed, background4Speed]
            
            
            var difY = currentCameraPosition.y - previousCameraPosition.y
            
            for i in 0...(backgrounds.count - 1) {
                difY = difY * backgroundsSpeed[i]
                backgrounds[i].position = CGPoint(x: backgrounds[i].position.x, y: backgrounds[i].position.y + difY)
            }
            
            previousCameraPosition.y = currentCameraPosition.y
        }
    }
    
    fileprivate func parallaxInXDirection() {
        let background1Speed: CGFloat = 0.1
        let background2Speed: CGFloat = 0.3
        let background3Speed: CGFloat = 0.5
        let background4Speed: CGFloat = 0.7
        
        let backgroundsSpeed = [background1Speed, background2Speed, background3Speed, background4Speed]
        
        //Parallax in x direction
        if previousCameraPosition.x != currentCameraPosition.x {
            
            //To let the background still while camera is moving
            let cameraMovimentX = (currentCameraPosition.x - previousCameraPosition.x)
            
            for i in 0...(backgrounds.count - 1) {
                
                let moveX = backgrounds[i].position.x + cameraMovimentX + -characterMoviment * backgroundsSpeed[i]
                
                backgrounds[i].position = CGPoint(x: moveX, y: backgrounds[i].position.y)
            }
        }
    }
    
}

