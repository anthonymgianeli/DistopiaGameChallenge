

import SpriteKit
import GameplayKit

struct ColliderType {
    static let None: UInt32 = 0
    static let Character: UInt32 = 1
    static let Camera: UInt32 = 2
    static let Ground: UInt32 = 4
}

class Level2GameScene: SKScene, SKPhysicsContactDelegate {
    var cameraImage: SKSpriteNode?
    var cameraBody: SKSpriteNode?
    var lightNode: SKLightNode?
    var lamp: SKSpriteNode?
    var character: SKSpriteNode?
    var ground: SKSpriteNode?
    
    var characterOnGround:Bool = true
    
    var movingTouch: CGPoint!
    var firstTouch: CGPoint!
    var movingCenter: CGPoint!
    var movimentConstant: CGFloat = 20
    let screenSize: CGRect = UIScreen.main.bounds
    
    var count:Int = 0
    
    
    
    override func didMove(to view: SKView) {
        self.character = self.childNode(withName: "character2") as? SKSpriteNode
        self.cameraImage = childNode(withName: "Camera") as? SKSpriteNode
        self.ground = childNode(withName: "ground2") as? SKSpriteNode
        self.cameraBody = cameraImage!.childNode(withName: "CameraBody") as? SKSpriteNode
        
//        let center = SKSpriteNode()
//        center.position = CGPoint(x: -358.468, y: 204.451)
//        cameraImage!.addChild(center)

        
        let rotateAnti = SKAction.rotate(byAngle: .pi/6, duration: 0.7)
        let rotateClockwise = SKAction.rotate(byAngle: -(.pi/6), duration: 0.7)
        let sequence = SKAction.sequence([rotateClockwise, rotateAnti])
        let repeatAction = SKAction.repeatForever(sequence)
        cameraImage!.run(repeatAction)
        
        
        physicsWorld.contactDelegate = self
        character!.physicsBody?.categoryBitMask = ColliderType.Character
        cameraBody!.physicsBody?.categoryBitMask = ColliderType.Camera
        character!.physicsBody?.collisionBitMask = ColliderType.Ground
        //Operadores binários: AND(&), OR(|)
        //A soma dos valores sem carry tambem e valida para OR
        character!.physicsBody?.contactTestBitMask = ColliderType.Camera
        cameraBody!.physicsBody?.contactTestBitMask = ColliderType.Character
    
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA == self.cameraBody?.physicsBody && contact.bodyB == self.character?.physicsBody) ||
            (contact.bodyA == self.character?.physicsBody && contact.bodyB == self.cameraBody?.physicsBody) {
            count+=1
            print("Encostou na camera!  \(count)")
        }
        
        if (contact.bodyA == self.character?.physicsBody && contact.bodyB == self.ground?.physicsBody) ||
            (contact.bodyA == self.ground?.physicsBody && contact.bodyB == self.character?.physicsBody) {
            characterOnGround = true
            print("true")
        }
        
    }
    
    
    func didEnd(_ contact: SKPhysicsContact) {
        if (contact.bodyA == self.cameraBody?.physicsBody && contact.bodyB == self.character?.physicsBody) ||
            (contact.bodyA == self.character?.physicsBody && contact.bodyB == self.cameraBody?.physicsBody){
            print("Ta fora!")
        }
        
        if (contact.bodyA == self.character?.physicsBody && contact.bodyB == self.ground?.physicsBody) ||
            (contact.bodyA == self.ground?.physicsBody && contact.bodyB == self.character?.physicsBody) {
            characterOnGround = false
            print("false")
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

//            if Double(movingTouch.x) > Double(movingCenter.x) {
//                moveRight()
//                movingCenter.x = movingTouch.x - 0.1
//            } else if Double(movingTouch.x) < Double(movingCenter.x) {
//                moveLeft()
//                movingCenter.x = movingTouch.x + 0.1
//            } else if Double(movingTouch.y) != Double(movingCenter.y)
            if characterOnGround {
                jump()

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
    
    @objc func jump() {
        character!.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 5))
        
//        let minX: CGFloat = 200 // some suitable value
//        let multiplier: CGFloat = 5
//        let force = max(0, (character!.position.x / minX - 1) * multiplier)
//        character!.physicsBody?.applyImpulse(CGVector(dx: -force, dy: 0))
        
//        let jump = SKAction.moveBy(x: 0, y: 50, duration: 1)
//        let moveRight = SKAction.moveBy(x: 50 , y: 0, duration: 0.5)
//        let group = SKAction.group([jump, moveRight])
//        character?.run(group)
    }
    
}

