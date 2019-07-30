//
//  SigninViewController.swift
//  NeteaseIM
//
//  Created by Jianguo Wu on 2018/6/5.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import UIKit

class SigninViewController<AccountType: AccountProtocol>: StaticTableViewController, UITextFieldDelegate {
    
    let account: AccountType!
    
    init(account: AccountType) {
        self.account = account
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var accountCell: InputTextFieldTableViewCell!
    var passwordCell: InputTextFieldTableViewCell!
    var signinButton: ActivityIndicatorTextButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Strings.signin
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.signup, style: .plain, target: self, action: #selector(signupClick(sender:)))

        let inputSection = StaticTableSection()
        accountCell = InputTextFieldTableViewCell(style: .default, reuseIdentifier: nil)
        accountCell.onConfig = {
            self.accountCell.selectionStyle = .none
            self.accountCell.textField.keyboardType = .asciiCapable
            self.accountCell.textField.returnKeyType = .next
            self.accountCell.textField.delegate = self
            self.accountCell.label.text = Strings.account
            self.accountCell.textField.text = AccountType.lastUsername()
        }
        passwordCell = InputTextFieldTableViewCell(style: .default, reuseIdentifier: nil)
        passwordCell.onConfig = {
            self.passwordCell.selectionStyle = .none
            self.passwordCell.label.text = Strings.password
            self.passwordCell.textField.returnKeyType = .done
            self.passwordCell.textField.delegate = self
            self.passwordCell.textField.isSecureTextEntry = true
        }
        inputSection.cells = [accountCell, passwordCell]
        
        sections = [inputSection]
        
        signinButton = ActivityIndicatorTextButton(title: Strings.signin, loadingTitle: Strings.signin)
        signinButton.addTarget(self, action: #selector(signinClick(sender:)), for: .touchUpInside)
        
        layoutFooterButton(button: signinButton)        
        accountCell.textField.becomeFirstResponder()
    }

    func signin(name: String, password: String, complete: (() -> Void)? = nil) {
        let data = AccountSigninData(username: name, password: password)
        account.signin(data: data) { (error) in
            HUDWrapper.stopLoading(error: error)
            complete?()
            guard error == nil else {
                return
            }
            
            let vc = MediaSyncViewController()
            let nav = UINavigationController(rootViewController: vc)
            let app = UIApplication.shared.delegate as! AppDelegate
            app.window?.rootViewController = nav
        }
    }
    
    @objc func signinClick(sender: ActivityIndicatorTextButton) {
        guard let name = accountCell.textField.text?.trimmingCharacters(in: .whitespaces), let password = passwordCell.textField.text?.trimmingCharacters(in: .whitespaces) else {
            return
        }
        guard name.count > 0 && password.count > 0 else {
            return
        }
        accountCell.textField.isEnabled = false
        passwordCell.textField.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        sender.startLoading()

        signin(name: name, password: password) {
            sender.stopLoading()
            self.accountCell.textField.isEnabled = true
            self.passwordCell.textField.isEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    @objc func signupClick(sender: UIBarButtonItem) {
        let vc = SignupViewController<AccountType>(account: account)
        vc.success = { name in
            self.accountCell.textField.text = name
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == accountCell.textField {
            passwordCell.textField.becomeFirstResponder()
        } else if textField == passwordCell.textField {
            if signinButton.isEnabled {
                signinClick(sender: signinButton)
                return false
            }
        }
        return true
    }
}
