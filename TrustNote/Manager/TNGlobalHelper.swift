//
//  TNGlobalHelper.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/22.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

enum TNWalletRecoverStyle {
    case all
    case observed
    case syncCloned
    case none
}

final class TNGlobalHelper {
    
    var updateDict: [String: Any] = [:]
    var isVerifyPasswdForMain = true
    var recoverStyle: TNWalletRecoverStyle = .none
    var appVersion = ""
    var password: String? = nil
    var encryptePrivKey = ""
    var tempPrivKey = ""
    var xPubkey: String = ""             // root publickey
    var tempDeviceKey: String = ""       // temp privateKey
    var tempPublicKey:String  = ""       // temp publicKey
    var prevTempDeviceKey: String = ""   // previous temp privatekey
    var mnemonic: String = ""          //
    var ecdsaPubkey: String = ""
    var ecdsaPrivkey: String = ""
    var my_device_address: String = ""
    
    var currentWallet: TNWalletModel = TNWalletModel()
    
    var witnesses: [String] = []
    
    let  unitDecimals: Int = 4
    class var shared: TNGlobalHelper {
        
        struct Static {
            static let instance: TNGlobalHelper = TNGlobalHelper()
        }
        return Static.instance
    }
    
    public func createGlobalParameters() {
        
        getAppVersion()
        
        guard TNConfigFileManager.sharedInstance.isExistProfileFile() else {
            return
        }
        let profile = TNConfigFileManager.sharedInstance.readProfileFile() as! [String: Any]
        if profile.keys.contains("mnemonic") {
            mnemonic = profile["mnemonic"] as! String
            let hubViewModel = TNHubViewModel()
            TNWebSocketManager.sharedInstance.webSocketOpen(hubAddress: hubViewModel.hubAddress) 
        }
        if profile.keys.contains("xPrivKey") {
            encryptePrivKey = profile["xPrivKey"] as! String
        }
        if profile.keys.contains("tempDeviceKey") {
            tempDeviceKey = profile["tempDeviceKey"] as! String
        }
        if profile.keys.contains("prevTempDeviceKey") {
            prevTempDeviceKey = profile["prevTempDeviceKey"] as! String
        }
        if profile.keys.contains("my_device_address") {
            my_device_address = profile["my_device_address"] as! String
        }
        TNSQLiteManager.sharedManager.queryDataFromWitnesses(sql: "SELECT * FROM my_witnesses") { (results) in
            self.witnesses = results as! [String]
        }
        
        let config: NSDictionary = TNConfigFileManager.sharedInstance.readConfigFile()
        let rootWindow = config["keywindowRoot"] as! Int
        guard rootWindow == 4 else {return}
        let sql = "SELECT Count(*) FROM wallets WHERE is_local = 1"
        TNSQLiteManager.sharedManager.queryCount(sql: sql) { (count) in
            if count == 0 {
                self.createNewWallet()
            }
        }
    }
    
    func getAppVersion() {
        let infoDictionary = Bundle.main.infoDictionary
        appVersion = infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    func createNewWallet() {
        
        let walletViewModel = TNWalletViewModel()
        walletViewModel.generateNewWalletByDatabaseNumber(isLocal: true) {
            walletViewModel.saveNewWalletToProfile(TNGlobalHelper.shared.currentWallet)
            walletViewModel.saveWalletDataToDatabase(TNGlobalHelper.shared.currentWallet)
            if !TNGlobalHelper.shared.currentWallet.xPubKey.isEmpty {
                walletViewModel.generateWalletAddress(wallet_xPubKey: TNGlobalHelper.shared.currentWallet.xPubKey, change: false, num: 0, comletionHandle: { (walletAddressModel) in
                   walletViewModel.insertWalletAddressToDatabase(walletAddressModel: walletAddressModel)
                    TNHubViewModel.getMyTransactionHistory(addresses: [walletAddressModel.walletAddress])
                })
            }
        }
    }
    
    func getPrivkey() -> String {
        if let psw_key = password {
            guard !encryptePrivKey.isEmpty else {
                return tempPrivKey
            }
            let decryptPrivKey: String = AES128CBC_Unit.aes128Decrypt(encryptePrivKey, key: psw_key)
            if decryptPrivKey.contains("\0") {
                let result = decryptPrivKey.replacingOccurrences(of: "\0", with: "")
                return result
            }
        }
        return tempPrivKey
    }
}

