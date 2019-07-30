//
//  ActivityIndicatorTextButton.swift
//  NeteaseIM
//
//  Created by Jianguo Wu on 2018/7/13.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import UIKit

class ActivityIndicatorTextButton: UIButton {

    init(title: String, loadingTitle: String) {
        super.init(frame: .zero)
        self.title = title
        self.loadingTitle = loadingTitle
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var title: String!
    
    var loadingTitle: String!
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    
    func setup() {
        setTitle(title, for: .normal)
        backgroundColor = UIConstants.themeColor
        layer.masksToBounds = true
        layer.cornerRadius = 4
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = UIConstants.themeColor.darker()
            } else {
                backgroundColor = UIConstants.themeColor
            }
        }
    }
    
    func startLoading() {
        setTitle(loadingTitle, for: .disabled)
        isEnabled = false
        backgroundColor = UIConstants.themeColor.lighter()
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .trailing, relatedBy: .equal, toItem: titleLabel, attribute: .leading, multiplier: 1, constant: -UIConstants.padding))
    }
    
    func stopLoading() {
        setTitle(title, for: .disabled)
        backgroundColor = UIConstants.themeColor
        isEnabled = true
        activityIndicator.removeFromSuperview()
    }

}
