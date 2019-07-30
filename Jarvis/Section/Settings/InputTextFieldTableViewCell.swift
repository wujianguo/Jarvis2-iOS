//
//  InputTextFieldTableViewCell.swift
//  NeteaseIM
//
//  Created by Jianguo Wu on 2018/7/13.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import UIKit

class InputTextFieldTableViewCell: StatictableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.preferredFont(forTextStyle: .title2)
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()
    
    func setup() {
        contentView.addSubview(label)
        contentView.addSubview(textField)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .topMargin, multiplier: 1, constant: 0))
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailingMargin, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1, constant: UIConstants.padding * 2))
        contentView.addConstraint(NSLayoutConstraint(item: textField, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -UIConstants.padding))
    }
    
}
