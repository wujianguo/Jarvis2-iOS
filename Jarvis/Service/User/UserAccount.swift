//
//  UserAccount.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2018/10/11.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import Foundation
//import SQLite.Swift

typealias Completion = (Error?) -> Void

let AccountStatusChangedNotificationName = Notification.Name("AccountStatusChangedNotificationName")


struct AccountSignupData: Codable {
    
    let username: String
    
    let password: String
    
    let nickname: String
}

struct AccountSigninData: Codable {
    
    let username: String
    
    let password: String
    
}

struct AccountUser: Codable {
    
    let username: String
    
    let sessionToken: String
    
    var unique: String {
        return username
    }
    
//    let accid: String
}


protocol AccountProtocol {

    static func canAutoSignin() -> Bool
    
    static func lastUsername() -> String?
    
    func signup(data: AccountSignupData, complete: Completion?)
    
    func signin(data: AccountSigninData, complete: Completion?)
    
    func autoSignin()
    
    func signout(complete: Completion?)

}

//class AppUser: LCUser {
//
//}

class UserAccount: AccountProtocol {

    static let UserNameKey     = "Account.UserName"
    static let AccessTokenKey  = "Account.AccessToken"

    static func canAutoSignin() -> Bool {
        guard UserDefaults.standard.string(forKey: UserAccount.UserNameKey) != nil else {
            return false
        }
        guard UserDefaults.standard.string(forKey: UserAccount.AccessTokenKey) != nil else {
            return false
        }
        return true
    }
    
    static func lastUsername() -> String? {
        return UserDefaults.standard.string(forKey: UserAccount.UserNameKey)
    }
    

    var user: AccountUser! = nil
    let database = DatabaseClient()

    func signup(data: AccountSignupData, complete: Completion?) {
        let req = APIRequest(post: "/users", body: try! JSONEncoder().encode(data))
        req.response { (result: Result<AccountUser, Error>) in
            switch result {
            case .success(let user):
                UserDefaults.standard.set(user.sessionToken, forKey: UserAccount.AccessTokenKey)
                UserDefaults.standard.set(user.username, forKey: UserAccount.UserNameKey)
                self.user = user
                self.onLogin()
                DispatchQueue.main.async {
                    complete?(nil)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    complete?(error)
                }
            }
        }
    }
    
    func signin(data: AccountSigninData, complete: Completion?) {
        let req = APIRequest(post: "/auth/login", body: try! JSONEncoder().encode(data))
        req.response { (result: Result<AccountUser, Error>) in
            switch result {
            case .success(let user):
                UserDefaults.standard.set(user.sessionToken, forKey: UserAccount.AccessTokenKey)
                UserDefaults.standard.set(user.username, forKey: UserAccount.UserNameKey)
                self.user = user
                self.onLogin()
                APIRequest.accessToken = user.sessionToken
                DispatchQueue.main.async {
                    complete?(nil)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    complete?(error)
                }
            }

        }
    }
    
    func autoSignin() {
        guard let token = UserDefaults.standard.string(forKey: UserAccount.AccessTokenKey) else {
            assert(false)
            return
        }
        guard let name = UserDefaults.standard.string(forKey: UserAccount.UserNameKey) else {
            assert(false)
            return
        }
        self.user = AccountUser(username: name, sessionToken: token)
        APIRequest.accessToken = token
        self.onLogin()
    }
    
    func signout(complete: Completion?) {
        database.close()
        APIRequest.accessToken = nil
        UserDefaults.standard.removeObject(forKey: UserAccount.AccessTokenKey)
        complete?(nil)
    }
    
    private func onLogin() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(self.user.unique)
        try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        let full = path.appendingPathComponent("\(self.user.unique).db")
        database.open(path: full.relativePath)
    }
    
//    private var db: Connection! = nil
    private func onSigninSuccess() {
//        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(self.user.username)
//        try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
//        db = try! Connection(path.appendingPathComponent("media.sqlite3").absoluteString)
//
//        let media = Table("media")
//        let id = Expression<Int64>("id")
//        let localIdentifier = Expression<String>("localIdentifier")
//        _ = try? db.run(media.create(ifNotExists: true) { t in
//            t.column(id, primaryKey: .autoincrement)
//            t.column(localIdentifier, unique: true)
//        })
    }
    
    func save(localIdentifier: String) {
//        let media = Table("media")
//        let localIdentifierEx = Expression<String>("localIdentifier")
//        let insert = media.insert(localIdentifierEx <- localIdentifier)
//        _ = try? db.run(insert)
    }
    
    func query(localIdentifier: String) -> Bool {
//        let media = Table("media")
//        let localIdentifierEx = Expression<String>("localIdentifier")
//        let query = media.filter(localIdentifierEx == localIdentifier)
//        if let count = try? db.scalar(query.count) {
//            return count > 0
//        }
        return false
    }
    
}
