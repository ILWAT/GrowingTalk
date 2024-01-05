//
//  SignupViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/4/24.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class SignupViewController: BaseViewController {
    //MARK: - UIProperties
    private let emailLabelField = LabelTextField(labelString: "이메일", textFieldPlaceHolder: "이메일을 입력하세요")
    
    private let emailValidButton = InteractionButton(titleString: "중복 확인", isActive: false)
    
    private let nicknameLabelField = LabelTextField(labelString: "닉네임", textFieldPlaceHolder: "닉네임을 입력하세요")
    
    private let phoneNumberLabelField = LabelTextField(labelString: "연락처", textFieldPlaceHolder: "전화번호를 입력하세요")
    
    private let passwordLabelField = LabelTextField(labelString: "비밀번호", textFieldPlaceHolder: "비밀번호를 입력하세요")
    
    private let checkPasswordLabelField = LabelTextField(labelString: "비밀번호 확인", textFieldPlaceHolder: "비밀번호를 입력하세요")
    
    private lazy var emailStackView = UIStackView().then { view in
        view.addArrangedSubview(emailLabelField)
        view.addArrangedSubview(emailValidButton)
        
        view.axis = .horizontal
        view.spacing = 12
        view.alignment = .bottom
        view.distribution = .fill
        
        emailLabelField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        emailValidButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private let signUpButton = InteractionButton(titleString: "가입하기", isActive: false)
    
    private let buttonWrapperView = UIView().then { view in
        view.backgroundColor = .BackgroundColor.backgroundPrimaryColor
    }
    
    private let leftNavItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: nil)
    
    //MARK: - RxProperties
    
    let disposeBag = DisposeBag()
    
    //MARK: - generalProperties
    
    let viewModel = SignupViewModel()
    
    //MARK: - configureVC
    override func configureNavigation() {
        self.title = "회원가입"
        self.navigationItem.leftBarButtonItem = leftNavItem
        self.navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    override func bind() {
        let input = SignupViewModel.Input(
            inputEmail: emailLabelField.textField.rx.text.orEmpty,
            inputNickname: nicknameLabelField.textField.rx.text.orEmpty,
            inputPhoneNumber: phoneNumberLabelField.textField.rx.text.orEmpty,
            inputPassword: passwordLabelField.textField.rx.text.orEmpty,
            inputCheckPassword: checkPasswordLabelField.textField.rx.text.orEmpty,
            signUpButtonTap: signUpButton.rx.tap
        )
        
        let output = viewModel.transform(input)
        
        output.activeCheckBtn
            .drive(with: self) { owner, activeCheck in
                owner.emailValidButton.changedButtonValid(newValue: activeCheck)
            }
            .disposed(by: disposeBag)
    }
    
    deinit{
        print(#function, "deinit")
    }
    
    //MARK: - configureUI
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        buttonWrapperView.addSubview(signUpButton)
        self.view.addSubViews([emailStackView, nicknameLabelField, phoneNumberLabelField, passwordLabelField, checkPasswordLabelField,buttonWrapperView])
    }
    
    override func configureViewConstraints() {
        let componentInset = 24
        emailStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(componentInset)
        }
        nicknameLabelField.snp.makeConstraints { make in
            make.top.equalTo(emailStackView.snp.bottom).offset(componentInset)
            make.horizontalEdges.equalTo(emailStackView)
        }
        phoneNumberLabelField.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabelField.snp.bottom).offset(componentInset)
            make.horizontalEdges.equalTo(emailStackView)
        }
        passwordLabelField.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberLabelField.snp.bottom).offset(componentInset)
            make.horizontalEdges.equalTo(emailStackView)
        }
        checkPasswordLabelField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabelField.snp.bottom).offset(componentInset)
            make.horizontalEdges.equalTo(emailStackView)
        }
        emailValidButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(emailLabelField.textField)
        }
        buttonWrapperView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(68)
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        }
        signUpButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.verticalEdges.equalToSuperview().inset(12)
        }
    }
    
    @objc
    func didTapCloseButton(){
        self.dismiss(animated: true)
    }
}
