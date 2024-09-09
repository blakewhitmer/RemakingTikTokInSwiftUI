//
//  ThumbnailView.swift
//  VideoPlayerView 2
//
//  Created by Blake Whitmer on 5/30/24.
//

import SwiftUI
import AVKit
import AVFoundation

struct ThumbnailView: View {
    let videoURL: URL
    let title: String
    @State private var thumbnailImage: Image?

    var body: some View {
        VStack {
            if let thumbnailImage = thumbnailImage {
                VStack {
                    thumbnailImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .overlay(
                            VStack {
                                Spacer()
                                Text(title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .shadow(radius: 5)
                                    .padding(.vertical)
                            }
                        )
                }
            } else {
                Text("Loading thumbnail...")
            }
        }
        .onAppear {
            generateThumbnail(from: videoURL) { image in
                thumbnailImage = image
            }
        }
    }

    func generateThumbnail(from url: URL, completion: @escaping (Image?) -> Void) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImageGenerator.appliesPreferredTrackTransform = true

            let time = CMTime(seconds: 1, preferredTimescale: 60)
            do {
                let cgImage = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    completion(Image(uiImage: uiImage))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
