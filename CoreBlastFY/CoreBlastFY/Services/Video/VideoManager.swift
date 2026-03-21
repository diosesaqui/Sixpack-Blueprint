//
//  VideoManager.swift
//  CoreBlastFY
//
//  Created by Claude on 12/4/24.
//

import Foundation
import Combine
import UIKit

final class VideoManager: ObservableObject {
    static let shared = VideoManager()
    
    //private let firebaseRepository: VideoRepository
    private let localRepository: VideoRepository
    private let cacheManager = VideoCacheManager.shared
    private let networkMonitor = NetworkMonitor.shared
    
    private var cancellables = Set<AnyCancellable>()
    private let downloadQueue = DispatchQueue(label: "video.download.queue", attributes: .concurrent)
    private var activeDownloads = Set<String>()
    
    @Published var isLoadingVideos = false
    @Published var downloadProgress: [String: Float] = [:]
    @Published var availableVideos: [String: VideoMetadata] = [:]
    
    enum VideoLoadError: LocalizedError {
        case noVideoAvailable
        case downloadFailed
        case cacheError
        
        var errorDescription: String? {
            switch self {
            case .noVideoAvailable:
                return "No video available for this exercise"
            case .downloadFailed:
                return "Failed to download video"
            case .cacheError:
                return "Failed to cache video"
            }
        }
    }
    
    private init() {
       // self.firebaseRepository = FirebaseVideoRepository()
        self.localRepository = LocalVideoRepository()
    }
    
    func prefetchAllVideos() {
        // TO DO uncomment when videos are uploaded rwrw
//        guard networkMonitor.shouldDownloadVideo() else {
//            print("Network conditions not suitable for video download")
//            return
//        }
//        
//        isLoadingVideos = true
//        
//        firebaseRepository.getAllVideoMetadata()
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    self?.isLoadingVideos = false
//                    if case .failure(let error) = completion {
//                        print("Failed to fetch video metadata: \(error)")
                        self.loadLocalVideosAsFallback()
//                    }
//                },
//                receiveValue: { [weak self] metadataList in
//                    self?.processVideoMetadata(metadataList)
//                }
//            )
//            .store(in: &cancellables)
    }
    
    private func processVideoMetadata(_ metadataList: [VideoMetadata]) {
        for metadata in metadataList {
            availableVideos[metadata.exerciseName] = metadata
            
            if cacheManager.isVideoOutdated(
                exerciseName: metadata.exerciseName,
                currentVersion: metadata.version
            ) {
               // prefetchVideo(metadata: metadata)
            }
        }
    }
    
//    private func prefetchVideo(metadata: VideoMetadata) {
//        guard networkMonitor.shouldDownloadVideo() else { return }
//        guard !activeDownloads.contains(metadata.exerciseName) else { return }
//        
//        activeDownloads.insert(metadata.exerciseName)
//        
//        firebaseRepository.downloadVideo(from: metadata.downloadURL)
//            .receive(on: downloadQueue)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    self?.activeDownloads.remove(metadata.exerciseName)
//                    if case .failure(let error) = completion {
//                        print("Failed to prefetch video for \(metadata.exerciseName): \(error)")
//                    }
//                },
//                receiveValue: { [weak self] data in
//                    do {
//                        _ = try self?.cacheManager.saveVideo(data: data, metadata: metadata)
//                        print("Successfully cached video: \(metadata.exerciseName) v\(metadata.version)")
//                    } catch {
//                        print("Failed to cache video: \(error)")
//                    }
//                }
//            )
//            .store(in: &cancellables)
//    }
    
    func getVideoURL(for exerciseName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        // First check cache
        if let metadata = availableVideos[exerciseName],
           let cachedURL = cacheManager.getCachedVideoURL(for: metadata) {
            completion(.success(cachedURL))
            return
        }
        
        // If not in cache, try to download from Firebase
//        if networkMonitor.isConnected {
//          //  fetchAndCacheVideo(exerciseName: exerciseName, completion: completion)
//        } else {
            // Fall back to local bundled video
            loadLocalVideo(exerciseName: exerciseName, completion: completion)
      //  }
    }
    
//    private func fetchAndCacheVideo(exerciseName: String, completion: @escaping (Result<URL, Error>) -> Void) {
//        firebaseRepository.fetchVideoMetadata(for: exerciseName)
//            .flatMap { [weak self] metadata -> AnyPublisher<(VideoMetadata, Data), Error> in
//                guard let self = self, let metadata = metadata else {
//                    return Fail(error: VideoLoadError.noVideoAvailable)
//                        .eraseToAnyPublisher()
//                }
//                
//                return self.firebaseRepository.downloadVideo(from: metadata.downloadURL)
//                    .map { (metadata, $0) }
//                    .eraseToAnyPublisher()
//            }
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { result in
//                    if case .failure(let error) = result {
//                        print("Failed to fetch video from Firebase: \(error)")
//                        self.loadLocalVideo(exerciseName: exerciseName, completion: completion)
//                    }
//                },
//                receiveValue: { [weak self] metadata, data in
//                    do {
//                        let url = try self?.cacheManager.saveVideo(data: data, metadata: metadata)
//                        completion(.success(url ?? URL(fileURLWithPath: "")))
//                    } catch {
//                        self?.loadLocalVideo(exerciseName: exerciseName, completion: completion)
//                    }
//                }
//            )
//            .store(in: &cancellables)
//    }
    
    private func loadLocalVideo(exerciseName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        localRepository.fetchVideoMetadata(for: exerciseName)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        completion(.failure(error))
                    }
                },
                receiveValue: { metadata in
                    if let metadata = metadata,
                       let url = URL(string: metadata.downloadURL) {
                        completion(.success(url))
                    } else {
                        completion(.failure(VideoLoadError.noVideoAvailable))
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadLocalVideosAsFallback() {
        localRepository.getAllVideoMetadata()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] metadataList in
                    for metadata in metadataList {
                        self?.availableVideos[metadata.exerciseName] = metadata
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func clearCache() {
        cacheManager.clearCache()
        availableVideos.removeAll()
        downloadProgress.removeAll()
    }
    
    func getCacheInfo() -> (usedSpace: String, totalVideos: Int) {
        let info = cacheManager.getCacheInfo()
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        let usedSpaceString = formatter.string(fromByteCount: info.usedSpace)
        return (usedSpaceString, info.totalVideos)
    }
}

// MARK: - Exercise Integration
extension VideoManager {
    func getVideoURL(for exercise: Exercise, completion: @escaping (URL?) -> Void) {
        getVideoURL(for: exercise.name) { result in
            switch result {
            case .success(let url):
                completion(url)
            case .failure(let error):
                print("Failed to get video for \(exercise.name): \(error)")
                // Try to use the existing local video URL from the exercise
                completion(exercise.videoURL)
            }
        }
    }
}
