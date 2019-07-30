//
//  MediaSyncViewController.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2019/5/6.
//  Copyright © 2019 wujianguo. All rights reserved.
//

import UIKit
import Photos
import SnapKit

class MediaSyncViewController: UIViewController {

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.setTitle("start", for: .normal)
        button.setTitle("stop", for: .selected)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.addTarget(self, action: #selector(startButtonClick(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "hello"
        return label
    }()
    
    private lazy var mediaManager: MediaManager = {
        let manager = MediaManager()
        manager.delegate = self
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "logout", style: .plain, target: self, action: #selector(logoutButtonClick(sender:)))

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.addArrangedSubview(startButton)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(statusLabel)

        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                
            }
        }
    }
    
    @objc func logoutButtonClick(sender: UIBarButtonItem) {
        UIApplication.shared.account.signout(complete: nil)
        let vc = SigninViewController<UserAccount>(account: UIApplication.shared.account)
        let nav = UINavigationController(rootViewController: vc)
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = nav
    }
    
    @objc func startButtonClick(sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            mediaManager.startSync()
        } else {
            mediaManager.stopSync()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MediaSyncViewController: PhotoUploadDelegate {
    
    func photoUploadStateChangedTo(state: PhotoUploadState) {
        switch state {
        case .start(let index):
            statusLabel.text = "start \(index)"
        case .thumbnail(let image):
            imageView.image = image
        case .origin(let image):
            imageView.image = image
        case .uploading:
            statusLabel.text = "uploading"
        case .failure(let reason):
            statusLabel.text = reason
        case .done:
            statusLabel.text = "done"
        }
    }
}
