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
    
    private let orLabel = UILabel().then { label in
        label.text = "또는"
        label.font = .Custom.appTitle2
        label.textColor = .black
    }
    
    private let signUpButton = UIButton().then { btn in
        btn.setTitle("새롭게 회원가입하기", for: .normal)
        btn.setTitleColor(.BrandColor.brandGreen, for: .normal)
    }
    
    private lazy var signUpStackView = UIStackView(arrangedSubviews: [self.orLabel, self.signUpButton]).then { view in
        view.axis = .horizontal
        view.spacing = 0
        view.alignment = .fill
        view.distribution = .equalSpacing
    }
    
    private lazy var authStackView = UIStackView(arrangedSubviews: [appleLoginButton, kakaoLoginButton, emailLoginButton, signUpStackView]).then { view in
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
                print("signUpButton")
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
            make.verticalEdges.equalToSuperview().inset(27)
            make.horizontalEdges.equalToSuperview().inset(35)
        }
        emailLoginButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
}
