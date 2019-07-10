//
//  StairsGameScene.swift
//  DistopiaGame
//
//  Created by Julia Conti Mestre on 01/07/19.
//  Copyright © 2019 anthony.gianeli. All rights reserved.
//

import SpriteKit
import GameplayKit

class Level1GameScene: LevelGameScene {
    
    var background1 = SKSpriteNode()
    var background2 = SKSpriteNode()
    var background3 = SKSpriteNode()
    var background4 = SKSpriteNode()
    
    var backgrounds = [SKSpriteNode()]
    var backgroundsYPosition = [SKSpriteNode().position.y]
    
    let cameraNode = SKCameraNode()
    var previousCameraPosition = CGPoint.zero
    var currentCameraPosition = CGPoint.zero
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        setUpCamera()
        setUpBackground()

    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        moveCamera(rightScreenEdge: size.width * 2)

    }
    
    func setUpCamera() {
        addChild(cameraNode)
        camera = cameraNode
        camera?.position.x = size.width / 2
        camera?.position.y = size.height / 2
        previousCameraPosition.x = camera?.position.x ?? 0
        previousCameraPosition.y = camera?.position.y ?? 0
    }
    
    func setUpBackground() {
        self.background1 = self.childNode(withName: "background1") as! SKSpriteNode
        self.background2 = self.childNode(withName: "background2") as! SKSpriteNode
        self.background3 = self.childNode(withName: "background3") as! SKSpriteNode
        self.background4 = self.childNode(withName: "background4") as! SKSpriteNode
        
        backgrounds = [background1, background2, background3, background4]
        backgroundsYPosition = [background1.position.y, background2.position.y, background3.position.y, background4.position.y]
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
    
    func moveCamera(rightScreenEdge: CGFloat) {
        //Left screen edge
        if character.position.x < size.width / 2 { //don't move camera
            camera?.position.x = size.width / 2
            
        //Right screen edge - Depends on the level size
        } else if character.position.x > rightScreenEdge - size.width / 2 { //stop moving camera
            camera?.position.x = rightScreenEdge - size.width / 2
            
        //Move camera according to character position
        } else {
            camera?.position.x = character.position.x
            currentCameraPosition.x = camera?.position.x ?? 0
            
            parallaxInXDirection()
            
            previousCameraPosition.x = currentCameraPosition.x
        }
        
        //Move camera in y direction
        if character.position.y > size.height / 2 {
            camera?.position.y = character.position.y
            currentCameraPosition.y = camera?.position.y ?? 0
            
            let background1Speed: CGFloat = 0.1
            let background2Speed: CGFloat = 0.3
            let background3Speed: CGFloat = 0.5
            let background4Speed: CGFloat = 0.7
            
            let backgroundsSpeed = [background1Speed, background2Speed, background3Speed, background4Speed]
            
            if previousCameraPosition.y != currentCameraPosition.y {
                // to let the background still while camera is moving
                let cameraMovimentY = (currentCameraPosition.y - previousCameraPosition.y)

                for i in 0...(backgrounds.count - 1) {
                    let moveY = backgrounds[i].position.y + cameraMovimentY * backgroundsSpeed[i]

                    backgrounds[i].position = CGPoint(x: backgrounds[i].position.x, y: moveY)
                }
            }
            
        //Don't move camera
        } else {
            camera?.position.y = size.height / 2
            
            for i in 0...(backgrounds.count - 1) {
                backgrounds[i].position.y = backgroundsYPosition[i]
            }
            
        }
    }
    
}
