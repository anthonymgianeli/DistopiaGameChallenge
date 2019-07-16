//
//  AssestsAnimation.swift
//  DistopiaGame
//
//  Created by Julia Conti Mestre on 15/07/19.
//  Copyright © 2019 anthony.gianeli. All rights reserved.
//

import Foundation
import SpriteKit

var idleFrames: [SKTexture] = [] //01
var walkFrames: [SKTexture] = [] //02
var runFrames: [SKTexture] = [] //03
var jumpFrames: [SKTexture] = [] //04 e 05
var ladderFrames: [SKTexture] = [] //31
var pullFrames: [SKTexture] = [] //22
var pushFrames: [SKTexture] = [] //21
var deadFrames: [SKTexture] = [] //27

func idleCharacter() {
    var characterTexture = SKTextureAtlas()
    characterTexture = SKTextureAtlas(named: "01")
    let numImages = characterTexture.textureNames.count
    
    for i in 0...(numImages - 1) {
        let characterTextureName = i < 10 ? "01_00\(i)" : "01_0\(i)"
        idleFrames.append(characterTexture.textureNamed(characterTextureName))
    }
    
}

func jumpingCharacter() {
    var characterTextureUp = SKTextureAtlas()
    var characterTextureDown = SKTextureAtlas()
    characterTextureUp = SKTextureAtlas(named: "04")
    characterTextureDown = SKTextureAtlas(named: "05")
    let numImagesUp = characterTextureUp.textureNames.count
    let numImagesDown = characterTextureDown.textureNames.count

    for i in 0...(numImagesUp - 1) {
        let characterTextureName = i < 10 ? "04_00\(i)" : "04_0\(i)"
        jumpFrames.append(characterTextureUp.textureNamed(characterTextureName))
    }

    for i in 0...(numImagesDown - 1) {
        let characterTextureName = i < 10 ? "05_00\(i)" : "05_0\(i)"
        jumpFrames.append(characterTextureDown.textureNamed(characterTextureName))
    }

}

func runningCharacter() {
    var characterTexture = SKTextureAtlas()
    characterTexture = SKTextureAtlas(named: "03")
    let numImages = characterTexture.textureNames.count

    for i in 0...(numImages - 1) {
        let characterTextureName = i < 10 ? "03_00\(i)" : "03_0\(i)"
        runFrames.append(characterTexture.textureNamed(characterTextureName))
    }
}

func walkingCharacter() {
    var characterTexture = SKTextureAtlas()
    characterTexture = SKTextureAtlas(named: "02")
    let numImages = characterTexture.textureNames.count

    for i in 0...(numImages - 1) {
        let characterTextureName = i < 10 ? "02_00\(i)" : "02_0\(i)"
        walkFrames.append(characterTexture.textureNamed(characterTextureName))
    }
}

func deadCharacter() {
    var characterTexture = SKTextureAtlas()
    characterTexture = SKTextureAtlas(named: "27")
    let numImages = characterTexture.textureNames.count
    
    for i in 0...(numImages - 1) {
        let characterTextureName = i < 10 ? "27_00\(i)" : "27_0\(i)"
        deadFrames.append(characterTexture.textureNamed(characterTextureName))
    }
    
}

func animateAssets() {
    idleCharacter()
    
    runningCharacter()
    walkingCharacter()
    deadCharacter()
    jumpingCharacter()
    
}

class loadGame: SKScene {
    
    override func didMove(to view: SKView) {
        animateAssets()
        firstLevel(levelWithFileNamed: "Level1GameScene")
    }
    
    func firstLevel(levelWithFileNamed: String){
        if let view = self.view as SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: levelWithFileNamed) {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                let animation = SKTransition.fade(withDuration: 1.0)
                // Present the scene
                view.presentScene(scene, transition: animation)
            }
        }
    }

}
