

import SpriteKit
import GameplayKit

struct ColliderType {
    static let None: UInt32 = 0
    static let Character: UInt32 = 1
    static let Camera: UInt32 = 2
    static let Ground: UInt32 = 4
    static let Laser: UInt32 = 8
}

class Level2GameScene: LevelGameScene, SKPhysicsContactDelegate {
    var cameraAnchor: SKSpriteNode?
    var cameraImage: SKSpriteNode?
    var cameraLaserBody: SKSpriteNode?
    var lightNode: SKLightNode?
    var lamp: SKSpriteNode?
    var ground: SKSpriteNode?
    var laser: SKSpriteNode?
    var laserAtivated: SKSpriteNode?
    var laserButton: SKSpriteNode?
    
    var characterOnGround:Bool = true
    
    var movingTouch: CGPoint!
    var firstTouch: CGPoint!
    var movingCenter: CGPoint!
    var movimentConstant: CGFloat = 20
    
    var inContactWithCamera:Bool = false
    
    var useLaser = UITapGestureRecognizer()
    var aimTarget = UIPanGestureRecognizer()
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.cameraAnchor = childNode(withName: "CameraAnchor") as? SKSpriteNode
        self.cameraImage = cameraAnchor!.childNode(withName: "CameraImage") as? SKSpriteNode
        self.cameraLaserBody = cameraAnchor!.childNode(withName: "CameraLaserBody") as? SKSpriteNode
        self.ground = childNode(withName: "ground2") as? SKSpriteNode
        self.laser = childNode(withName: "Laser") as? SKSpriteNode
        self.laserButton = childNode(withName: "laserButton") as? SKSpriteNode
        self.laserAtivated = characterImage.childNode(withName: "laserActivated") as? SKSpriteNode
        self.laserAtivated?.isHidden = true
        

        
        let rotateAnti = SKAction.rotate(byAngle: .pi/6, duration: 0.7)
        let rotateClockwise = SKAction.rotate(byAngle: -(.pi/6), duration: 0.7)
        let sequence = SKAction.sequence([rotateClockwise, rotateAnti])
        let repeatAction = SKAction.repeatForever(sequence)
        cameraAnchor!.run(repeatAction)
        
        
        physicsWorld.contactDelegate = self
        characterBody.physicsBody?.categoryBitMask = ColliderType.Character
        cameraLaserBody!.physicsBody?.categoryBitMask = ColliderType.Camera
        laser!.physicsBody?.categoryBitMask = ColliderType.Laser
        characterBody.physicsBody?.collisionBitMask = ColliderType.Ground
        //Operadores binários: AND(&), OR(|)
        //A soma dos valores sem carry tambem e valida para OR
        characterBody.physicsBody?.contactTestBitMask = ColliderType.Camera | ColliderType.Laser
        cameraLaserBody!.physicsBody?.contactTestBitMask = ColliderType.Character
        laser!.physicsBody?.contactTestBitMask = ColliderType.Character
        
        useLaser = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        useLaser.numberOfTapsRequired = 2
        self.view!.addGestureRecognizer(useLaser)

        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA == self.cameraLaserBody?.physicsBody && contact.bodyB == super.characterBody.physicsBody) ||
            (contact.bodyA == super.characterBody.physicsBody && contact.bodyB == self.cameraLaserBody?.physicsBody) {
            inContactWithCamera = true
            self.cameraLaserBody?.isHidden = true
            //print("Encostou na camera!  \(inContactWithCamera)")
        }
        
        if (contact.bodyA == super.characterBody.physicsBody && contact.bodyB == self.ground?.physicsBody) ||
            (contact.bodyA == self.ground?.physicsBody && contact.bodyB == super.characterBody.physicsBody) {
            characterOnGround = true
            //print("true")
        }
        
        if (contact.bodyA == super.characterBody.physicsBody && contact.bodyB == self.laser?.physicsBody) ||
            (contact.bodyA == self.laser?.physicsBody && contact.bodyB == super.characterBody.physicsBody) {
            self.laser?.removeFromParent()
        }
        
    }
    
    
    func didEnd(_ contact: SKPhysicsContact) {
        if (contact.bodyA == self.cameraLaserBody?.physicsBody && contact.bodyB == super.characterBody.physicsBody) ||
            (contact.bodyA == super.characterBody.physicsBody && contact.bodyB == self.cameraLaserBody?.physicsBody){
             inContactWithCamera = false
            //print("Ta fora!  \(inContactWithCamera)")
        }
        
        if (contact.bodyA == super.characterBody.physicsBody && contact.bodyB == self.ground?.physicsBody) ||
            (contact.bodyA == self.ground?.physicsBody && contact.bodyB == super.characterBody.physicsBody) {
            characterOnGround = false
            //print("false")
        }
    }
    
//    //inContactWithCamera - Importante para escada diferenciar pulo de subida
//    override func swipe(_ gesture: UISwipeGestureRecognizer, isInContact: Bool) {
//        super.swipe(gesture, isInContact: inContactWithCamera)
//    }
//
//    //inContactWithCamera - Importante para verificar contato com objetos carregáveis
//    override func longPress(_ gesture: UILongPressGestureRecognizer, isInContact: Bool) {
//         super.longPress(gesture, isInContact: inContactWithCamera)
//    }
    
    @objc func doubleTap(_ sender: UITapGestureRecognizer) {
//        var post = sender.location(in: sender.view)
//        post = convertPoint(fromView: post)
//        let touchNode = self.atPoint(post)

        self.laserAtivated?.isHidden = false
        
    }
    

}

