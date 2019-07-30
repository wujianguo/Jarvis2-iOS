//
//  StaticTableViewController.swift
//  NeteaseIM
//
//  Created by Jianguo Wu on 2018/7/10.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import UIKit


protocol StaticTableViewCellEvent {
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    
}

class StatictableViewCell: UITableViewCell, StaticTableViewCellEvent {
    
    var onConfig: (() -> Void)? = nil
    var onSelect: (() -> Void)? = nil
    
    var height: CGFloat {
        return 0
    }
}

class StaticTableSection  {
    var title: String? = nil
    var cells: [StatictableViewCell] = []
}

class StaticButtonTableViewCell: StatictableViewCell {
    
    override var height: CGFloat {
        return 40
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    func setup() {
        contentView.addSubview(nameLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false;
        contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0))
    }

}

class StaticTableViewController: UITableViewController {

    var sections: [StaticTableSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func layoutFooterButton(button: UIButton) {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        
        footer.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        footer.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: footer, attribute: .top, multiplier: 1, constant: 0))
        footer.addConstraint(NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: footer, attribute: .bottom, multiplier: 1, constant: 0))
        footer.addConstraint(NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: footer, attribute: .leadingMargin, multiplier: 1, constant: 0))
        footer.addConstraint(NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: footer, attribute: .trailingMargin, multiplier: 1, constant: 0))
        
        tableView.tableFooterView = footer
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sections[indexPath.section].cells[indexPath.row]
        cell.onConfig?()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section].cells[indexPath.row].onSelect?()
    }
}
