//
//  VideoPlayerGroupVie2.swift
//  VideoPlayerView 2
//
//  Created by Blake Whitmer on 5/26/24.
//

import SwiftUI
import AVKit
import CloudKit

struct VideoPlayerGroupView: View {
    @State private var videoInfoGroup: [VideoInfo]
    @State private var isLoading: Bool = false
    @Binding var navigationPath: NavigationPath
    private let recordName: String?
    
    let columns = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3)
        ]
    
    init(videoInfoGroup: [VideoInfo], navigationPath: Binding<NavigationPath>) {
        self.videoInfoGroup = videoInfoGroup
        self._navigationPath = navigationPath
        self.recordName = nil
    }
    
    var body: some View {
        
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .onAppear {
                        isLoading = false
                    }
            } else {
                if videoInfoGroup.isEmpty {
                    EmptyView()
                } else if videoInfoGroup.count == 1 {
                    VStack {
                        NavigationLink(destination: VideoPlayerScrollView(videoInfoGroup: videoInfoGroup, navigationPath: $navigationPath)) {
                            ThumbnailView(videoURL: videoInfoGroup[0].url, title: videoInfoGroup[0].title)
                                .frame(width: UIScreen.main.bounds.width)
                        }
                    }
                } else {
                    LazyVGrid(columns: columns, spacing: 3) {
                        ForEach(0..<videoInfoGroup.count, id: \.self) { index in
                            // Need array of items given urls
                                                        
                            NavigationLink(destination: VideoPlayerScrollView(videoInfoGroup: rearrangeVideos(selectedIndex: index), navigationPath: $navigationPath)) {
                                    ThumbnailView(videoURL: videoInfoGroup[index].url, title: videoInfoGroup[index].title)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func rearrangeVideos(selectedIndex: Int) -> [VideoInfo] {
            var sortedVideos = videoInfoGroup
            let selectedVideo = sortedVideos.remove(at: selectedIndex)
            sortedVideos.insert(selectedVideo, at: 0)
            return sortedVideos
        }
}
