//
//  LoopingVideoView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI
import AVFoundation

struct LoopingVideoView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        guard let url = Bundle.main.url(forResource: "IMG_4012", withExtension: "mp4") else {
            return view
        }

        let player = AVPlayer(url: url)
        player.isMuted = true
        player.actionAtItemEnd = .none
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = UIScreen.main.bounds
        playerLayer.setAffineTransform(CGAffineTransform(scaleX: 1.2, y: 1.4)) // Keep your zoom effect

        view.layer.addSublayer(playerLayer)

        // Loop the video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }

        player.play()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
