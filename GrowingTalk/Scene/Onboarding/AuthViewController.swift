//
//  AuthViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/3/24.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

final class AuthViewController: BaseViewController {
    //MARK: - UIProperties
    private let appleLoginButton = ImageWrapButton(imageString: "AppleLoginImage")
    
    private let kakaoLoginButton = ImageWrapButton(imageString: "KakaoLoginImage")
    
    private let emailLoginButton = InteractionButton(titleString: "이메일로 시작하기", imageString: "EmailIcon")
    
    private let signUpButton = UIButton().then { btn in
        let titleString = "또는 새롭게 회원가입 하기"
        let attributedString = NSMutableAttributedString(string: titleString)
        let range = (titleString as NSString).range(of: "새롭게 회원가입 하기")
        attributedString.addAttribute(.foregroundColor, value: UIColor.BrandColor.brandGreen, range: range)
        
        btn.setAttributedTitle(attributedString, for: .normal)
        btn.titleLabel?.font = .Custom.appTitle2
        btn.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private lazy var authStackView = UIStackView(arrangedSubviews: [appleLoginButton, kakaoLoginButton, emailLoginButton, signUpButton]).then { view in
        view.axis = .vertical
        view.spacing = 16
        view.alignment = .fill
        view.distribution = .equalSpacing
    }
    
    //MARK: - RxProperties
    private let disposeBag = DisposeBag()
    //MARK: - ConfigureVC
    override func bind() {
        appleLoginButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                print("apple")
            }
            .disposed(by: disposeBag)
        
        kakaoLoginButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                print("kakao")
            }
            .disposed(by: disposeBag)
        
        signUpButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                let nextVC = SignupViewController()
                let nav = UINavigationController(rootViewController: nextVC)
                self.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
        
        
    }
    
    //MARK: - ConfigureUI
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubview(authStackView)
    }
    
    override func configureViewConstraints() {
        authStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        emailLoginButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
}
