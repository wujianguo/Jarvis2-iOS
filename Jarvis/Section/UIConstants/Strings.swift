//
//  Strings.swift
//  NeteaseIM
//
//  Created by Jianguo Wu on 2018/5/23.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import Foundation

struct Strings {
    
}

// tab
extension Strings {
    static let contact = NSLocalizedString("Contact", comment: "contact")
    static let me      = NSLocalizedString("Me", comment: "me")
}

// status
extension Strings {
    static let connecting   = NSLocalizedString("Connecting", comment: "Connecting")
    static let disconnected = NSLocalizedString("Disconnected", comment: "Disconnected")
}

// message
extension Strings {
    static let notSupportYet = NSLocalizedString("[not support yet.]", comment: "[not support yet.]")
    static let ID            = NSLocalizedString("ID", comment: "ID")
}

// signin & signup
extension Strings {
    static let inputNamePlaceholder     = NSLocalizedString("user name for login", comment: "input your user name")
    static let inputNickPlaceholder     = NSLocalizedString("input your nick name", comment: "input your nick name")
    static let inputPasswordPlaceholder = NSLocalizedString("input your password", comment: "input your password")
    
    static let account          = NSLocalizedString("Account", comment: "Account")
    static let nickName         = NSLocalizedString("Nick name", comment: "Nick name")
    static let password         = NSLocalizedString("Password", comment: "Password")
    
    static let signin           = NSLocalizedString("Sign in", comment: "Sign in")
    static let signup           = NSLocalizedString("Sign up", comment: "Sign up")
    static let signout          = NSLocalizedString("Sign out", comment: "Sign out")
    static let confirmSignout   = NSLocalizedString("Are you sure?", comment: "Are you sure?")
    
    static let accountPasswordError     = NSLocalizedString("Account or password error", comment: "Account or password error")
    static let alreadyRegistered = NSLocalizedString("Already registered", comment: "Already registered")
}

// contact
extension Strings {
    static let inputAccount  = NSLocalizedString("input account", comment: "input account")
    static let requestFriend = NSLocalizedString("Request friend", comment: "Request friend")
    static let startChat     = NSLocalizedString("Start chat", comment: "Start chat")
    static let postscript    = NSLocalizedString("postscript", comment: "postscript")
}

// common
extension Strings{
    static let ok       = NSLocalizedString("OK", comment: "OK")
    static let cancel   = NSLocalizedString("Cancel", comment: "Cancel")
}
