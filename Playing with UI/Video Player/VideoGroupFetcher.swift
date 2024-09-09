//
//  VideoPlayerFetcherView.swift
//  VideoPlayerView 2
//
//  Created by Blake Whitmer on 5/30/24.
//

import CloudKit
import SwiftUI
import AVKit

struct VideoInfo: Identifiable {
    let title: String
    let url: URL
    let firstFrame: UIImage
    var id: String { title }

    init(title: String, url: URL) {
        self.title = title
        self.url = url
        self.firstFrame = generateFirstFrame(url: url)
    }
}

// This function is used to generate the first frame. This is used in the video player to give the illusion of the next video loading on scroll.

func generateFirstFrame(url: URL) -> UIImage {
    let asset = AVAsset(url: url)
    let assetImageGenerator = AVAssetImageGenerator(asset: asset)
    assetImageGenerator.appliesPreferredTrackTransform = true

    let time = CMTime(seconds: 0.0, preferredTimescale: 600)
    do {
        let cgImage = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
        return UIImage(cgImage: cgImage)
    } catch {
        return UIImage()
    }
}


func fetchVideoGroup(recordID: CKRecord.ID, containerIdentifier: String) async -> [VideoInfo] {
    let publicDatabase = CKContainer(identifier: containerIdentifier).publicCloudDatabase
    var videoInfoGroup: [VideoInfo] = []
    
    do {
        let record = try await fetchRecord(for: recordID, from: publicDatabase)
        if let references = record["VideoGroup"] as? [CKRecord.Reference] {
            let videoInfos = await fetchVideoForDisplayRecords(from: references, in: publicDatabase)
            let hardLinks = await createHardLinks(from: videoInfos)
            videoInfoGroup = hardLinks
        }
    } catch {
        print("Error fetching record: \(error.localizedDescription)")
    }
    
    return videoInfoGroup
}

private func fetchVideoForDisplayRecords(from references: [CKRecord.Reference], in publicDatabase: CKDatabase) async -> [VideoInfo] {
    var videoInfos: [VideoInfo] = []
    
    await withTaskGroup(of: VideoInfo?.self) { group in
        for reference in references {
            group.addTask {
                do {
                    let record = try await fetchRecord(for: reference.recordID, from: publicDatabase)
                    if let title = record["Title"] as? String,
                       let asset = record["Video"] as? CKAsset,
                       let fileURL = asset.fileURL {
                        return VideoInfo(title: title, url: fileURL)
                    }
                } catch {
                    print("Error fetching VideoForDisplay record: \(error.localizedDescription)")
                }
                return nil
            }
        }
        
        for await videoInfo in group {
            if let videoInfo = videoInfo {
                videoInfos.append(videoInfo)
            }
        }
    }
    
    return videoInfos
}

private func createHardLinks(from videoInfos: [VideoInfo]) async -> [VideoInfo] {
    var hardLinks: [VideoInfo] = []
    let fileManager = FileManager.default
    let tempDir = fileManager.temporaryDirectory
    
    for videoInfo in videoInfos {
        let hardLinkURL = tempDir.appendingPathComponent(videoInfo.url.lastPathComponent).appendingPathExtension("mp4")
        do {
            // Remove existing file if it exists
            if fileManager.fileExists(atPath: hardLinkURL.path) {
                try fileManager.removeItem(at: hardLinkURL)
            }
            // Create hard link
            try fileManager.linkItem(at: videoInfo.url, to: hardLinkURL)
            print("Created hard link: \(hardLinkURL)")
            hardLinks.append(VideoInfo(title: videoInfo.title, url: hardLinkURL))
        } catch {
            print("Error creating hard link: \(error.localizedDescription)")
        }
    }
    
    return hardLinks
}

private func fetchRecord(for recordID: CKRecord.ID, from publicDatabase: CKDatabase) async throws -> CKRecord {
    try await withCheckedThrowingContinuation { continuation in
        publicDatabase.fetch(withRecordID: recordID) { record, error in
            if let record = record {
                continuation.resume(returning: record)
            } else if let error = error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(throwing: CKError(.unknownItem))
            }
        }
    }
}
