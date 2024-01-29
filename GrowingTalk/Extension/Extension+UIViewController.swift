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
    
    ///파라미터로 받는 UIViewController를 현재 윈도우의 첫번째 뷰컨트롤러로 교체하고 화면 전환을 진행한다.
    func changeFirstVC(nextVC: UIViewController) throws {
        guard let window = self.view.window else { throw DeviceError.changeViewError }
        window.rootViewController = nextVC
        
        UIView.transition(with: window, duration: 0.5,options: [.transitionCrossDissolve], animations: nil)
    }
}
