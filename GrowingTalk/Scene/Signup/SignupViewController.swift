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
    
    private let passwordLabelField = LabelTextField(labelString: "비밀번호", textFieldPlaceHolder: "비밀번호를 입력하세요", isSecure: true)
    
    private let checkPasswordLabelField = LabelTextField(labelString: "비밀번호 확인", textFieldPlaceHolder: "비밀번호를 입력하세요", isSecure: true)
    
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
    
    private let leftNavItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: SignupViewController.self, action: nil).then { item in
        item.tintColor = .black
    }
    
    //MARK: - RxProperties
    
    let disposeBag = DisposeBag()
    
    //MARK: - generalProperties
    
    let viewModel = SignupViewModel()
    
    deinit{
        print("SignupVC deinit")
    }
    
    //MARK: - configureVC
    override func configureNavigation() {
        self.title = "회원가입"
        self.navigationItem.leftBarButtonItem = leftNavItem
    }
    
    override func bind() {
        let input = SignupViewModel.Input(
            inputEmail: emailLabelField.textField.rx.text.orEmpty,
            inputNickname: nicknameLabelField.textField.rx.text.orEmpty,
            inputPhoneNumber: phoneNumberLabelField.textField.rx.text.orEmpty,
            inputPassword: passwordLabelField.textField.rx.text.orEmpty,
            inputCheckPassword: checkPasswordLabelField.textField.rx.text.orEmpty,
            signUpButtonTap: signUpButton.rx.tap,
            checkEmailButtonTap: emailValidButton.rx.tap
        )
        
        let output = viewModel.transform(input)
        
        leftNavItem.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.activeCheckBtn
            .drive(with: self) { owner, activeCheck in
                owner.emailValidButton.changedButtonValid(newValue: activeCheck)
            }
            .disposed(by: disposeBag)
        
        output.activeSignupBtn
            .drive(with: self) { owner, active in
                owner.signUpButton.changedButtonValid(newValue: active)
            }
            .disposed(by: disposeBag)
        
        output.checkEmailToast
            .drive(with: self) { owner, emailCheckingResult in
                owner.view.makeAppBottomToast(toastMessage: emailCheckingResult.rawValue, point: CGPoint(x: self.view.bounds.width / 2.0, y: self.view.bounds.minY + (self.buttonWrapperView.frame.minY - 16.0)))
            }
            .disposed(by: disposeBag)
        
        output.filteringPhoneNUmber
            .drive(with: self) { owner, phoneNumber in
                owner.phoneNumberLabelField.textField.rx.text.orEmpty.onNext(phoneNumber)
            }
            .disposed(by: disposeBag)
        
        output.requiredData
            .drive(with: self) { owner, requiredDatas in
                guard let firstResponder = requiredDatas.first else { return }
                owner.changeLabelColorToRed(type: firstResponder)
                
                owner.changeLabelColorOriginal()
                for requiredData in requiredDatas {
                    owner.changeLabelColorToRed(type: requiredData)
                }
            }
            .disposed(by: disposeBag)
        
        
        output.signupResult
            .drive(with: self) { owner, signupResult in
                
                
                guard let currentWindow = self.view.window else {
                    self.view.makeAppBottomToast(toastMessage: "알 수 없는 오류가 발생했습니다. 잠시후 시도해주세요", point: CGPoint(x: self.view.bounds.width / 2.0, y: self.view.bounds.minY + (self.buttonWrapperView.frame.minY - 16.0)))
                    return
                }
                
                let nextVC = WorkSpaceInitialViewController()
                let nextNav = UINavigationController(rootViewController: nextVC)
                currentWindow.rootViewController = nextNav
                
                UIView.transition(with: currentWindow, duration: 0.5,options: [.transitionCrossDissolve], animations: nil)
                
                nextVC.changeSubTitle(nickName: signupResult.nickname)
            }
            .disposed(by: disposeBag)
        
        
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
    
    //MARK: - Helper
    @objc
    func didTapCloseButton(){
        self.dismiss(animated: true)
    }
    
    func TextFieldBecoeFirst(type: SignupRequiredCase) {
        switch type {
        case .email:
            emailLabelField.textField.becomeFirstResponder()
        case .nickname:
            nicknameLabelField.textField.becomeFirstResponder()
        case .password:
            passwordLabelField.textField.becomeFirstResponder()
        case .checkPassword:
            checkPasswordLabelField.textField.becomeFirstResponder()
        }
    }
    
    func changeLabelColorToRed(type: SignupRequiredCase) {
        switch type{
        case .email:
            emailLabelField.chageLabelColor(color: .red)
        case .nickname:
            nicknameLabelField.chageLabelColor(color: .red)
        case .password:
            passwordLabelField.chageLabelColor(color: .red)
        case .checkPassword:
            checkPasswordLabelField.chageLabelColor(color: .red)
        }
    }
    
    func changeLabelColorOriginal() {
        [emailLabelField, nicknameLabelField, phoneNumberLabelField, passwordLabelField, checkPasswordLabelField].forEach { view in
            view.chageLabelColor(color: .label)
        }
    }
}
