//
//  LoginVIewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/11/24.
//

import UIKit
import RxCocoa
import RxSwift

final class LoginViewController: BaseViewController {
    //MARK: - UIProperties
    private let closeButton = {
        let item =  UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
        item.tintColor = .label
        return item
    }()
    private let idLabelField = LabelTextField(labelString: "이메일", textFieldPlaceHolder: "이메일을 입력하세요")
    
    private let passowrdLabelField = LabelTextField(labelString: "비밀번호", textFieldPlaceHolder: "비밀번호를 입력하세요")
    
    private let loginButton = InteractionButton(titleString: "로그인", isActive: false)
    
    //MARK: - Properties
    let viewModel = LoginViewModel()
    
    let disposeBag = DisposeBag()
    
    //MARK: - override
    
    //MARK: - VC Method
    override func configure() {
        super.configure()
    }
    
    override func configureNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        self.title = "이메일 로그인"
        self.navigationItem.leftBarButtonItem = closeButton
    }
    
    override func bind() {
        let input = LoginViewModel.Input(
            closeButtonTap: closeButton.rx.tap,
            idText: idLabelField.textField.rx.text.orEmpty,
            passwordText: passowrdLabelField.textField.rx.text.orEmpty,
            loginButtonTap: loginButton.rx.tap
        
        )
        
        let output = viewModel.transform(input)
        
        output.closebuttonTap
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
            
        output.wrongType
            .drive(with: self) { owner, result in
                switch result {
                case .success(_):
                    [owner.idLabelField, owner.passowrdLabelField].forEach { view in
                        view.chageLabelColor(color: .label)
                    }
                case .failure(let failType):
                    switch failType{
                    case .id:
                        owner.idLabelField.chageLabelColor(color: .systemRed)
                        owner.idLabelField.textField.becomeFirstResponder()
                    case .password:
                        owner.passowrdLabelField.chageLabelColor(color: .systemRed)
                        owner.passowrdLabelField.textField.becomeFirstResponder()
                    case .all:
                        [owner.idLabelField, owner.passowrdLabelField].forEach { view in
                            view.chageLabelColor(color: .systemRed)
                        }
                        owner.becomeFirstResponder()
                    }
                }
            }
            .disposed(by: disposeBag)
        
        output.LoginButtonActive
            .drive(with: self) { owner, active in
                owner.loginButton.changedButtonValid(newValue: active)
            }
            .disposed(by: disposeBag)
        
        output.userHaveWorkspace
            .filter({ $0 })
            .withLatestFrom(output.usersOwnWorkspace.asDriver(onErrorJustReturn: []))
            .drive(with: self) { owner, value in
                if let workspaceInfo = value.first {
                    let tabBarVC = HomeTabBarController()
                    tabBarVC.appendNavigationWrappingVC(viewControllers: [HomeInitialViewController(workspaceInfo: workspaceInfo)])
                    try? owner.changeFirstVC(nextVC: tabBarVC)
                }
                
            }
            .disposed(by: disposeBag)
        
        output.userHaveWorkspace
            .filter({ !$0 })
            .drive(with: self) { owner, value in
                if !value { try? owner.changeFirstVC(nextVC: UINavigationController(rootViewController: HomeEmptyViewController())) }
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - UI Method
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubViews([idLabelField, passowrdLabelField, loginButton])
    }
    
    override func configureViewConstraints() {
        idLabelField.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(self.view.safeAreaLayoutGuide).inset(24)
        }
        passowrdLabelField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(idLabelField)
            make.top.equalTo(idLabelField.snp.bottom).offset(24)
        }
        loginButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(self.view.keyboardLayoutGuide).inset(24)
            make.height.equalTo(44)
        }
    }
}
