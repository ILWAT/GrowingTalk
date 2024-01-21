//
//  Extension+UIViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/5/24.
//

import UIKit

extension UIViewController {
    func showNavVCSheetController<V: UIViewController>(nextVC: V.Type) {
        let nextVC = nextVC.init()
        let nav = UINavigationController(rootViewController: nextVC)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        self.present(nav, animated: true)
    }
}
