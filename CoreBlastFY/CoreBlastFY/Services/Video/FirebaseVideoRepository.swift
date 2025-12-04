//
//  FirebaseVideoRepository.swift
//  CoreBlastFY
//
//  Created by Claude on 12/4/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Combine

final class FirebaseVideoRepository: VideoRepository {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let metadataCollection = "video_metadata"
    
    func fetchVideoMetadata(for exerciseName: String) -> AnyPublisher<VideoMetadata?, Error> {
        return Future<VideoMetadata?, Error> { [weak self] promise in
            guard let self = self else { 
                promise(.failure(VideoRepositoryError.metadataNotFound))
                return 
            }
            
            let normalizedName = exerciseName.lowercased().replacingOccurrences(of: " ", with: "_")
            
            self.db.collection(self.metadataCollection)
                .document(normalizedName)
                .getDocument { document, error in
                    if let error = error {
                        print("Error fetching metadata for \(exerciseName): \(error)")
                        promise(.failure(error))
                        return
                    }
                    
                    guard let document = document, 
                          document.exists,
                          let data = document.data() else {
                        promise(.success(nil))
                        return
                    }
                    
                    let metadata = VideoMetadata(from: data)
                    promise(.success(metadata))
                }
        }
        .eraseToAnyPublisher()
    }
    
    func getAllVideoMetadata() -> AnyPublisher<[VideoMetadata], Error> {
        return Future<[VideoMetadata], Error> { [weak self] promise in
            guard let self = self else { 
                promise(.failure(VideoRepositoryError.metadataNotFound))
                return 
            }
            
            self.db.collection(self.metadataCollection)
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        print("Error fetching all metadata: \(error)")
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    let metadataList = documents.compactMap { document -> VideoMetadata? in
                        return VideoMetadata(from: document.data())
                    }
                    
                    promise(.success(metadataList))
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
            
            let task = URLSession.shared.dataTask(with: videoURL) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let data = data else {
                    promise(.failure(VideoRepositoryError.downloadFailed))
                    return
                }
                
                promise(.success(data))
            }
            
            task.resume()
        }
        .eraseToAnyPublisher()
    }
    
    func downloadVideoFromStorage(path: String) -> AnyPublisher<Data, Error> {
        return Future<Data, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(VideoRepositoryError.downloadFailed))
                return
            }
            
            let storageRef = self.storage.reference().child(path)
            let maxSize: Int64 = 100 * 1024 * 1024 // 100MB max
            
            storageRef.getData(maxSize: maxSize) { data, error in
                if let error = error {
                    print("Error downloading video from Storage: \(error)")
                    promise(.failure(error))
                    return
                }
                
                guard let data = data else {
                    promise(.failure(VideoRepositoryError.downloadFailed))
                    return
                }
                
                promise(.success(data))
            }
        }
        .eraseToAnyPublisher()
    }
}