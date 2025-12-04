//
//  VideoCacheManager.swift
//  CoreBlastFY
//
//  Created by Claude on 12/4/24.
//

import Foundation

final class VideoCacheManager {
    static let shared = VideoCacheManager()
    
    private let cacheDirectory: URL
    private let metadataFile: URL
    private let maxCacheSize: Int64 = 1_073_741_824 // 1GB
    private let fileManager = FileManager.default
    private var cacheMetadata: [String: CachedVideoInfo] = [:]
    
    private struct CachedVideoInfo: Codable {
        let metadata: VideoMetadata
        let localPath: String
        let downloadDate: Date
        let lastAccessDate: Date
        let fileSize: Int64
    }
    
    private init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.cacheDirectory = documentsPath.appendingPathComponent("VideoCache")
        self.metadataFile = cacheDirectory.appendingPathComponent("cache_metadata.json")
        
        createCacheDirectoryIfNeeded()
        loadCacheMetadata()
    }
    
    private func createCacheDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    private func loadCacheMetadata() {
        guard let data = try? Data(contentsOf: metadataFile),
              let metadata = try? JSONDecoder().decode([String: CachedVideoInfo].self, from: data) else {
            cacheMetadata = [:]
            return
        }
        cacheMetadata = metadata
    }
    
    private func saveCacheMetadata() {
        guard let data = try? JSONEncoder().encode(cacheMetadata) else { return }
        try? data.write(to: metadataFile)
    }
    
    func getCachedVideoURL(for metadata: VideoMetadata) -> URL? {
        let cacheKey = metadata.cacheKey
        
        guard let cachedInfo = cacheMetadata[cacheKey] else {
            return nil
        }
        
        let videoURL = cacheDirectory.appendingPathComponent(cachedInfo.localPath)
        
        if fileManager.fileExists(atPath: videoURL.path) {
            // Update last access date
            var updatedInfo = cachedInfo
            updatedInfo = CachedVideoInfo(
                metadata: cachedInfo.metadata,
                localPath: cachedInfo.localPath,
                downloadDate: cachedInfo.downloadDate,
                lastAccessDate: Date(),
                fileSize: cachedInfo.fileSize
            )
            cacheMetadata[cacheKey] = updatedInfo
            saveCacheMetadata()
            
            return videoURL
        } else {
            // File doesn't exist, remove from metadata
            cacheMetadata.removeValue(forKey: cacheKey)
            saveCacheMetadata()
            return nil
        }
    }
    
    func saveVideo(data: Data, metadata: VideoMetadata) throws -> URL {
        let cacheKey = metadata.cacheKey
        let fileName = metadata.localFileName
        let videoURL = cacheDirectory.appendingPathComponent(fileName)
        
        // Check if we need to clear space
        let dataSize = Int64(data.count)
        ensureCacheSpace(for: dataSize)
        
        // Save the video
        try data.write(to: videoURL)
        
        // Update metadata
        let cachedInfo = CachedVideoInfo(
            metadata: metadata,
            localPath: fileName,
            downloadDate: Date(),
            lastAccessDate: Date(),
            fileSize: dataSize
        )
        cacheMetadata[cacheKey] = cachedInfo
        saveCacheMetadata()
        
        return videoURL
    }
    
    func isVideoOutdated(exerciseName: String, currentVersion: String) -> Bool {
        let matchingVideos = cacheMetadata.values.filter { $0.metadata.exerciseName == exerciseName }
        
        for cachedVideo in matchingVideos {
            if cachedVideo.metadata.version == currentVersion {
                return false
            }
        }
        return true
    }
    
    private func ensureCacheSpace(for requiredSize: Int64) {
        var currentCacheSize = calculateCacheSize()
        
        while currentCacheSize + requiredSize > maxCacheSize {
            guard let oldestVideo = findOldestAccessedVideo() else { break }
            
            removeVideo(cacheKey: oldestVideo.0)
            currentCacheSize = calculateCacheSize()
        }
    }
    
    private func calculateCacheSize() -> Int64 {
        return cacheMetadata.values.reduce(0) { $0 + $1.fileSize }
    }
    
    private func findOldestAccessedVideo() -> (String, CachedVideoInfo)? {
        return cacheMetadata.min { $0.value.lastAccessDate < $1.value.lastAccessDate }
    }
    
    private func removeVideo(cacheKey: String) {
        guard let cachedInfo = cacheMetadata[cacheKey] else { return }
        
        let videoURL = cacheDirectory.appendingPathComponent(cachedInfo.localPath)
        try? fileManager.removeItem(at: videoURL)
        cacheMetadata.removeValue(forKey: cacheKey)
        saveCacheMetadata()
    }
    
    func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        createCacheDirectoryIfNeeded()
        cacheMetadata = [:]
        saveCacheMetadata()
    }
    
    func getCacheInfo() -> (usedSpace: Int64, totalVideos: Int) {
        let usedSpace = calculateCacheSize()
        let totalVideos = cacheMetadata.count
        return (usedSpace, totalVideos)
    }
}