//
//  VideoRepository.swift
//  CoreBlastFY
//
//  Created by Claude on 12/4/24.
//

import Foundation
import Combine

protocol VideoRepository {
    func fetchVideoMetadata(for exerciseName: String) -> AnyPublisher<VideoMetadata?, Error>
    func downloadVideo(from url: String) -> AnyPublisher<Data, Error>
    func getAllVideoMetadata() -> AnyPublisher<[VideoMetadata], Error>
}

enum VideoRepositoryError: LocalizedError {
    case networkUnavailable
    case metadataNotFound
    case downloadFailed
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network connection is unavailable"
        case .metadataNotFound:
            return "Video metadata not found"
        case .downloadFailed:
            return "Failed to download video"
        case .invalidURL:
            return "Invalid video URL"
        }
    }
}