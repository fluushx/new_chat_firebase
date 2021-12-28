//
//  StorageManager.swift
//  Firebase Chat App
//
//  Created by Felipe Ignacio Zapata Riffo on 09-09-21.
//

import Foundation
import FirebaseStorage

final class storageManager {
    static let shared  = storageManager()
    
    private let storage = Storage.storage().reference()
    //profile_picture.png
    public typealias UploadPictureComplations = (Result<String,Error>)->Void
    public func uploadProfilePicture(with data:Data,
                                     fileName:String,
                                     completion:@escaping UploadPictureComplations) {
        
        storage.child("images\(fileName)").putData(data,metadata: nil,completion: {metadata,error in
            guard error == nil else {
                print("failed to upload picture to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self.storage.child("images\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                let urlString  = url.absoluteString
                print("download url returned : \(urlString)")
                completion(.success(urlString))
                
            })
        })
        
    }
    
    public enum StorageErrors : Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
    
    public func downloadURL(for path:String,completion: @escaping(Result<URL,Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
        
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        })
    }
}
