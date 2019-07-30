//
//  Request.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2019/5/5.
//  Copyright © 2019 wujianguo. All rights reserved.
//


import Foundation

enum APIError: Error {
    case serverError(Int, String)
    case networkError(Int, String)
    case defaultError
}

protocol APIResponseProtocol: Decodable {
    var msg: String { get }
    var code: Int { get }
    var error: Error? { get }
}

struct APIResponse<T: Decodable> : APIResponseProtocol {
    let msg: String
    let code: Int
    let data: T?
    
    var error: Error? {
        if code != 0 {
            return APIError.serverError(code, msg)
        }
        return nil
    }
}

struct APIResponseErrorData: Decodable {
    let code: Int
    let error: String
}

struct APIRequest {
    
    static var accessToken: String? = nil
    
    static let root = "https://1807399101089095.cn-shanghai.fc.aliyuncs.com/2016-08-15/proxy/Jarvis/jarvis"
    
    static func url(endpoint: String) -> URL {
        if endpoint.hasPrefix("http://") || endpoint.hasPrefix("https://") {
            return URL(string: endpoint)!
        }
        
//        return URL(string: "http://192.168.33.14:8888")!.appendingPathComponent(endpoint)
        return URL(string: root)!.appendingPathComponent(endpoint)
    }
    
    let request: URLRequest
    
    init(get endpoint: String, query: [String: Any] = [:]) {
        var components = URLComponents(string: APIRequest.url(endpoint: endpoint).absoluteString)!
        var queryItems = [URLQueryItem]()
        for (k, v) in query {
            queryItems.append(URLQueryItem(name: k, value: "\(v)"))
        }
        components.queryItems = queryItems
        var req = URLRequest(url: components.url!)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = APIRequest.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request = req
    }

    init(post endpoint: String, query: [String: Any] = [:], body: Data, contentType: String = "application/json") {
        var components = URLComponents(string: APIRequest.url(endpoint: endpoint).absoluteString)!
        var queryItems = [URLQueryItem]()
        for (k, v) in query {
            queryItems.append(URLQueryItem(name: k, value: "\(v)"))
        }
        components.queryItems = queryItems
        var req = URLRequest(url: components.url!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue(contentType, forHTTPHeaderField: "Content-Type")
        if let token = APIRequest.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        req.httpBody = body
        request = req
    }

    
    @discardableResult
    func response<T: Decodable>(queue: DispatchQueue? = nil, complete: ((Result<T, Error>)->Void)? = nil) -> URLSessionDataTask {
//        debugPrint(request.url!)
        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
            if let res = response as? HTTPURLResponse {
                if res.statusCode >= 400 {
                    if data != nil {
                        if let ret = try? JSONDecoder().decode(APIResponseErrorData.self, from: data!) {
                            let error = APIError.serverError(ret.code, ret.error)
                            self.completeResult(result: .failure(error), queue: queue, complete: complete)
                            return
                        } else {
                            let error = APIError.serverError(res.statusCode, HTTPURLResponse.localizedString(forStatusCode: res.statusCode))
                            self.completeResult(result: .failure(error), queue: queue, complete: complete)
                            return
                        }
                    }
                }
            }
            if let err = err {
                self.completeResult(result: .failure(err), queue: queue, complete: complete)
            } else if let data = data {
                do {
                    let str = String(data: data, encoding: .utf8)!
//                    debugPrint(str)
                    let ret = try JSONDecoder().decode(T.self, from: data)
                    self.completeResult(result: .success(ret), queue: queue, complete: complete)
                } catch {
                    self.completeResult(result: .failure(error), queue: queue, complete: complete)
                }
            } else {
                self.completeResult(result: .failure(APIError.defaultError), queue: queue, complete: complete)
            }
        }
        task.resume()
        return task
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
}
