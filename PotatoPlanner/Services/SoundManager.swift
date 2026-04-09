//
//  SoundManager.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 4/3/26.
//

// Music by Dvir Silverstone from Pixabay

import Foundation
import AVFoundation

@MainActor
class SoundManager {
    static let shared = SoundManager()

    private var soundEffectPlayer: AVAudioPlayer?
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var rainMusicPlayer: AVAudioPlayer?

    private init() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
        #endif
    }

    func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "m4a") else {
            print("sound file not found: \(soundName)")
            return
        }
        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            soundEffectPlayer?.volume = 3
            soundEffectPlayer?.play()
        } catch {
            print("error playing sound: \(error.localizedDescription)")
        }
    }

    func playBGM(volume: Float) {
        guard let url = Bundle.main.url(forResource: "sonican_acoustic_loop", withExtension: "mp3") else { return }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1
            backgroundMusicPlayer?.volume = volume
            backgroundMusicPlayer?.play()
        } catch {
            print("error playing BGM: \(error.localizedDescription)")
        }
    }

    func stopBGM() {
        backgroundMusicPlayer?.stop()
    }

    func setBGMVolume(_ volume: Float) {
        backgroundMusicPlayer?.volume = volume
    }

    func playRain(volume: Float) {
        guard let url = Bundle.main.url(forResource: "rain_sound", withExtension: "mp3") else { return }
        do {
            rainMusicPlayer = try AVAudioPlayer(contentsOf: url)
            rainMusicPlayer?.numberOfLoops = -1
            rainMusicPlayer?.volume = volume
            rainMusicPlayer?.play()
        } catch {
            print("error playing rain: \(error.localizedDescription)")
        }
    }

    func stopRain() {
        rainMusicPlayer?.stop()
    }

    func setRainVolume(_ volume: Float) {
        rainMusicPlayer?.volume = volume
    }
}
