//
//  AliyunObjectAccess.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2019/6/10.
//  Copyright © 2019 wujianguo. All rights reserved.
//

import Foundation
import CommonCrypto
import AliyunOSSiOS

struct AliyunSignature {
    
    static func makeDigest(message: String, key: String) -> String {
        let cMessage = message.cString(using: .utf8)
        let cMessageLen = message.lengthOfBytes(using: .utf8)
        
        let cKey = key.cString(using: .utf8)
        let cKeyLen = key.lengthOfBytes(using: .utf8)
        
        let digestLen = CC_SHA1_DIGEST_LENGTH
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: Int(digestLen))
        
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), cKey!, cKeyLen, cMessage!, cMessageLen, result)

//        let ret = String(cString: result)
        let ret = Data(bytes: result, count: Int(digestLen)).base64EncodedString()
        result.deallocate()
        return ret
    }
    
    static func signature(params: [String: String], accessKeyId: String, accessKeySecret: String, version: String, securityToken: String? = nil) -> [String: String] {
        var input = params
        input["Format"] = "JSON"
        input["Version"] = version
        input["SignatureMethod"] = "HMAC-SHA1"
        input["SignatureVersion"] = "1.0"
        input["SignatureNonce"] = "\(Int.random(in: 100000..<1000000))"
        input["AccessKeyId"] = accessKeyId
        let timestamp = ISO8601DateFormatter().string(from: Date(timeIntervalSinceNow: 0))
        input["Timestamp"] = timestamp
        if let token = securityToken {
            input["SecurityToken"] = token
        }
        let sortedInput = input.sorted { (item1, item2) -> Bool in
            return item1.key > item2.key
        }
        let queryArray: [String] = sortedInput.map {
            "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        }
        let s1 = queryArray.joined(separator: "&")
        print(s1)
        let s2 = "GET&%2F&\(s1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        print(s2)
        let s3 = makeDigest(message: s2, key: "\(accessKeySecret)&")
        print(s3)
        input["Signature"] = s3
        return input
    }

    static func signature2(action: String, params: [String: String], accessKeyId: String, accessKeySecret: String, version: String, securityToken: String, timestamp: String, nonce: String) -> [String: String] {
        var input = params
        input["Action"] = action
        input["Format"] = "JSON"
        input["Version"] = version
        input["SignatureMethod"] = "HMAC-SHA1"
        input["SignatureVersion"] = "1.0"
        input["SignatureNonce"] = nonce
        input["AccessKeyId"] = accessKeyId
        input["Timestamp"] = timestamp
        input["SecurityToken"] = securityToken
        let sortedInput = input.sorted { (item1, item2) -> Bool in
            return item1.key < item2.key
        }
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: ":#[]@=&()*+,;'!$/")
//        allowedCharacterSet.insert(charactersIn: "!$&'()*+,;")
        let queryArray: [String] = sortedInput.map {
            "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!)"
        }
        let s1 = queryArray.joined(separator: "&")
//        print(s1)
//        print("=====")
        let s2 = "GET&%2F&\(s1.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!)"
//        print(s2)
//        print("=====")
//        print(accessKeySecret)
        let s3 = makeDigest(message: s2, key: "\(accessKeySecret)&")
//        print(s3)
        input["Signature"] = s3
        return input
    }
    
    static func test() {
        let timestamp = "2019-06-11T11:28:19"
        let nonce = "3847474"
        let ret = signature2(action: "", params: ["a": "1"], accessKeyId: "accessKeyId", accessKeySecret: "accessKeySecret", version: "version", securityToken: "securityToken", timestamp: timestamp, nonce: nonce)
//        print(ret)
    }

}
/*
class AliyunCredentialProvider2 {
    
    var credential: AliyunCredential? = nil
    
    func getCredential(complete: @escaping (Result<AliyunCredential, Error>) -> Void) {
        if credential != nil {
            complete(credential, nil)
            return
        }
        APIRequest(get: "/aliyun/photo/credential").response(success: { (credential: AliyunCredential) in
            self.credential = credential
            complete(self.credential, nil)
        }) { (error) in
            complete(nil, error)
        }
    }
    
}
*/
/*
class AliyunCloudPhotoClient {
    
    let endpoint: URL
    let credentialProvider: AliyunCredentialProvider

    
    init(endpoint: URL, credentialProvider: AliyunCredentialProvider) {
        self.endpoint = endpoint
        self.credentialProvider = credentialProvider
    }
    
    func buildRequest(action: String, param: [String: Any] = [:], credential: AliyunCredential) -> URLRequest {
        let request = URLRequest(url: endpoint)
        return request
    }
    
    func response<T: Decodable>(action: String, param: [String: Any] = [:], success: ((T)->Void)?, failure: ((Error)->Void)?) {
        credentialProvider.getCredential { (credential, error) in
            guard let credential = credential else {
                failure?(error!)
                return
            }
            let request = self.buildRequest(action: action, param: param, credential: credential)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let err = error {
                    DispatchQueue.main.async {
                        failure?(err)
                    }
                } else if let data = data {
                    do {
                        let ret = try JSONDecoder().decode(T.self, from: data)
                        DispatchQueue.main.async {
                            success?(ret)
                        }
                    } catch {
                        debugPrint(String(data: data, encoding: .utf8) ?? "")
                        DispatchQueue.main.async {
                            debugPrint(error)
                            failure?(error)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        failure?(APIError.defaultError)
                    }
                }

            })
            task.resume()
        }
    }
    
    
    struct AliyunTransactionResponse: Decodable {
        let Action: String
        let Message: String
        let Code: String
        let RequestId: String
        
        let Transaction: [AliyunUpload]
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

    func createTransaction(ext: String, md5: String, size: Int, storeName: String, success: ((AliyunUpload)->Void)?, failure: ((Error)->Void)?) {
        let param = [
            "Ext": ext,
            "Md5": md5,
            "Size": "\(size)",
            "StoreName": storeName
        ]
        response(action: "CreateTransaction", param: param, success: { (item: AliyunTransactionResponse) in
            success?(item.Transaction.first!)
        }) { (error) in
            failure?(error)
        }
    }
    
    struct AliyunPhotoResponse: Decodable {
        let Action: String
        let Message: String
        let Code: String
        let RequestId: String

        let Photo: AliyunPhoto
    }
    
    struct AliyunPhoto: Decodable {
        let Ctime: String
        let FileId: String
        let Height: Int
        let Width: Int
        let Id: Int
        let Md5: String
        let Mtime: String
        let State: String
        let Title: String
        let Remark: String
        let TakenAt: Int
    }
    
    
    func createPhoto(fileId: String, photoTitle: String, sessionId: String, storeName: String, success: ((AliyunPhoto)->Void)?, failure: ((Error)->Void)?) {
        let param = [
            "FileId": fileId,
            "PhotoTitle": photoTitle,
            "SessionId": sessionId,
            "StoreName": storeName,
            "UploadType": "manual",
        ]
        response(action: "CreatePhoto", param: param, success: { (item: AliyunPhotoResponse) in
            success?(item.Photo)
        }) { (error) in
            failure?(error)
        }
    }

}


class AliyunObjectAccess {
    
//    var credential: AliyunCredential?
    lazy var client: AliyunCloudPhotoClient = {
        let credential = AliyunCredentialProvider()
        return AliyunCloudPhotoClient(endpoint: URL(string: "")!, credentialProvider: credential)
    }()
    
//    lazy var credentialProvider: OSSFederationCredentialProvider = {
//        let credentialProvider = OSSFederationCredentialProvider { () -> OSSFederationToken? in
//            let semaphore = DispatchSemaphore(value: 0)
//            APIRequest(get: "/aliyun/photo/credential").response(success: { (credential: AliyunCredential) in
//                self.credential = credential
//                semaphore.signal()
//            }) { (error) in
//                semaphore.signal()
//            }
//            semaphore.wait()
//            if let credential = self.credential {
//                let token = OSSFederationToken()
//                token.tAccessKey = credential.accessKeyId
//                token.tSecretKey = credential.accessKeySecret
//                token.tToken = credential.securityToken
//                token.expirationTimeInGMTFormat = credential.expiration
//                return token
//            } else {
//                return nil
//            }
//        }
//        return credentialProvider
//    }()
    
    init() {

    }
    
//    func updateCredentialsIfNeed(complete: @escaping (Error?) -> Void) {
//        if credential != nil {
//            complete(nil)
//            return
//        }
//        APIRequest(get: "/aliyun/photo/credential").response(success: { (credential: AliyunCredential) in
//            self.credential = credential
//            let provider = OSSStsTokenCredentialProvider(accessKeyId: credential.accessKeyId, secretKeyId: credential.accessKeySecret, securityToken: credential.securityToken)
//            self.client = OSSClient(endpoint: "", credentialProvider: provider)
//            complete(nil)
//        }) { (error) in
//            complete(error)
//        }
//    }
    
    func upload(data: Data, name: String, complete: @escaping (Error?) -> Void) {
        client.createTransaction(ext: "", md5: "", size: 40, storeName: "", success: { (upload) in
            let putRequest = OSSPutObjectRequest()
            let provider = OSSStsTokenCredentialProvider(accessKeyId: upload.AccessKeyId, secretKeyId: upload.AccessKeySecret, securityToken: upload.StsToken)
            let ossClient = OSSClient(endpoint: upload.OssEndpoint, credentialProvider: provider)
            let putTask = ossClient.putObject(putRequest)
            putTask.continue ({ (task) -> Any? in
                self.client.createPhoto(fileId: upload.FileId, photoTitle: "", sessionId: upload.SessionId, storeName: "", success: { (photo) in
                    
                }, failure: { (error) in
                    
                })
                DispatchQueue.main.async {
                    complete(task.error)
                }
                return nil
            })

        }) { (error) in
            complete(error)
        }
//        self.client = OSSClient(endpoint: "", credentialProvider: credentialProvider)
//        let client = self.client!

    }
}
*/
