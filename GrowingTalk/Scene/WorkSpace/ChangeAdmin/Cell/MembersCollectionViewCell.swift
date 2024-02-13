//
//  MembersCollectionViewCell.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/11/24.
//

import UIKit
import RxCocoa
import RxSwift
import Then

final class MembersCollectionViewCell: UICollectionViewCell {
    //MARK: - UI Properties
    private let profileImage = UIImageView().then { view in
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.image = UIImage(named: "DefaultProfile_A")
    }
    
    private let nicknameLabel = UILabel().then { label in
        label.font = .Custom.appTitle2
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .label
    }
    
    private let emailLabel = UILabel().then { label in
        label.font = .Custom.generalBody
        label.textColor = .TextColor.textSecondaryColor
        label.textAlignment = .left
        label.numberOfLines = 1
    }
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViewHierarchy()
        configureViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure UI
    private func configureViewHierarchy() {
        self.contentView.addSubViews([profileImage, nicknameLabel, emailLabel])
    }
    
    private func configureViewConstraints() {
        profileImage.snp.makeConstraints { make in
            make.size.equalTo(44)
            make.leading.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(8)
        }
        nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImage.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.top.equalTo(profileImage)
        }
        emailLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(nicknameLabel.snp.bottom)
            make.bottom.equalTo(profileImage)
            make.horizontalEdges.equalTo(nicknameLabel)
        }
    }
    
    func settingUI(userInfo: UserInfo) {
        if let userProfile = userInfo.profileImage {
            profileImage.kf.setImageWithHeader(with: URL(string: SecretKeys.severURL_V1+userProfile)!)
        }
        nicknameLabel.text = userInfo.nickname
        emailLabel.text = userInfo.email
    }
    
}
