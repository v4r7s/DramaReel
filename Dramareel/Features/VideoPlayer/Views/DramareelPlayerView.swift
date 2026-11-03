import SwiftUI
import AVFoundation

public struct DramareelPlayerView: UIViewControllerRepresentable {
    public let player: AVPlayer?
    
    public init(player: AVPlayer?) {
        self.player = player
    }
    
    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        controller.view.backgroundColor = .black
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player !== player {
            uiViewController.player = player
        }
    }
}
