//
//  SignupViewController.swift
//  NeteaseIM
//
//  Created by Jianguo Wu on 2018/6/5.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import UIKit


class SignupViewController<AccountType: AccountProtocol>: StaticTableViewController, UITextFieldDelegate {
    
    var success: ((String) -> Void)? = nil
    
    let account: AccountType!
    
    init(account: AccountType) {
        self.account = account
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var accountCell: InputTextFieldTableViewCell!
    var nickCell: InputTextFieldTableViewCell!
    var passwordCell: InputTextFieldTableViewCell!
    var signupButton: ActivityIndicatorTextButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.signup

        let inputSection = StaticTableSection()
        accountCell = InputTextFieldTableViewCell(style: .default, reuseIdentifier: nil)
        accountCell.onConfig = {
            self.accountCell.selectionStyle = .none
            self.accountCell.textField.keyboardType = .asciiCapable
            self.accountCell.textField.returnKeyType = .next
            self.accountCell.textField.delegate = self
            self.accountCell.label.text = Strings.account
        }
        
        nickCell = InputTextFieldTableViewCell(style: .default, reuseIdentifier: nil)
        nickCell.onConfig = {
            self.nickCell.selectionStyle = .none
            self.nickCell.textField.keyboardType = .asciiCapable
            self.nickCell.textField.returnKeyType = .next
            self.nickCell.textField.delegate = self
            self.nickCell.label.text = Strings.nickName
        }

        passwordCell = InputTextFieldTableViewCell(style: .default, reuseIdentifier: nil)
        passwordCell.onConfig = {
            self.passwordCell.selectionStyle = .none
            self.passwordCell.label.text = Strings.password
            self.passwordCell.textField.isSecureTextEntry = true
            self.passwordCell.textField.returnKeyType = .join
            self.passwordCell.textField.delegate = self
        }
        inputSection.cells = [accountCell, nickCell, passwordCell]
        
        sections = [inputSection]
        
        signupButton = ActivityIndicatorTextButton(title: Strings.signup, loadingTitle: Strings.signup)
        signupButton.addTarget(self, action: #selector(signupClick(sender:)), for: .touchUpInside)
        layoutFooterButton(button: signupButton)
        
        accountCell.textField.becomeFirstResponder()
    }
    
    func signup(name: String, nick: String, password: String, complete: (() -> Void)? = nil) {
        let data = AccountSignupData(username: name, password: password, nickname: nick)
        account.signup(data: data) { (error) in
            HUDWrapper.stopLoading(error: error)
            complete?()
            guard error == nil else {
                return
            }
            self.success?(name)
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc func signupClick(sender: ActivityIndicatorTextButton) {
        guard let name = accountCell.textField.text?.trimmingCharacters(in: .whitespaces), let nick = nickCell.textField.text?.trimmingCharacters(in: .whitespaces), let password = passwordCell.textField.text?.trimmingCharacters(in: .whitespaces) else {
            return
        }
        guard name.count > 0 && password.count > 0 && nick.count > 0 else {
            return
        }
        accountCell.textField.isEnabled = false
        nickCell.textField.isEnabled = false
        passwordCell.textField.isEnabled = false
        sender.startLoading()
        
        signup(name: name, nick: nick, password: password) {
            sender.stopLoading()
            self.accountCell.textField.isEnabled = true
            self.nickCell.textField.isEnabled = true
            self.passwordCell.textField.isEnabled = true
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == accountCell.textField {
            nickCell.textField.becomeFirstResponder()
        } else if textField == nickCell.textField {
            passwordCell.textField.becomeFirstResponder()
        } else if textField == passwordCell.textField {
            if signupButton.isEnabled {
                signupClick(sender: signupButton)
                return false
            }
        }
        return true
    }
}
