//
//  AliyunMediaCloudClient.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2019/6/15.
//  Copyright © 2019 wujianguo. All rights reserved.
//

import Foundation
import UIKit
import AliyunOSSiOS
//
//struct AliyunMediaItem: MediaItem {
//
//    var takenAt: Date
//
//    var localIdentifier: String
//
//    let size: CGSize
//
//    let title: String
//
//    let id: String
//
//    let updatedAt: Date
//
//    let createdAt: Date
//
//}

class AliyunCredentialProvider {
    
    var credential: AliyunCredential? = nil
    
    func getCredential(complete: @escaping (Result<AliyunCredential, Error>) -> Void) {
        if let credential = credential {
            complete(.success(credential))
            return
        }
        APIRequest(get: "/aliyun/photo/credential").response(complete: complete)
    }
    
}


class AliyunMediaCloudClient {
    
    struct AliyunErrorMessage: Decodable {
        let Code: String
        let RequestId: String
        let HostId: String
        let Recommend: String
        let Message: String
    }
    
    enum AliyunError: Error {
        case aliyun(AliyunErrorMessage)
    }
    
    var client: OSSClient? = nil
    var task: Any? = nil
    
    let storeName: String
    let library: String
    let endpoint: URL
    let credentialProvider: AliyunCredentialProvider
    
    
    init(storeName: String, library: String, endpoint: URL, credentialProvider: AliyunCredentialProvider) {
        self.storeName = storeName
        self.library = library
        self.endpoint = endpoint
        self.credentialProvider = credentialProvider
    }
    
    private func buildRequest(action: String, param: [String: String] = [:], credential: AliyunCredential) -> URLRequest {
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)!
        var queryItems = [URLQueryItem]()
        let timestamp = ISO8601DateFormatter().string(from: Date(timeIntervalSinceNow: 0))
        let nonce = "\(Int.random(in: 100000..<1000000))"
        let query = AliyunSignature.signature2(action: action, params: param, accessKeyId: credential.accessKeyId, accessKeySecret: credential.accessKeySecret, version: "2017-07-11", securityToken: credential.securityToken, timestamp: timestamp, nonce: nonce)
//        debugPrint(query)
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: ":#[]@=&()*+,;'!$")

        for (k, v) in query {
//            let queryArray: [String] = sortedInput.map {
//                "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!)"
//            }

            queryItems.append(URLQueryItem(name: k, value: v.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)))
        }
//        queryItems.append(URLQueryItem(name: "Action", value: action))
        
//        components.queryItems = queryItems
        components.percentEncodedQueryItems = queryItems
        var request = URLRequest(url: components.url!)

