//
//  Database.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2019/6/15.
//  Copyright © 2019 wujianguo. All rights reserved.
//

import Foundation
import WCDBSwift

class DatabaseClient {

    let queue: DispatchQueue
    var client: Database?
    
    init() {
        self.queue = DispatchQueue(label: "database")
    }
    
    func open(path: String) {
        queue.async {
            self.client = Database(withPath: path)
            try? self.client?.create(table: self.uploadStateTableName, of: UploadState.self)
        }
    }
    
    func close() {
        queue.async {
            self.client?.close()
        }
    }
}

// upload
extension DatabaseClient {
    
    var uploadStateTableName: String {
        return "upload_state"
    }
    
    func insert(upload: UploadState) {
        queue.async {
            try? self.client?.insert(objects: upload, intoTable: self.uploadStateTableName)
        }
    }
    
    func query(localIdentifier: String, complete: @escaping (UploadState?) -> Void) {
        queue.async {
            do {
                
                let upload: UploadState? = try self.client?.getObject(on: [UploadState.Properties.localIdentifier, UploadState.Properties.remoteIdentifier], fromTable: self.uploadStateTableName, where: UploadState.Properties.localIdentifier.asExpression() == localIdentifier)
                DispatchQueue.main.async {
                    complete(upload)
                }
            } catch {
                DispatchQueue.main.async {
                    complete(nil)
                }
            }
        }
    }
    
}

// album
extension DatabaseClient {
    
}
