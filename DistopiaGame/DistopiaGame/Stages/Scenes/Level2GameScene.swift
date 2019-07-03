

import SpriteKit
import GameplayKit

class Level2GameScene: SKScene {
    
    //    private var lightNode = SKLightNode()
    //    private var background = SKSpriteNode(imageNamed: "fundo")
    var cameraImage: SKSpriteNode?
    var lightNode: SKLightNode?
    var lamp: SKSpriteNode?
    var character: SKSpriteNode?
    
    
    
    override func didMove(to view: SKView) {
        self.character = self.childNode(withName: "character2") as? SKSpriteNode
        self.cameraImage = childNode(withName: "Camera") as? SKSpriteNode
        
        let rotateAnti = SKAction.rotate(byAngle: .pi/6, duration: 0.7)
        let rotateClockwise = SKAction.rotate(byAngle: -(.pi/6), duration: 0.7)
        let sequence = SKAction.sequence([rotateClockwise, rotateAnti])
        let repeatAction = SKAction.repeatForever(sequence)
        cameraImage!.run(repeatAction)
        
        
        //      Ponto de luz
        //        background.size = CGSize(width: self.size.height, height: self.size.height)
        ////        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ////        background.position = CGPoint(x: self.size.width/2, y:self.size.height/2)
        ////        background.zPosition = -1
        //
        //
        //        background.lightingBitMask = 1
        //        background.shadowCastBitMask = 0
        //        background.shadowedBitMask = 1
        //        addChild(background)
        //
        
        //self.lightNode = childNode(withName: "Light") as? SKLightNode
        //        lightNode!.categoryBitMask = 1
        //        lightNode!.falloff = 0
        //        lightNode!.ambientColor = UIColor.white
        //        lightNode!.lightColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.5)
        //        lightNode!.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        //        lightNode!.setScale(50)
        
        
    }
    
    //Testar se funciona
    //Inverter if - não sei qual é o A  e o B (?)
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA == self.cameraImage && contact.bodyB == self.character {
            print("Encostou na camera!")
        }
    }
    
}
