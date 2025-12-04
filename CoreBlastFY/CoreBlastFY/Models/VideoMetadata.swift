//
//  VideoMetadata.swift
//  CoreBlastFY
//
//  Created by Claude on 12/4/24.
//

import Foundation
import Firebase

struct VideoMetadata: Codable {
    let exerciseName: String
    let version: String
    let downloadURL: String
    let fileSize: Int64
    let checksum: String
    let uploadDate: Date
    let duration: TimeInterval?
    let quality: VideoQuality
    
    enum VideoQuality: String, Codable {
        case low = "480p"
        case medium = "720p"
        case high = "1080p"
    }
    
    enum CodingKeys: String, CodingKey {
        case exerciseName = "exercise_name"
        case version
        case downloadURL = "download_url"
        case fileSize = "file_size"
        case checksum
        case uploadDate = "upload_date"
        case duration
        case quality
    }
}

extension VideoMetadata {
    init(from document: [String: Any]) {
        self.exerciseName = document["exercise_name"] as? String ?? ""
        self.version = document["version"] as? String ?? "1.0.0"
        self.downloadURL = document["download_url"] as? String ?? ""
        self.fileSize = document["file_size"] as? Int64 ?? 0
        self.checksum = document["checksum"] as? String ?? ""
        
        if let timestamp = document["upload_date"] as? Timestamp {
            self.uploadDate = timestamp.dateValue()
        } else {
            self.uploadDate = Date()
        }
        
        self.duration = document["duration"] as? TimeInterval
        
        let qualityString = document["quality"] as? String ?? "720p"
        self.quality = VideoQuality(rawValue: qualityString) ?? .medium
    }
    
    var cacheKey: String {
        return "\(exerciseName)_\(version)_\(quality.rawValue)"
    }
    
    var localFileName: String {
        return "\(exerciseName)_\(version).mp4"
    }
}