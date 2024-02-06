//
//  SideBarCell.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/6/24.
//

import UIKit
import Kingfisher

final class SideBarCell: UICollectionViewCell {
    private let workspaceImage = UIImageView().then { view in
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
    }
    
    private let workSpaceTitleLabel = UILabel().then { label in
        label.font = .Custom.bodyBold
        label.textAlignment = .left
    }
    
    private let workspaceInitDateLabel = UILabel().then { label in
        label.font = .Custom.generalBody
        label.textAlignment = .left
    }
    
    private let actionButton = UIButton().then { view in
        view.frame = CGRect(origin: .zero, size: CGSize(width: 20, height: 20))
        view.backgroundColor = .clear
        view.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        view.tintColor = .label
        view.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCellHierarchy()
        configureCellConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCellHierarchy() {
        self.contentView.addSubViews([workspaceImage, workSpaceTitleLabel, workspaceInitDateLabel, actionButton])
        self.contentView.layer.cornerRadius = 8
    }
    
    private func configureCellConstraints() {
        workspaceImage.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview().inset(8)
            make.width.equalTo(workspaceImage.snp.height)
        }
        actionButton.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(12)
        }
        workSpaceTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(workspaceImage.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(actionButton).offset(-18)
            make.top.equalTo(workspaceImage)
        }
        workspaceInitDateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(workspaceImage)
            make.horizontalEdges.equalTo(workSpaceTitleLabel)
        }
    }
    
    func configureCellItem(imageString: String, titleText: String, initialDateString: String, isSelectedCell: Bool = false) {
        let imageProcessor = DownsamplingImageProcessor(size: CGSize(width: 44, height: 44))
        workspaceImage.kf.setImageWithHeader(with: URL(string: SecretKeys.severURL_V1+imageString), options: [.processor(imageProcessor)])
        workSpaceTitleLabel.text = titleText
        workspaceInitDateLabel.text = initialDateString.stringToDate?.dateToString()
        if isSelectedCell {
            self.contentView.backgroundColor = .BrandColor.brandGray
            self.actionButton.isHidden = false
        }
    }
}
