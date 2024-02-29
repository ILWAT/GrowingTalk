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
    
    
    //MARK: - Properties
    private let workspaceID: Int
    
    private let viewModel = InviteMemberViewModel()
    
    private let disposeBag = DisposeBag()
    
    
    //MARK: - Initialization
    init(workspaceID: Int) {
        self.workspaceID = workspaceID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure VC
    override func configure() {
        super.configure()
    }
    
    override func configureNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        
        self.navigationItem.title = "팀원 초대"
        self.navigationItem.setLeftBarButton(closeButton, animated: true)
        
        self.navigationItem.scrollEdgeAppearance = appearance
    }
    
    override func bind() {
        let input = InviteMemberViewModel.Input(
            workspaceID: workspaceID,
            closeButtonTap: closeButton.rx.tap,
            inputEmailText: inputEmailBox.textField.rx.text.orEmpty,
            inviteButtonTap: inviteButton.rx.tap
        )
        
        let output = viewModel.transform(input)
        
        output.closeButtonTap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.buttonEnable
            .drive(with: self) { owner, value in
                owner.inviteButton.changedButtonValid(newValue: value)
            }
            .disposed(by: disposeBag)
        
        output.inviteMemberRequestSuccess
            .drive(with: self) { owner, isSuccess in
                self.view.makeAppToast(toastMessage: "멤버를 성공적으로 초대했습니다.")
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.toastMessage
            .drive(with: self) { owner, message in
                owner.view.makeAppBottomToast(toastMessage: message, point: CGPoint(x: Double(owner.view.safeAreaLayoutGuide.layoutFrame.midX), y: Double(owner.inviteButton.frame.minY - 24)))
            }
            .disposed(by: disposeBag)
        
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
