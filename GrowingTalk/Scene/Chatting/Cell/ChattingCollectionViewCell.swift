//
//  ChattingCollectionViewCell.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/21/24.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift
import Then


final class ChattingCollectionViewCell: UICollectionViewCell {
    //MARK: - UI Properties
    private let profileImageView = UIImageView().then { view in
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
    }
    
    private let userNameLabel = UILabel().then {
        $0.font = .Custom.generalCaption
    }
    
    private let contentStackView = UIStackView().then { view in
        view.axis = .vertical
        view.alignment = .leading
        view.spacing = 5
        view.distribution = .equalSpacing
    }
    
    private let textView = UITextView().then { view in
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.BrandColor.brandGray.cgColor
        view.layer.borderWidth = 1
        view.isEditable = false
        view.isScrollEnabled = false
    }
    
    private let imageContentStack = UIStackView().then { view in
        view.axis = .vertical
        view.spacing = 2
        view.distribution = .fillEqually
        view.alignment = .fill
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
    }
    private let firstRowImageStack = UIStackView().then { view in
        view.axis = .horizontal
        view.spacing = 2
        view.distribution = .fillEqually
        view.alignment = .fill
    }
    
    private let secondRowImageStack = UIStackView().then { view in
        view.axis = .horizontal
        view.spacing = 2
        view.distribution = .fillEqually
        view.alignment = .fill
    }
    
    private let contentImage1 = UIImageView().then { view in
        view.layer.cornerRadius = 4
    }
    private let contentImage2 = UIImageView().then { view in
        view.layer.cornerRadius = 4
    }
    private let contentImage3 = UIImageView().then { view in
        view.layer.cornerRadius = 4
    }
    private let contentImage4 = UIImageView().then { view in
        view.layer.cornerRadius = 4
    }
    private let contentImage5 = UIImageView().then { view in
        view.layer.cornerRadius = 4
    }
    private let dateLabel = UILabel().then {
        $0.font = .Custom.generalCaption
        $0.textColor = .TextColor.textSecondaryColor
    }
    
    //MARK: - Properties
//    private let channelChatData: ChannelChatModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViewHierarchy()
        configureViewConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - LifeCycle
    override func prepareForReuse() {
        super.prepareForReuse()
        resetAllContents()
        configureViewConstraints()
    }
    
    
    //MARK: - Configure UI
    
    private func configureViewHierarchy() {
        self.contentView.addSubViews([profileImageView, userNameLabel, contentStackView, dateLabel])
        self.contentStackView.addArrangedSubview(textView)
        self.contentStackView.addArrangedSubview(imageContentStack)
        self.imageContentStack.addArrangedSubview(firstRowImageStack)
        self.imageContentStack.addArrangedSubview(secondRowImageStack)
        self.firstRowImageStack.addArrangedSubview(contentImage1)
        self.firstRowImageStack.addArrangedSubview(contentImage2)
        self.firstRowImageStack.addArrangedSubview(contentImage3)
        self.secondRowImageStack.addArrangedSubview(contentImage4)
        self.secondRowImageStack.addArrangedSubview(contentImage5)
    }
    
    private func configureViewConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.leading.equalTo(self.contentView).inset(8)
            make.size.equalTo(34)
        }
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
        }
        contentStackView.snp.makeConstraints { make in
            make.leading.equalTo(userNameLabel)
            make.top.equalTo(userNameLabel.snp.bottom).offset(5)
            make.width.lessThanOrEqualTo(self.contentView.safeAreaLayoutGuide).multipliedBy(0.5)
            make.bottom.equalToSuperview().inset(8)
        }
        imageContentStack.snp.makeConstraints { make in
            make.height.equalTo(160)
        }
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentStackView.snp.trailing).offset(8)
            make.bottom.equalTo(contentStackView)
        }
    }
    
    func setUpCell(channelChat: ChannelChatModel? = nil){
        if let channelChat {
            setUpChannelChat(channelChat: channelChat)
        }
    }
    
    private func setUpChannelChat(channelChat: ChannelChatModel) {
        //프로필 이미지 설정
        if let profileImagePath = channelChat.user.profileImage {
            let downSampling = DownsamplingImageProcessor(size: CGSize(width: 34, height: 34))

            profileImageView.kf.setImageWithHeader(with: URL(string: SecretKeys.severURL_V1+profileImagePath), options: [.processor(downSampling)])
        } else {
            profileImageView.image = UIImage(named: "DefaultProfile_A")
        }
        
        userNameLabel.text = channelChat.user.nickname
        
        //채팅 텍스트
        if channelChat.content != "" {
            textView.isHidden = false
            textView.text = channelChat.content
        } else {
            textView.isHidden = true
        }
        
        //이미지 설정
        showImages(imagePath: channelChat.files)
        
        dateLabel.text = channelChat.createdAt.stringToDate?.dateToString(targetString: "hh:mm a")
    }
    
    private func showImages(imagePath:[String]) {
        let contentImageArray = [contentImage1, contentImage2, contentImage3, contentImage4, contentImage5]
        
        let imageCount = imagePath.count
        
        for nextLoadingImageIndex in 0 ..< imageCount {
            let imageView = contentImageArray[nextLoadingImageIndex]
            imageView.isHidden = false
            imageView.kf.setImageWithHeader(with: URL(string: SecretKeys.severURL_V1+imagePath[nextLoadingImageIndex]))
        }
        
        for hiddenImageViewIndex in imageCount ..< 5 {
            let imageView = contentImageArray[hiddenImageViewIndex]
            imageView.isHidden = true
        }
        
        switch imageCount {
        case 0:
            imageContentStack.isHidden = true
        case 1:
            secondRowImageStack.isHidden = true
        case 2...3:
            secondRowImageStack.isHidden = true
            imageContentStack.snp.updateConstraints { make in
                make.height.equalTo(80)
            }
        default:
            secondRowImageStack.isHidden = false
        }
        
    }
    
    func resetAllContents() {
        [textView, imageContentStack, secondRowImageStack, contentImage1, contentImage2, contentImage3, contentImage4, contentImage5].forEach { view in
            view.isHidden = false
        }
        
        imageContentStack.snp.removeConstraints()
    }
    
    
}
