//
//  BaseView.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/3/24.
//

import UIKit

class BaseView: UIView {
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor =  backgroundColor
        configureHierarchy()
        configureConstraints()
    }
    
    init(frame: CGRect, color backgroundColor: UIColor) {
        super.init(frame: frame)
        self.backgroundColor =  backgroundColor
        configureHierarchy()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("cannot init using coder")
    }
    
    //MARK: - Function
    func configureHierarchy() { }
    func configureConstraints() { }
}
