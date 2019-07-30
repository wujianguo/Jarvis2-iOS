//
//  MessageHUD.swift
//  NeteaseIM
//
//  Created by Jianguo Wu on 2018/7/2.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import Foundation
import PKHUD

extension Error {
    
    var hudDescription: String {
        if let error = self as? DecodingError {
            switch error {
            case .keyNotFound(let codingKey, _):
                return "'\(codingKey.stringValue)' key not found"
            default:
                return "\(error)"
            }
        }
        if let error = self as? APIError {
            switch error {
            case .networkError(let code, let message):
                return "\(message)(\(code))"
            case .serverError(let code, let message):
                return "\(message)(\(code))"
            case .defaultError:
                return "unknown error"
            }
        }
        let err = self as NSError
        if let des = err.localizedFailureReason {
            return des
        }
        return err.localizedDescription
    }
    
}

struct HUDWrapper {
    
    static func startLoading() {
        HUD.show(.systemActivity)
    }
    
    static func tipSuccessOrFailure(error: Error?) {
        HUD.hide(animated: false)
        if let error = error {
            HUD.flash(.label(error.hudDescription), delay: 2)
        } else {
            HUD.flash(.label(Strings.ok), delay: 2)
        }
    }
    
    static func stopLoading(error: Error?) {
        if let error = error {
            HUD.hide(animated: false)
            HUD.flash(.label(error.hudDescription), delay: 2)
        } else {
            HUD.hide()
        }
    }
    
}