//        var request = URLRequest(url: endpoint)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return request
    }
    
    private func completeResult<T>(result: Result<T, Error>, queue: DispatchQueue? = nil, complete: ((Result<T, Error>)->Void)? = nil) {
        switch result {
        case .failure(let error):
            debugPrint(error)
        default:
            break
        }
        guard let complete = complete else {
            return
        }
        if let queue = queue {
            queue.async {
                complete(result)
            }
        } else {
            complete(result)
        }
    }

    private func response<T: Decodable>(action: String, param: [String: String] = [:], queue: DispatchQueue? = nil, complete: @escaping ((Result<T, Error>)->Void)) {
        credentialProvider.getCredential { (result) in
            switch result {
            case .success(let credential):
                let request = self.buildRequest(action: action, param: param, credential: credential)
//                debugPrint(request.url!)
                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, err) in
                    if let res = response as? HTTPURLResponse {
                        if res.statusCode >= 400 {
                            let str = String(data: data!, encoding: .utf8)!
                            debugPrint(action)
                            debugPrint(param)
                            debugPrint(str)

                            if data != nil {
                                if let e = try? JSONDecoder().decode(AliyunErrorMessage.self, from: data!) {
                                    self.completeResult(result: .failure(AliyunError.aliyun(e)), queue: queue, complete: complete)
                                    return
                                }
                            }

                            let error = APIError.serverError(res.statusCode, HTTPURLResponse.localizedString(forStatusCode: res.statusCode))
                            self.completeResult(result: .failure(error), queue: queue, complete: complete)
                            return
                        }
                    }

                    if let err = err {
                        self.completeResult(result: .failure(err), queue: queue, complete: complete)
                    } else if let data = data {
                        do {
                            let ret = try JSONDecoder().decode(T.self, from: data)
                            self.completeResult(result: .success(ret), queue: queue, complete: complete)
                        } catch {
                            let str = String(data: data, encoding: .utf8)!
                            debugPrint(action)
                            debugPrint(param)
                            debugPrint(str)
                            self.completeResult(result: .failure(error), queue: queue, complete: complete)
                        }
                    } else {
                        self.completeResult(result: .failure(APIError.defaultError), queue: queue, complete: complete)
                    }
                })
                task.resume()
            case .failure(let error):
                self.completeResult(result: .failure(error), queue: queue, complete: complete)
            }
        }
    }
    
    
    struct AliyunTransactionResponse: Decodable {
        let Action: String
        let Message: String
        let Code: String
        let RequestId: String
        
        let Transaction: AliyunTransactionInner
        
        struct AliyunTransactionInner: Decodable {
            let Upload: AliyunUpload
        }
        
    }
    
    struct AliyunUpload: Decodable {
        let AccessKeyId: String
        let AccessKeySecret: String
        let Bucket: String
        let FileId: String
        let ObjectKey: String
        let OssEndpoint: String
        let SessionId: String
        let StsToken: String
    }
    
    private func createTransaction(ext: String, md5: String, size: Int, storeName: String, queue: DispatchQueue? = nil, complete: @escaping ((Result<AliyunUpload, Error>)->Void)) {
        let param = [
            "Ext": ext,
            "Md5": md5,
            "Size": "\(size)",
            "StoreName": storeName
        ]
//        response(action: "CreateTransaction", param: param, queue: queue, complete: complete)
        response(action: "CreateTransaction", param: param, queue: queue) { (result: Result<AliyunTransactionResponse, Error>) in
            switch result {
            case .success(let resp):
                self.completeResult(result: .success(resp.Transaction.Upload), queue: queue, complete: complete)
            case .failure(let error):
                self.completeResult(result: .failure(error), queue: queue, complete: complete)
            }
        }
    }
    
    struct AliyunPhotoResponse: Decodable {
        let Action: String
        let Message: String
        let Code: String
        let RequestId: String
        
        let Photo: AliyunPhoto
    }
    
    struct AliyunPhotosResponse: Decodable {
        let Action: String
        let Message: String
        let Code: String
        let RequestId: String
        
        let Photos: [AliyunPhoto]
    }

    
    struct AliyunPhoto: Decodable, MediaItem {        
        
        var size: CGSize {
            return CGSize(width: Width, height: Height)
        }
        
        var title: String {
            return Title
        }
        
        var id: Int {
            return Id
        }
        
        var updatedAt: Date {
            return Date(timeIntervalSince1970: TimeInterval(Mtime))
        }
        
        var createdAt: Date {
            return Date(timeIntervalSince1970: TimeInterval(Ctime))
        }
        
        var takenAt: Date {
            return Date(timeIntervalSince1970: TimeInterval(TakenAt))
        }
        
        let Ctime: Int
        let FileId: String
        let Height: Int
        let Width: Int
        let Id: Int
        let Md5: String
        let Mtime: Int
        let State: String
        let Title: String
        let Remark: String
        let TakenAt: Int
    }
    
    
    private func createPhoto(fileId: String, photoTitle: String, sessionId: String, storeName: String, queue: DispatchQueue? = nil, complete: @escaping ((Result<AliyunPhoto, Error>)->Void)) {
        let param = [
            "FileId": fileId,
            "PhotoTitle": photoTitle,
            "SessionId": sessionId,
            "StoreName": storeName,
            "UploadType": "manual",
        ]
//        response(action: "CreatePhoto", param: param, queue: queue, complete: complete)
        response(action: "CreatePhoto", param: param, queue: queue) { (result: Result<AliyunPhotoResponse, Error>) in
            switch result {
            case .success(let resp):
                self.completeResult(result: .success(resp.Photo), queue: queue, complete: complete)
            case .failure(let error):
                self.completeResult(result: .failure(error), queue: queue, complete: complete)
            }
        }
    }

    private func getBy(md5: String, storeName: String, queue: DispatchQueue? = nil, complete: @escaping ((Result<AliyunPhoto?, Error>)->Void)) {
        let param = [
            "Md5.1": md5,
            "StoreName": storeName,
            "State": "all"
        ]
        response(action: "GetPhotosByMd5s", param: param, queue: queue) { (result: Result<AliyunPhotosResponse, Error>) in
            switch result {
            case .success(let resp):
                self.completeResult(result: .success(resp.Photos.first), queue: queue, complete: complete)
            case .failure(let error):
                self.completeResult(result: .failure(error), queue: queue, complete: complete)
            }
        }
    }
    
    func getPhoto(id: Int, storeName: String, queue: DispatchQueue? = nil, complete: @escaping (Result<AliyunPhoto?, Error>) -> Void) {
        let param = [
            "PhotoId.1": "\(id)",
            "StoreName": storeName
        ]
        response(action: "GetPhotos", param: param, queue: queue) { (result: Result<AliyunPhotosResponse, Error>) in
            switch result {
            case .success(let resp):
                self.completeResult(result: .success(resp.Photos.first), queue: queue, complete: complete)
            case .failure(let error):
                self.completeResult(result: .failure(error), queue: queue, complete: complete)
            }
        }
    }
    
    func getURL(id: Int, storeName: String, zoomType: String) {
        
    }
}

