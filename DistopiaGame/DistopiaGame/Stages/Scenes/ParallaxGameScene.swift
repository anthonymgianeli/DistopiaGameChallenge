//
//  ParallaxGameScene.swift
//  DistopiaGame
//
//  Created by anthony gianeli on 03/07/19.
//  Copyright © 2019 anthony.gianeli. All rights reserved.
//

import SpriteKit
import GameplayKit

class ParallaxGameScene: SKScene {
    
    var character: SKSpriteNode?
    var movingTouch: CGPoint!
    var firstTouch: CGPoint!
    var movingCenter: CGPoint!
    var movimentConstant: CGFloat = 20
    let screenSize: CGRect = UIScreen.main.bounds
    var parallaxComponentSystem: GKComponentSystem<ParallaxComponent>?
    var entities = [GKEntity]()
    
    override func didMove(to view: SKView) {
        
        parallaxComponentSystem = GKComponentSystem.init(componentClass: ParallaxComponent.self)
        
        for _ in self.entities {
            parallaxComponentSystem?.addComponent(foundIn: entity!)
        }
        
        for component in (parallaxComponentSystem?.components)! {
            component.prepareWith(camera: camera)
        }
        
        self.character = self.childNode(withName: "character") as? SKSpriteNode
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(jump(_:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
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
            
            if Double(movingTouch.x) > Double(movingCenter.x) {
                moveRight()
                movingCenter.x = movingTouch.x - 0.1
            } else if Double(movingTouch.x) < Double(movingCenter.x) {
                moveLeft()
                movingCenter.x = movingTouch.x + 0.1
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
    
    @objc func jump(_ sender: UISwipeGestureRecognizer) {
        let jump = SKAction.moveBy(x: 0, y: 10, duration: 1)
        character?.run(jump)
    }
    
    override func update(_ currentTime: TimeInterval) {
        parallaxComponentSystem?.update(deltaTime: currentTime)
    }
    
}
