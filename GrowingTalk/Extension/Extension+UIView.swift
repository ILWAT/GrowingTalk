//
//  Extension+UIView.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/3/24.
//

import UIKit

extension UIView {
    func addSubViews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
}
