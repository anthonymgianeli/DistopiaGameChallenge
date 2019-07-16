//
//  Music.swift
//  DistopiaGame
//
//  Created by Luma Gabino Vasconcelos on 14/07/19.
//  Copyright © 2019 anthony.gianeli. All rights reserved.
//

import Foundation
import AVFoundation
import SpriteKit

class Music {
    var audioPlayer = AVAudioPlayer()
    var clickAudio = SKAction.playSoundFileNamed("Click.wav", waitForCompletion: false)
    var walkAudio = SKAction.playSoundFileNamed("Click.wav", waitForCompletion: false)
    var runAudio = SKAction.playSoundFileNamed("Click.wav", waitForCompletion: false)
    var deathAudio = SKAction.playSoundFileNamed("Death.wav", waitForCompletion: false)
    var jumpAudio = SKAction.playSoundFileNamed("Jump.wav", waitForCompletion: false)

    func playingSoundWith(fileName: String, type: String) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: fileName, withExtension: type)!)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            audioPlayer.volume = 0.4
            audioPlayer.numberOfLoops = -1
        } catch {
            print(error)
        }
    }
    
    func playClick() -> SKAction {
        return clickAudio
    }
    func playWalk() -> SKAction {
        return walkAudio
    }
    func playRun() -> SKAction {
        return runAudio
    }
    func playDeath() -> SKAction {
        return deathAudio
    }
    func playJump() -> SKAction {
        return jumpAudio
    }
}
