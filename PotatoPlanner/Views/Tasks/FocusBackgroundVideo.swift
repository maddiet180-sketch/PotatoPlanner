//
//  FocusBackgroundVideo.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/13/26.
//

import AVKit
import SwiftUI

struct FocusBackgroundVideo: UIViewRepresentable {

    let duration: Double
    let initialProgress: Double
    let isPaused: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(duration: duration, initialProgress: initialProgress)
    }

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        context.coordinator.setup(view: view)
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        if isPaused {
            context.coordinator.player?.pause()
        } else {
            context.coordinator.player?.play()
        }
    }

    class Coordinator {
        let duration: Double
        let initialProgress: Double
        var player: AVPlayer?

        init(duration: Double, initialProgress: Double) {
            self.duration = duration
            self.initialProgress = initialProgress
        }

        func setup(view: PlayerView) {
            guard let url = Bundle.main.url(forResource: "focus_animation", withExtension: "mp4") else { return }

            Task {
                let asset = AVURLAsset(url: url)

                guard let videoTrack = try? await asset.loadTracks(withMediaType: .video).first,
                      let videoDuration = try? await asset.load(.duration) else { return }

                let composition = AVMutableComposition()
                guard let compositionTrack = composition.addMutableTrack(
                    withMediaType: .video,
                    preferredTrackID: kCMPersistentTrackID_Invalid
                ) else { return }

                let sourceRange = CMTimeRange(start: .zero, duration: videoDuration)
                try? compositionTrack.insertTimeRange(sourceRange, of: videoTrack, at: .zero)

                let targetDuration = CMTime(seconds: self.duration, preferredTimescale: 600)
                compositionTrack.scaleTimeRange(sourceRange, toDuration: targetDuration)

                let player = AVPlayer(playerItem: AVPlayerItem(asset: composition))

                if self.initialProgress > 0 {
                    let seekTime = CMTime(seconds: self.initialProgress, preferredTimescale: 600)
                    await player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
                }

                await MainActor.run {
                    self.player = player
                    view.playerLayer.player = player
                    view.playerLayer.videoGravity = .resizeAspectFill
                    player.play()
                }
            }
        }
    }
}

class PlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}
