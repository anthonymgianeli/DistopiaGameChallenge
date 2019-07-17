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
    static let Platform: UInt32 = 512
    static let Wall: UInt32 = 1024
    static let Gear: UInt32 = 2048
    static let Tubes: UInt32 = 4096
    static let Barrel: UInt32 = 8192
    static let WinningFlag: UInt32 = 16384
    static let Collectable: UInt32 = 32768
    static let Lever: UInt32 = 65536
}

//COMMON CLASS TO EVERY SCENE - CHARACTER HANDLING
class LevelGameScene: SKScene {
    
    var swipeUpActionDelegate: SwipeUpActionExecutor!
    
    //MARK: Character variables
    //character state to animate
    enum CharacterState {
        case idle
        case running
        case jumping
        case walking
        case dead
        case climbing
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
    var isClimbing = false
    var isTouchingStairs = false
    var isCharacterAboveStairs = false
    var isPushing = false

    var stairHeight:CGFloat = 0

    var isDead = false
    var isClimbingUp = false
    
    //Climbing variables
    var climbStart = SKAction()
    var climbAction = SKAction()
    var wait = SKAction()
    var climbEnd = SKAction()
    var climbSequence = SKAction()
    var climblingDuration: TimeInterval = 0

    
    //MARK: Touches variables
    //General locations
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
    
    let fog1 = SKSpriteNode(imageNamed: "fog1")
    let fog2 = SKSpriteNode(imageNamed: "fog2")
    
    //Camera variables
    let cameraNode = SKCameraNode()
    var previousCameraPosition = CGPoint.zero
    var currentCameraPosition = CGPoint.zero

    
    let music = Music()
    
    //MARK: Did Move Function
    override func didMove(to view: SKView) {
        stairHeight = screenSize.height
        
        self.characterImage = childNode(withName: "CharacterImage") as! SKSpriteNode
        let physicsBody =  SKPhysicsBody.init(rectangleOf: CGSize(width: 20, height: 60))
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = true
        physicsBody.allowsRotation = false
        physicsBody.pinned = false
        physicsBody.restitution = 0
        physicsBody.mass = 0.1133 // 113g
        
        self.characterImage.physicsBody = physicsBody
        
        buildCharacter() //first image and character state
        setUpCamera() //camera to move in the screen
        setUpBackground() //backgrounds to form the parallax

        self.view?.isMultipleTouchEnabled = true
        
        self.music.playingSoundWith(fileName: "BackgroundSound", type: "mp3")

        createFog()
        
        isDead = false
    }
    
    //MARK: Handle Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if isDead == true || isClimbing == true {
                touchesEnded(touches, with: event)
            } else {
                //Handle character moviment when touches began
                setBeganCharacterMoviment(touch)
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            //Handle character moviment when touches moved
            let movingTouchOnScreen = activeTouches[touch]
            
            if isDead == true || isClimbing == true {
                if isClimbing == true && setCharacterState != .climbing {
                    setCharacterState = .climbing
                }
                touchesEnded(touches, with: event)
            } else {
                //Character horizontal moviment
                if movingTouchOnScreen == "firstHalfOfScreen" {
                    //Adjust touch interation
                    if isJumping == true {
                        if setCharacterState == .jumping {
                            break
                        } else {
                            isJumping = false
                        }
                    }
                    
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
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchEndedLocation = touch.location(in: self.view)
            //Handle character moviment when touches ended
            let endedTouchOnScreen = activeTouches[touch]
            
            if isDead == true {
                break
            } else {
                //Character horizontal moviment
                if endedTouchOnScreen == "firstHalfOfScreen" {
                    
                    isMoving = false
                    isRunning = false
                    isWalking = false
                    center = CGPoint.zero
                    
                    activeTouchesFirstScreen -= 1
                    
                    if isJumping == false && isDead == false {
                        setCharacterState = .idle
                    }
                    
                    previousCharacterState = .idle
                    
                    //Character jump and interaction
                } else if endedTouchOnScreen == "secondHalfOfScreen" {
                    
                    if isTouchingStairs && !isCharacterAboveStairs && !isPushing && touchBeganLocation.y - touchEndedLocation.y > screenSize.height / 4 && !isClimbing {
                        //Climb Actions
                        climblingDuration = TimeInterval(stairHeight / 90)
                        climbStart = SKAction.run {
                            self.isClimbing = true
                            self.isClimbingUp = true
                            self.setCharacterState = .climbing
                        }
                        climbAction = SKAction.moveBy(x: 0, y: stairHeight, duration: climblingDuration)
                        wait = SKAction.wait(forDuration: 0)
                        climbEnd = SKAction.run {
                            self.isClimbing = false
                            self.isClimbingUp = false
                            self.setCharacterState = self.previousCharacterState
                        }
                        climbSequence = SKAction.sequence([climbStart, climbAction, wait, climbEnd])
                        
                        characterImage.run(climbSequence)
                        
                    } else if isTouchingStairs && isCharacterAboveStairs && !isPushing && touchBeganLocation.y - touchEndedLocation.y < screenSize.height / 4 && !isClimbing {
                        
                        characterImage.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Crate | ColliderType.WinningFlag | ColliderType.Door
                        
                        climblingDuration = TimeInterval(stairHeight / 90)
                        
                        //Climb Down Actions
                        climbStart = SKAction.run {
                            self.isClimbing = true
                            self.setCharacterState = .climbing
                        }
                        climbAction = SKAction.moveBy(x: 0, y: -stairHeight, duration: climblingDuration)
                        wait = SKAction.wait(forDuration: 0)
                        climbEnd = SKAction.run {
                            self.isClimbing = false
                            self.setCharacterState = self.previousCharacterState
                        }
                        climbSequence = SKAction.sequence([climbStart, climbAction, wait, climbEnd])
                        
                        characterImage.run(climbSequence)
                        
                    } else if !isTouchingStairs && !isPushing && touchBeganLocation.y - touchEndedLocation.y > screenSize.height / 4 && isJumping == false {
                        let jumpStart = SKAction.run {
                            self.isJumping = true
                            self.setCharacterState = .jumping
                        }
                        let jumpAction = SKAction.run {
                            self.characterImage.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 75))
                        }
                        let wait = SKAction.wait(forDuration: 0.9)
                        let sound = music.playJump()
                        let group = SKAction.group([wait, sound])
                        let jumpEnd = SKAction.run {
                            self.isJumping = false
                            if self.isDead == true {
                                self.setCharacterState = .dead
                                self.characterImage.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: 60, height: 15))
                            } else {
                                self.setCharacterState = self.previousCharacterState
                            }
                            
                        }
                        
                        let jump = SKAction.sequence([jumpStart, jumpAction, group, jumpEnd])
                        characterImage.run(jump)
                    }

                } else if endedTouchOnScreen == "notValidTouch" {
                    break
                }
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
        
