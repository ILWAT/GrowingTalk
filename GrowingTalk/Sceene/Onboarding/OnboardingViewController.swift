//
//  OnboardingViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/3/24.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class OnboardingViewController: BaseViewController {
    //MARK: - UIProperties
    private let titleLabel = UILabel().then { label in
        label.text = "새싹톡을 사용하면 어디서나\n팀을 모을 수 있습니다"
        label.numberOfLines = 2
        label.textColor = .TextColor.textPrimaryColor
        label.font = .Custom.appTitle1
        label.textAlignment = .center
    }
    private let onboardingImageView = UIImageView().then { view  in
        view.image = UIImage(named: "OnboardingImage")
        view.contentMode = .scaleAspectFit
    }
    
    private let startButton = InteractionButton(titleString: "시작하기")
    
    
    //MARK: - RxProperties
    
    
    //MARK: - configureUI
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubViews([onboardingImageView, titleLabel, startButton])
    }
    
    override func configureViewConstraints() {
        self.onboardingImageView.snp.makeConstraints { make in
            make.center.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(onboardingImageView.snp.width)
            make.width.equalTo(self.view.safeAreaLayoutGuide).multipliedBy(0.85)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(onboardingImageView).inset(-12)
            make.bottom.equalTo(onboardingImageView.snp.top).offset(-89)
        }
        self.startButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(44)
        }
    }
    
}
