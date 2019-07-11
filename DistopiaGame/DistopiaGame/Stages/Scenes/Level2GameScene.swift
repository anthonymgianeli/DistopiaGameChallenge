

import SpriteKit
import GameplayKit

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
    var inContactWithCamera:Bool = false
    var laserCollected:Bool = false
    
    var useLaser = UITapGestureRecognizer()
    
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
        characterImage.physicsBody?.categoryBitMask = ColliderType.Character
        cameraLaserBody!.physicsBody?.categoryBitMask = ColliderType.Camera
        laser!.physicsBody?.categoryBitMask = ColliderType.Laser
        
        characterImage.physicsBody?.collisionBitMask = ColliderType.Ground
        //Operadores binários: AND(&), OR(|)
        //A soma dos valores sem carry tambem e valida para OR
        characterImage.physicsBody?.contactTestBitMask = ColliderType.Camera | ColliderType.Laser
        cameraLaserBody!.physicsBody?.contactTestBitMask = ColliderType.Character
        laser!.physicsBody?.contactTestBitMask = ColliderType.Character
        
//        useLaser = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
//        useLaser.numberOfTapsRequired = 2
//        self.view!.addGestureRecognizer(useLaser)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA == self.cameraLaserBody?.physicsBody && contact.bodyB == super.characterImage.physicsBody) ||
            (contact.bodyA == super.characterImage.physicsBody && contact.bodyB == self.cameraLaserBody?.physicsBody) {
            inContactWithCamera = true
//            self.cameraLaserBody?.isHidden = true
            //print("Encostou na camera!  \(inContactWithCamera)")
        }
        
        if (contact.bodyA == super.characterImage.physicsBody && contact.bodyB == self.ground?.physicsBody) ||
            (contact.bodyA == self.ground?.physicsBody && contact.bodyB == super.characterImage.physicsBody) {
            characterOnGround = true
            //print("true")
        }
        
        //Coleta laser
        if (contact.bodyA == super.characterImage.physicsBody && contact.bodyB == self.laser?.physicsBody) ||
            (contact.bodyA == self.laser?.physicsBody && contact.bodyB == super.characterImage.physicsBody) {
            self.laser?.removeFromParent()
            self.laserCollected = true
        }
        
    }
    
    
    func didEnd(_ contact: SKPhysicsContact) {
        if (contact.bodyA == self.cameraLaserBody?.physicsBody && contact.bodyB == super.characterImage.physicsBody) ||
            (contact.bodyA == super.characterImage.physicsBody && contact.bodyB == self.cameraLaserBody?.physicsBody){
             inContactWithCamera = false
            //print("Ta fora!  \(inContactWithCamera)")
        }
        
        if (contact.bodyA == super.characterImage.physicsBody && contact.bodyB == self.ground?.physicsBody) ||
            (contact.bodyA == self.ground?.physicsBody && contact.bodyB == characterImage.physicsBody) {
            characterOnGround = false
            //print("false")
        }
    }

    
//    @objc func doubleTap(_ sender: UITapGestureRecognizer) {
//        //verificar lado da tela
//        if laserCollected {
//            //action do laser piscar
//            let showLaser = SKAction.run {
//                self.laserAtivated?.isHidden = false
//            }
//            let wait = SKAction.wait(forDuration: 0.1)
//            let hideLaser = SKAction.run {
//                self.laserAtivated?.isHidden = true
//            }
//            let sequence = SKAction.sequence([showLaser, wait, hideLaser])
//            characterImage.run(sequence)
//
//            //verificacao se personagem esta no intervalo de alcance da camera
//            let intervalX = CGFloat((self.cameraAnchor?.position.x)!) - CGFloat((self.characterImage.position.x))
//            if intervalX > 130 && intervalX < 150 && super.direction == 1 {
//                self.cameraLaserBody?.removeFromParent()
//            }
//        }
//    }
    

}

