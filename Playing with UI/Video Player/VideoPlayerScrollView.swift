//
//  VideoPlayerScrollView.swift
//  Playing with UI
//
//  Created by Blake Whitmer on 6/11/24.
//

import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerScrollView: View {
    @State private var offset: CGSize = .zero
    @State private var totalOffset: CGSize = .zero
    @Binding var navigationPath: NavigationPath
    @Environment(\.presentationMode) var presentationMode

    let videoInfoGroup: [VideoInfo]
    private let recordName: String?

    init(videoInfoGroup: [VideoInfo], navigationPath: Binding<NavigationPath>) {
        self.videoInfoGroup = videoInfoGroup
        self._navigationPath = navigationPath
        self.recordName = nil
    }

    var body: some View {
        ZStack {
            

            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(spacing: 0.0) {
                        ForEach(videoInfoGroup.indices, id: \.self) { index in
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(Color.black)
                                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                                
                                VideoPlayerView(player: AVPlayer(url: videoInfoGroup[index].url), videoInfo: videoInfoGroup[index])
                                                                .frame(height: UIScreen.main.bounds.height) // Full screen height for each video
                                                                .id(index)
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)

                .scrollTargetBehavior(.paging)
                
                .scrollIndicators(.hidden)
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = gesture.translation
                        }
                        .onEnded { gesture in
                            print("test")
                            if offset.width > 50 {
                                presentationMode.wrappedValue.dismiss()
                            }
                            offset = .zero
                        }

                )
            }
        }
        .onAppear() {
            configureAudioSession()
        }
    }
    
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [.defaultToSpeaker, .allowAirPlay])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
}