        updateFog()
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
        let speed: CGFloat = 0.015
        
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
        
        var sound = SKAction.wait(forDuration: 0.001)
        
        switch setCharacterState {
        case .idle:
            sound = SKAction.wait(forDuration: 0.001)
            frames = idleFrames
        case .jumping:
            sound = SKAction.wait(forDuration: 0.001)
            frames = jumpFrames
        case .running:
            sound = music.playRun()
            frames = runFrames
        case .walking:
            sound = music.playWalk()
            frames = walkFrames
        case .dead:
            frames = deadFrames
        case.climbing:
            frames = ladderFrames
        }
        
        characterFrames = frames
        let firstFrameTexture = characterFrames[0]
        characterImage.texture = firstFrameTexture

        let animate = SKAction.animate(with: characterFrames,
                                                              timePerFrame: 0.020,
                                                              resize: false,
                                                              restore: true)
        
        let repeatAnimation = SKAction.repeatForever(animate)
        let soundLoop = SKAction.sequence([sound,SKAction.wait(forDuration: 1.0)])
        let repeatSound = SKAction.repeatForever(soundLoop)
        let group = SKAction.group([repeatSound,repeatAnimation])
        
        
        characterImage.removeAction(forKey: "AnimatedWithSound")
        //Animate character
        characterImage.run(group, withKey: "AnimatedWithSound")
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
        // 0.35 calibrated by experimenting gameplay
        if abs(previousCameraPosition.x - currentCameraPosition.x) > 0.35 {
        
            //To let the background still while camera is moving
            let cameraMovimentX = (currentCameraPosition.x - previousCameraPosition.x)
            
            for i in 0...(backgrounds.count - 1) {
                
                let moveX = backgrounds[i].position.x + cameraMovimentX + -characterMoviment * backgroundsSpeed[i]
                
                backgrounds[i].position = CGPoint(x: moveX, y: backgrounds[i].position.y)
            }
        }
    }
    
    //MARK: Fog
    func createFog() {
        fog1.anchorPoint = CGPoint.zero
        fog1.position = CGPoint(x: 0, y: 0)
        fog1.zPosition = -5
        self.addChild(fog1)
        
        fog2.anchorPoint = CGPoint.zero
        fog2.position = CGPoint(x: fog1.size.width, y: 0)
        fog2.zPosition = -5
        self.addChild(fog2)
    }
    
    func updateFog() {
        fog1.position = CGPoint(x: fog1.position.x - 1.5, y: fog1.position.y)
        fog2.position = CGPoint(x: fog2.position.x - 1.5, y: fog2.position.y)
        
        if fog1.position.x < -fog1.size.width {
            fog1.position = CGPoint(x: fog1.position.x + fog1.size.width + fog2.size.width, y: fog2.position.y  )
        }
        
        if fog2.position.x < -fog2.size.width {
            fog2.position = CGPoint(x: fog2.position.x + fog2.size.width + fog1.size.width, y: fog1.position.y)
            
        }
        
    }
    
    func deadCharacter(inLevel: String) {
        let deadAnimation = SKAction.run {
            self.previousCharacterState = .dead
            self.setCharacterState = .dead
            self.characterImage.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: 60, height: 15))
        }
        let sound = music.playDeath()
        let wait = SKAction.wait(forDuration: 1.2)
        let restartAction = SKAction.run {
            self.restart(levelWithFileNamed: inLevel)
        }
        
        let deadSequence = SKAction.sequence([deadAnimation, sound, wait, restartAction])
        characterImage.run(deadSequence)
    }
    
}