// cache
extension AliyunMediaCloudClient {
    
    private func cacheImage() {
    
    }
}

import CommonCrypto
extension Data {
    func getMD5String() -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ = withUnsafeBytes { (bytes) in
            CC_MD5(bytes, CC_LONG(count), &digest)
        }
        var digestHex = ""
        for index in 0 ..< Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
}

extension AliyunMediaCloudClient: MediaCloudClient {
    
    func upload(data: Data, name: String, pathExtension: String, queue: DispatchQueue? = nil, complete: @escaping (Result<MediaItem, Error>) -> Void) {
        let md5 = data.getMD5String()
        getBy(md5: md5, storeName: storeName) { (result) in
            switch result {
            case .success(let photo):
                if let photo = photo {
                    self.completeResult(result: .success(photo), queue: queue, complete: complete)
                } else {
                    self.createTransaction(ext: pathExtension, md5: md5, size: data.count, storeName: self.storeName) { (result) in
                        switch result {
                        case .success(let upload):
                            let putRequest = OSSPutObjectRequest()
                            let provider = OSSStsTokenCredentialProvider(accessKeyId: upload.AccessKeyId, secretKeyId: upload.AccessKeySecret, securityToken: upload.StsToken)
                            let ossClient = OSSClient(endpoint: upload.OssEndpoint, credentialProvider: provider)
                            self.client = ossClient
                            putRequest.uploadingData = data
                            putRequest.objectKey = upload.ObjectKey
                            putRequest.bucketName = upload.Bucket
                            putRequest.contentType = "image/jpeg"
                            putRequest.contentDisposition = "inline; filename=\"\(name)\""
                            let putTask = ossClient.putObject(putRequest)
                            self.task = putTask
                            putTask.continue ({ (task) -> Any? in
                                if task.error != nil {
                                    self.completeResult(result: .failure(task.error!), queue: queue, complete: complete)
                                    return nil
                                }
                                self.createPhoto(fileId: upload.FileId, photoTitle: name, sessionId: upload.SessionId, storeName: self.storeName) { result in
                                    switch result {
                                    case .success(let photo):
                                        self.completeResult(result: .success(photo), queue: queue, complete: complete)
                                    case .failure(let error):
                                        self.completeResult(result: .failure(error), queue: queue, complete: complete)
                                    }
                                }
                                return nil
                            })
                            
                        case .failure(let error):
                            self.completeResult(result: .failure(error), queue: queue, complete: complete)
                        }
                    }

                }
            case .failure(let error):
                self.completeResult(result: .failure(error), queue: queue, complete: complete)
            }
        }
    }
    
    func requestImage(item: MediaItem, size: MediaImageSize, queue: DispatchQueue?, complete: @escaping (Result<UIImage, Error>) -> Void) {
        assert(false)
    }

}
