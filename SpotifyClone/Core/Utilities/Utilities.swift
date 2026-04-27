//
//  Utilities.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2025/10/31.
//

import Foundation
import UIKit
import SwiftUI

class Utilities {
    static let shared = Utilities()
    private init() {}

    /// 在 DEBUG 模式下，印出 API Response
    func logMessage(target: String, code: Int? = nil, message: String, isSuccess: Bool) {
#if DEBUG
        print("========================================")
        
        var codeContent = ""
        if let code = code {
            codeContent = "Code: \(code)"
        }
        
        if isSuccess {
            print("[✅] \(target) \(codeContent): \(message)")
        } else {
            print("[❌] \(target) Error \(codeContent), Reason: \(message)")
        }
#endif
    }
    
    /// 取得最上層的 VC，記得包 Main Thread
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController,
           let selectedController = topViewController(controller: tabController.selectedViewController)
        {
            return topViewController(controller: selectedController)
        }
        if let presented = controller?.presentingViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    func getRequestPhoneNum(_ phone: String) -> String {
        return phone.count == 9 ? ("0" + phone) : phone
    }
    
    /**
     UIKit 顯示 Alert
     - Parameters:
     - title: 提示標題
     - msg: 提示內容
     - primaryButtonTitle: 右邊按鈕名稱
     - secondaryButtonTitle: (Optional) 左邊按鈕名稱
     - onPrimaryAction: 右邊按鈕點擊後動作
     - onSecondaryAction: (Optional) 左邊按鈕點擊後動作
     */
    func showAlert(title: String, msg: String,
                   primaryButtonTitle: String, secondaryButtonTitle: String? = nil,
                   onPrimaryAction: @escaping () -> Void,
                   onSecondaryAction: (() -> Void)? = nil)
    {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let primaryAction = UIAlertAction(title: primaryButtonTitle, style: .default) { _ in
            onPrimaryAction()
        }
        alertController.addAction(primaryAction)
        
        if let secondaryButtonTitle = secondaryButtonTitle
        {
            let secondaryAction = UIAlertAction(title: secondaryButtonTitle, style: .cancel)
            { _ in
                onSecondaryAction?()
            }
            alertController.addAction(secondaryAction)
        }
        
        if let topVC = Utilities.shared.topViewController() {
            DispatchQueue.main.async {
                topVC.present(alertController, animated: true)
            }
        }
    }
}
