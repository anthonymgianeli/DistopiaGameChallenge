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

//MARK: Animate character
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

func ladderCharacter() {
    var characterTexture = SKTextureAtlas()
    characterTexture = SKTextureAtlas(named: "31")
    let numImages = characterTexture.textureNames.count
    
    for i in 0...(numImages - 1) {
        let characterTextureName = i < 10 ? "31_00\(i)" : "31_0\(i)"
        ladderFrames.append(characterTexture.textureNamed(characterTextureName))
    }
}

func pullCharacter() {
    var characterTexture = SKTextureAtlas()
    characterTexture = SKTextureAtlas(named: "22")
    let numImages = characterTexture.textureNames.count
    
    for i in 0...(numImages - 1) {
        let characterTextureName = i < 10 ? "22_00\(i)" : "22_0\(i)"
        pullFrames.append(characterTexture.textureNamed(characterTextureName))
    }
}

func pushCharacter() {
    var characterTexture = SKTextureAtlas()
    characterTexture = SKTextureAtlas(named: "21")
    let numImages = characterTexture.textureNames.count
    
    for i in 0...(numImages - 1) {
        let characterTextureName = i < 10 ? "21_00\(i)" : "21_0\(i)"
        pushFrames.append(characterTexture.textureNamed(characterTextureName))
    }
}

func animateAssets() {
    idleCharacter()
    runningCharacter()
    walkingCharacter()
    deadCharacter()
    jumpingCharacter()
    ladderCharacter()
    pullCharacter()
    pushCharacter()
    
}

class LoadGame: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        animateAssets()
        firstLevel()
    }
    
    func firstLevel(){
        let firstLevel = Level1GameScene(fileNamed: "Level1GameScene")!
        firstLevel.scaleMode = scaleMode
        let reveal = SKTransition.fade(with: .black, duration: 0.5)
        view?.presentScene(firstLevel, transition: reveal)
    }
    
}
