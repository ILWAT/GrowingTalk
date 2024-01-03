//
//  BaseViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/3/24.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureNavigation()
    }
    
    
    //MARK: - configureVC
    /// VC에서 뷰 작성시 super configure 호출 할것. 개인 View 생성시 super configure 호출하지 말것.
    func configure() {
        configureViewHierarchy()
        configureViewConstraints()
    }
    func configureNavigation() { }
    
    //MARK: - ConfigureView
    func configureViewHierarchy() { }
    func configureViewConstraints() { }
}
