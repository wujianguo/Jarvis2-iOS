//
//  AliyunCredential.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2019/6/10.
//  Copyright © 2019 wujianguo. All rights reserved.
//

import Foundation

struct AliyunCredential: Decodable {
    let accessKeyId: String
    let accessKeySecret: String
    let securityToken: String
    let expiration: String
}
