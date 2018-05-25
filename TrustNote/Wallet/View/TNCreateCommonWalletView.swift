//
//  TNCreateCommonWalletView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/18.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TNCreateCommonWalletView: UIView {
    
    let maxInputCount = 10
    let disposeBag = DisposeBag()
    let walletViewModel = TNWalletViewModel()
    
    typealias CreateCommonWalletCompleted = () -> Void
    
    var ceateCommonWalletCompleted: CreateCommonWalletCompleted?
    
    fileprivate var isDisplayWarning: BehaviorRelay<Bool> =  BehaviorRelay(value: false)
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputTextField.delegate = self
        clearButton.setTitle(NSLocalizedString("Create Wallet", comment: ""), for: .normal)
        warningLabel.text = NSLocalizedString("No more than 20 characters", comment: "")
        createButton.layer.cornerRadius = kCornerRadius
        createButton.layer.masksToBounds = true
        let inputObserver = inputTextField.rx.text.orEmpty.asDriver().debounce(0.1).map {$0.count > 0}
        inputObserver.drive(createButton.validState).disposed(by: disposeBag)
        inputObserver.drive(clearButton.rx_HiddenState).disposed(by: disposeBag)
        isDisplayWarning.asDriver().drive(lineView.rx_HighlightState).disposed(by: disposeBag)
    }
}

extension TNCreateCommonWalletView {
    
    @IBAction func createNewWallet(_ sender: Any) {
        
        guard (inputTextField.text?.count)! < maxInputCount + 1 else {
            warningView.isHidden = false
            isDisplayWarning.accept(true)
            return
        }
        createNewWallet()
        inputTextField.text = nil
        createButton.isEnabled = false
        createButton.alpha = 0.3
    }
    @IBAction func clearInputText(_ sender: Any) {
        inputTextField.text = nil
        createButton.isEnabled = false
        createButton.alpha = 0.3
        warningView.isHidden = true
        clearButton.isHidden = true
    }
    
    func createNewWallet() {
        
        TNGlobalHelper.shared.currentWallet.walletName = inputTextField.text!
        walletViewModel.generateNewWalletByDatabaseNumber(isLocal: true) {[unowned self] in
            self.walletViewModel.saveNewWalletToProfile(TNGlobalHelper.shared.currentWallet)
            self.walletViewModel.saveWalletDataToDatabase(TNGlobalHelper.shared.currentWallet)
            NotificationCenter.default.post(name: Notification.Name(rawValue: TNCreateCommonWalletNotification), object: nil)
            if !TNGlobalHelper.shared.currentWallet.xPubKey.isEmpty {
                self.walletViewModel.generateWalletAddress(wallet_xPubKey: TNGlobalHelper.shared.currentWallet.xPubKey, change: false, num: 0, comletionHandle: { (walletAddressModel) in
                    self.walletViewModel.insertWalletAddressToDatabase(walletAddressModel: walletAddressModel)
                    self.ceateCommonWalletCompleted?()
                })
            }
        }
    }
}

extension TNCreateCommonWalletView: TNNibLoadable {
    
    class func createCommonWalletView() -> TNCreateCommonWalletView {
        
        return TNCreateCommonWalletView.loadViewFromNib()
    }
}

extension TNCreateCommonWalletView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !warningView.isHidden {
            warningView.isHidden = true
            isDisplayWarning.accept(false)
        }
    }
}

extension UIButton {
    var validState: AnyObserver<Bool> {
        return Binder(self) { button, valid in
            button.isEnabled = valid
            button.alpha = valid ? 1.0 : 0.3
            }.asObserver()
    }
}
