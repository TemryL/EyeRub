//
//  ModelFileManager.swift
//  EyeRub
//
//  Created by Tom MERY on 01.11.2023.
//

import SwiftUI
import CoreML

class ModelFileManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    @Published var downloadProgress: Double = 0.0

    var downloadTask: URLSessionDownloadTask?
    var downloadQueue: [String] = [] // Queue of file names to download
    var currentFileName: String?
    var downloadCompletion: ((Bool) -> Void)?
    let baseURL = "http://127.0.0.1:8000" // Your base URL
    let documentURL = FileManager.default.urls(for: .documentDirectory,
                                         in: .userDomainMask).first!
    let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.mery.EyeRub")
    
    
    func downloadFilesSequentially(fileNames: [String], completion: @escaping (Bool) -> Void) {
        downloadQueue = fileNames // Populate the download queue
        downloadNextFile(completion: completion)
    }

    func downloadNextFile(completion: @escaping (Bool) -> Void) {
        guard let fileName = downloadQueue.first else {
            // No more files in the queue
            completion(true)
            return
        }

        guard let url = URL(string: baseURL + "/" + fileName) else {
            completion(false)
            return
        }

        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        downloadTask = session.downloadTask(with: url)
        downloadTask?.resume()

        // Store the current file name
        self.currentFileName = fileName
        self.downloadCompletion = completion
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        if downloadTask == self.downloadTask {
            let calculatedProgress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            DispatchQueue.main.async {
                self.downloadProgress = calculatedProgress
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if downloadTask == self.downloadTask, let fileName = currentFileName, let completion = downloadCompletion {
            let destinationURL = documentURL.appendingPathComponent(fileName)
            
            if saveDownloadedFile(from: location, destinationURL, fileName) {
                print("\(fileName) download completed successfully")
                compileCoreMLModel(at: destinationURL)
            } else {
                print("\(fileName) download failed")
            }

            // Remove the current file name from the queue and proceed to the next file
            downloadQueue.removeFirst()
            downloadNextFile(completion: completion)
        }
    }
    
    func saveDownloadedFile(from localURL: URL, _ destinationURL: URL, _ fileName: String) -> Bool {
        do {
            _ = try FileManager.default.replaceItemAt(destinationURL, withItemAt: localURL)
            return true
        } catch {
            print("Error saving file: \(error)")
            return false
        }
    }
    
    func compileCoreMLModel(at url: URL) {
        do {
            let compiledModelURL = try MLModel.compileModel(at: url)
            let compiledModelName = compiledModelURL.lastPathComponent
            let sharedModelURL = sharedContainerURL?.appendingPathComponent(compiledModelName)
            if let sharedModelURL = sharedModelURL {
                _ = try FileManager.default.replaceItemAt(sharedModelURL, withItemAt: compiledModelURL)
            } else {
                print("Error saving Core ML model in app group container")
            }
        } catch {
            print("Error compiling Core ML model: \(error)")
        }
    }
}
