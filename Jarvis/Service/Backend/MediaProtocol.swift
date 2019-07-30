//
//  MediaProtocol.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2019/6/15.
//  Copyright © 2019 wujianguo. All rights reserved.
//

import Foundation
import UIKit

enum MediaImageSize {
    case thumbnail
    case origin
}

protocol MediaItem {
    
    var size: CGSize { get }
    
    var title: String { get }
    
    var id: Int { get }
    
    var takenAt: Date { get }
    
    var updatedAt: Date { get }
    
    var createdAt: Date { get }
 
}

protocol MediaCloudClient {
    
    func upload(data: Data, name: String, pathExtension: String, queue: DispatchQueue?, complete: @escaping (Result<MediaItem, Error>) -> Void)

    func requestImage(item: MediaItem, size: MediaImageSize, queue: DispatchQueue?, complete: @escaping (Result<UIImage, Error>) -> Void)

    func requestPhotoList(takenAt: Date, complete: @escaping (Result<[MediaItem], Error>) -> Void)
}
