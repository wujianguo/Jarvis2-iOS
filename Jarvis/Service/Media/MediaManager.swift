//
//  MediaManager.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2019/3/21.
//  Copyright © 2019 wujianguo. All rights reserved.
//

import Foundation
import Photos
import WCDBSwift

enum PhotoUploadState {
    case start(Int)
    case thumbnail(UIImage)
    case origin(UIImage)
    case uploading
    case failure(String)
    case done
}

protocol PhotoUploadDelegate: NSObjectProtocol {
    func photoUploadStateChangedTo(state: PhotoUploadState)
}


class AliyunCloudPhoto {
    
    init() {
        
    }
    
    private func get(param: Encodable) {
    }
    
    func createTransaction() {
        
    }
    
    func ossUpload() {
        
    }
    
    func createPhoto() {
        
    }
    
}

struct AliyunPhoto: Decodable {
    let id: Int
    let md5: String
    let height: Int
    let width: Int
    let title: String
    let fileId: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case md5 = "Md5"
        case height = "Height"
        case width = "Width"
        case title = "Title"
        case fileId = "FileId"
    }
}


struct UploadState: TableCodable {

    let localIdentifier: String

    let remoteIdentifier: String
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = UploadState
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case remoteIdentifier
        case localIdentifier
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                localIdentifier: ColumnConstraintBinding(isPrimary: true),
            ]
        }
    }
}

class MediaManager {
    
    weak var delegate: PhotoUploadDelegate?
    
    lazy var client: AliyunMediaCloudClient = {
        return AliyunMediaCloudClient(storeName: "jarvis", library: UIApplication.shared.account.user.unique, endpoint: URL(string: "https://cloudphoto.cn-shanghai.aliyuncs.com")!, credentialProvider: AliyunCredentialProvider())
    }()
    
    func startSync() {
        syncing = true
        upload(index: 0)
    }
    
    func stopSync() {
        syncing = false
    }

    var syncing = false
    
    
    private func upload(index: Int) {
        guard syncing else {
            return
        }
        guard let fetchResult = fetchResult else {
            delegate?.photoUploadStateChangedTo(state: .done)
            return
        }
        guard index < fetchResult.count else {
            delegate?.photoUploadStateChangedTo(state: .done)
            return
        }
        
        let asset = fetchResult.object(at: index)
        guard asset.mediaType == .image else {
            upload(index: index + 1)
            return
        }
        
        let uploadData = { (data: Data, name: String, pathExtension: String) in
            self.delegate?.photoUploadStateChangedTo(state: .uploading)
            self.client.upload(data: data, name: name, pathExtension: pathExtension, queue: DispatchQueue.main, complete: { (result) in
                switch result {
                case .success(let item):
                    print(item.id)
                    let asset = fetchResult.object(at: index)
                    let state = UploadState(localIdentifier: asset.localIdentifier, remoteIdentifier: "\(item.id)")
                    UIApplication.shared.database.insert(upload: state)
                    self.upload(index: index + 1)
                case .failure( _):
                    self.upload(index: index + 1)
                }
            })
//            APIRequest(post: "/upload/media/\(name)", body: data, contentType: "application/octet-stream").response(success: { (photo: AliyunPhoto) in
//                let asset = fetchResult.object(at: index)
//                UserAccount.current.save(localIdentifier: asset.localIdentifier)
//                self.upload(index: index + 1)
//            }, failure: { (error) in
//                self.delegate?.photoUploadStateChangedTo(state: .failure("\(error)"))
//                self.upload(index: index + 1)
//            })
        }
        
        let requestOrigin = {
            let asset = fetchResult.object(at: index)
            let options = PHImageRequestOptions()
            options.version = .original
            options.isNetworkAccessAllowed = true
            self.imageManager.requestImageData(for: asset, options: options) { (data, str, orientation, info) in
                guard let data = data else {
                    self.delegate?.photoUploadStateChangedTo(state: .failure("origin fail 1"))
                    self.upload(index: index + 1)
                    return
                }
                guard let image = UIImage(data: data) else {
                    self.delegate?.photoUploadStateChangedTo(state: .failure("origin fail 2"))
                    self.upload(index: index + 1)
                    return
                }
                if str != AVFileType.jpg.rawValue {
                    self.delegate?.photoUploadStateChangedTo(state: .failure("format not supported"))
                    self.upload(index: index + 1)
                    return
                }
                self.delegate?.photoUploadStateChangedTo(state: .origin(image))
                let fileURL = info?["PHImageFileURLKey"] as! URL
                print(str!)
                print(fileURL.pathExtension)
                uploadData(data, fileURL.lastPathComponent, fileURL.pathExtension)
            }
        }
        
        let requestThumbnail = {
            let asset = fetchResult.object(at: index)
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.resizeMode = .exact
            options.deliveryMode = .fastFormat
            options.isNetworkAccessAllowed = true
            
            self.imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: options) { (image, info) in
                guard let image = image else {
                    self.delegate?.photoUploadStateChangedTo(state: .failure("thumbnail fail"))
                    self.upload(index: index + 1)
                    return
                }
                self.delegate?.photoUploadStateChangedTo(state: .thumbnail(image))
                requestOrigin()
            }
        }
        
        let requestLocal = {
            let asset = fetchResult.object(at: index)
            UIApplication.shared.database.query(localIdentifier: asset.localIdentifier) { (upload) in
                if upload != nil {
                    self.upload(index: index + 1)
                } else {
                    requestThumbnail()
                }
            }
        }
        
        delegate?.photoUploadStateChangedTo(state: .start(index))
//        requestThumbnail()
        requestLocal()
    }
    
    
    
    private lazy var fetchResult: PHFetchResult<PHAsset>? = {
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        guard smartAlbums.firstObject != nil else {
            return nil
        }
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
        return PHAsset.fetchAssets(in: smartAlbums.firstObject!, options: options)
    }()

    private lazy var imageManager: PHCachingImageManager = {
        let manager = PHCachingImageManager()
        return manager
    }()

}
