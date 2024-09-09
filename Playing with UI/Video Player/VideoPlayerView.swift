//
//  VideoPlayerView.swift
//  VideoPlayerView 2
//
//  Created by Blake Whitmer on 5/26/24.
//


import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @State var player: AVQueuePlayer
    let videoInfo: VideoInfo // Assuming VideoInfo contains the URL and other metadata
    @State private var isCurrentVideo = false
    @State private var isDoubleSpeed = false
    private var looper: AVPlayerLooper?
    
    @State private var isPaused = false

    init(player: AVPlayer, videoInfo: VideoInfo) {
        let queuePlayer = AVQueuePlayer(items: [AVPlayerItem(asset: player.currentItem!.asset)])
        self._player = State(initialValue: queuePlayer)
        self.videoInfo = videoInfo

        let playerItem = AVPlayerItem(url: videoInfo.url)
        let playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        self.looper = playerLooper
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.black)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                .onTapGesture {
                    print("tap gesture")
                    togglePlayPause()
                }
            
            GeometryReader { proxy in
                let screenCenterY = UIScreen.main.bounds.midY
                let viewCenterY = proxy.frame(in: .global).midY
                let threshold = UIScreen.main.bounds.height / 2  // Half of the screen height

                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 100.0, height: 100.0)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                    .onChange(of: viewCenterY) { oldValue, newValue in
                        if abs(newValue - screenCenterY) <= threshold {
                            if !isCurrentVideo && !isPaused {
                                print("View is near the center of the screen")
                                player.play()
                                isCurrentVideo = true
                            }
                        } else {
                            if isCurrentVideo {
                                print("View is not near the center of the screen")
                                player.pause()
                                player.seek(to: .zero)
                                isCurrentVideo = false
                                isPaused = false
                            }
                        }
                    }
            }
            
            
            VideoPlayer(player: player)
                .edgesIgnoringSafeArea(.all)
                .disabled(true)
                .onAppear() {
                    player.pause()
                    isCurrentVideo = false
                }
                
            VStack {
                Spacer()
                HStack {
                    Text(videoInfo.title)
                        .font(.title)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.vertical)
                    Spacer(minLength: 3)
                    Button(action: toggleSpeed) {
                        ZStack {
                            Circle()
                                .fill(self.isDoubleSpeed ? Color.white : Color.black)
                                .frame(width: 50, height: 50)
                            Text("2x")
                                .foregroundColor(self.isDoubleSpeed ? Color.black : Color.white)
                                .bold()
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }

    private func togglePlayPause() {
        print("toggle play/pause")
            if player.timeControlStatus == .playing {
                print("Player is currently playing, will pause")
                player.pause()
                isPaused = true
                print("Player paused")
            } else {
                print("Player is currently paused, will play")
                player.play()
                isPaused = false
                print("Player playing")
                if isDoubleSpeed {
                    player.rate = 2.0
                    print("Player rate set to 2.0")
                }
            }
        }

    private func toggleSpeed() {
        isDoubleSpeed.toggle()
        if isCurrentVideo {
            player.rate = isDoubleSpeed ? 2.0 : 1.0
        }
    }
}
