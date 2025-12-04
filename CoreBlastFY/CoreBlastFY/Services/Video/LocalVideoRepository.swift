//
//  LocalVideoRepository.swift
//  CoreBlastFY
//
//  Created by Claude on 12/4/24.
//

import Foundation
import Combine

final class LocalVideoRepository: VideoRepository {
    
    func fetchVideoMetadata(for exerciseName: String) -> AnyPublisher<VideoMetadata?, Error> {
        return Future<VideoMetadata?, Error> { promise in
            let normalizedName = exerciseName.lowercased().replacingOccurrences(of: " ", with: "_")
            
            if let path = Bundle.main.path(forResource: normalizedName, ofType: "mov") ??
                          Bundle.main.path(forResource: normalizedName, ofType: "mp4") {
                
                let url = URL(fileURLWithPath: path)
                
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: path)
                    let fileSize = attributes[.size] as? Int64 ?? 0
                    
                    let metadata = VideoMetadata(
                        exerciseName: exerciseName,
                        version: "1.0.0",
                        downloadURL: url.absoluteString,
                        fileSize: fileSize,
                        checksum: "",
                        uploadDate: Date(),
                        duration: nil,
                        quality: .medium
                    )
                    
                    promise(.success(metadata))
                } catch {
                    promise(.failure(error))
                }
            } else {
                promise(.success(nil))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func downloadVideo(from url: String) -> AnyPublisher<Data, Error> {
        return Future<Data, Error> { promise in
            guard let videoURL = URL(string: url) else {
                promise(.failure(VideoRepositoryError.invalidURL))
                return
            }
            
            do {
                let data = try Data(contentsOf: videoURL)
                promise(.success(data))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getAllVideoMetadata() -> AnyPublisher<[VideoMetadata], Error> {
        return Future<[VideoMetadata], Error> { promise in
            var metadataList: [VideoMetadata] = []
            
            if let resourcePath = Bundle.main.resourcePath {
                do {
                    let items = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    
                    for item in items {
                        if item.hasSuffix(".mov") || item.hasSuffix(".mp4") {
                            let exerciseName = item
                                .replacingOccurrences(of: ".mov", with: "")
                                .replacingOccurrences(of: ".mp4", with: "")
                                .replacingOccurrences(of: "_", with: " ")
                            
                            let path = (resourcePath as NSString).appendingPathComponent(item)
                            let url = URL(fileURLWithPath: path)
                            
                            if let attributes = try? FileManager.default.attributesOfItem(atPath: path) {
                                let fileSize = attributes[.size] as? Int64 ?? 0
                                
                                let metadata = VideoMetadata(
                                    exerciseName: exerciseName.capitalized,
                                    version: "1.0.0",
                                    downloadURL: url.absoluteString,
                                    fileSize: fileSize,
                                    checksum: "",
                                    uploadDate: Date(),
                                    duration: nil,
                                    quality: .medium
                                )
                                
                                metadataList.append(metadata)
                            }
                        }
                    }
                } catch {
                    print("Error scanning bundle for videos: \(error)")
                }
            }
            
            promise(.success(metadataList))
        }
        .eraseToAnyPublisher()
    }
}