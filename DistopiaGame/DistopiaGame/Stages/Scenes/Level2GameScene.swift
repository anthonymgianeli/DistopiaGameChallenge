

import SpriteKit
import GameplayKit

class Level2GameScene: LevelGameScene, SKPhysicsContactDelegate {
    var cameraAnchor: SKSpriteNode?
    var cameraImage: SKSpriteNode?
    var cameraLaserBody: SKSpriteNode?
    var ground: SKSpriteNode?
    var laser: SKSpriteNode?
    var laserAtivated: SKSpriteNode?
    var light: SKLightNode?
    var lamp:  SKSpriteNode?
    var triangle:  SKSpriteNode?
    
    var characterOnGround:Bool = true
    var laserCollected:Bool = false
    
    var useLaser = UITapGestureRecognizer()
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        view.isUserInteractionEnabled = true
        
        self.cameraAnchor = childNode(withName: "CameraAnchor") as? SKSpriteNode
        self.cameraImage = cameraAnchor!.childNode(withName: "CameraImage") as? SKSpriteNode
        self.cameraLaserBody = cameraAnchor!.childNode(withName: "CameraLaserBody") as? SKSpriteNode
        self.ground = childNode(withName: "ground2") as? SKSpriteNode
        self.laser = childNode(withName: "Laser") as? SKSpriteNode
        self.laserAtivated = characterImage.childNode(withName: "laserActivated") as? SKSpriteNode
        self.laserAtivated?.isHidden = true
        self.light = childNode(withName: "Light") as? SKLightNode
        self.lamp = childNode(withName: "Lamp") as? SKSpriteNode
        self.triangle = childNode(withName: "Triangle") as? SKSpriteNode
        
        rotateCamera()
        lightConfig()
        
        //Tratamento das colisoes/contato
        physicsWorld.contactDelegate = self
        characterImage.physicsBody?.categoryBitMask = ColliderType.Character
        cameraLaserBody!.physicsBody?.categoryBitMask = ColliderType.Camera
        laser!.physicsBody?.categoryBitMask = ColliderType.Laser
        characterImage.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Wall
        //Operadores binários: AND(&), OR(|)
        //A soma dos valores sem carry tambem e valida para OR
        characterImage.physicsBody?.contactTestBitMask = ColliderType.Camera | ColliderType.Laser
        cameraLaserBody!.physicsBody?.contactTestBitMask = ColliderType.Character
        laser!.physicsBody?.contactTestBitMask = ColliderType.Character
        
        useLaser = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        useLaser.numberOfTapsRequired = 2
        self.view!.addGestureRecognizer(useLaser)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //Verifica contato com o foco da camera, caso exista reinicia a fase
        if (contact.bodyA == self.cameraLaserBody?.physicsBody && contact.bodyB == super.characterImage.physicsBody) ||
            (contact.bodyA == super.characterImage.physicsBody && contact.bodyB == self.cameraLaserBody?.physicsBody) {
            
            deadCharacter(inLevel: "Level2GameScene")
        }
        
        if (contact.bodyA == super.characterImage.physicsBody && contact.bodyB == self.ground?.physicsBody) ||
            (contact.bodyA == self.ground?.physicsBody && contact.bodyB == super.characterImage.physicsBody) {
            characterOnGround = true
        }
        
        //Coleta laser
        if (contact.bodyA == super.characterImage.physicsBody && contact.bodyB == self.laser?.physicsBody) ||
            (contact.bodyA == self.laser?.physicsBody && contact.bodyB == super.characterImage.physicsBody) {
            self.laser?.removeFromParent()
            self.laserCollected = true
        }
        
    }
    
    
    func didEnd(_ contact: SKPhysicsContact) {
        if (contact.bodyA == super.characterImage.physicsBody && contact.bodyB == self.ground?.physicsBody) ||
            (contact.bodyA == self.ground?.physicsBody && contact.bodyB == characterImage.physicsBody) {
            characterOnGround = false
        }
    }
   
    @objc func doubleTap(_ sender: UITapGestureRecognizer) {
        //Verifica lado da tela
        if sender.location(in: self.view).x > middleScreen {
            if laserCollected {
                //Acao do laser piscar
                let sound = super.music.playClick()
                let showLaser = SKAction.run {
                    self.laserAtivated?.isHidden = false
                }
                let wait = SKAction.wait(forDuration: 0.1)
                let hideLaser = SKAction.run {
                    self.laserAtivated?.isHidden = true
                }
                let sequence = SKAction.sequence([showLaser, sound, wait, hideLaser])
                characterImage.run(sequence)
                
                //Verificacao se personagem esta no intervalo de alcance da camera
                let intervalX = CGFloat((self.cameraAnchor?.position.x)!) - CGFloat((self.characterImage.position.x))
                if intervalX > 130 && intervalX < 150 && super.direction == 1 {
                    self.cameraLaserBody?.removeFromParent()
                }
            }
        }
    }
    
    func rotateCamera() {
        //Movimentacao da camera - rotacao em torno do node(pai)
        //cujo anchorPoint esta deslocado
        let rotateAnti = SKAction.rotate(byAngle: .pi/6, duration: 0.7)
        let rotateClockwise = SKAction.rotate(byAngle: -(.pi/6), duration: 0.7)
        let sequence = SKAction.sequence([rotateClockwise, rotateAnti])
        let repeatAction = SKAction.repeatForever(sequence)
        cameraAnchor!.run(repeatAction)
    }
    
    func lightConfig() {
        light?.lightColor = .white
        light?.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        triangle?.lightingBitMask = 0b0001
        triangle?.shadowCastBitMask = 0b0001
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        if characterImage.position.x > (screenSize.width * 0.9) {
            restart(levelWithFileNamed: "Level1GameScene")
        } 
    }

}

