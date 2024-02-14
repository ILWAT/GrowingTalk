//
//  InviteMemberViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/14/24.
//

import UIKit
import RxCocoa
import RxSwift
import Then

final class InviteMemberViewController: BaseViewController {
    //MARK: - UI Properties
    private let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil).then { item in
        item.tintColor = .black
    }
    
    private let inputEmailBox = LabelTextField(labelString: "이메일", textFieldPlaceHolder: "초대하려는 팀원의 이메일을 입력하세요.")
    
    private let inviteButton = InteractionButton(titleString: "초대 보내기", isActive: false)
    
    //MARK: - Configure VC
    override func configure() {
        super.configure()
    }
    
    override func configureNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        
        self.navigationItem.title = "팀원 초대"
        self.navigationItem.setLeftBarButton(closeButton, animated: true)
        
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    //MARK: - Configure View
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubViews([inputEmailBox, inviteButton])
    }
    
    override func configureViewConstraints() {
        inputEmailBox.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(24)
        }
        inviteButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-12)
        }
    }
}
