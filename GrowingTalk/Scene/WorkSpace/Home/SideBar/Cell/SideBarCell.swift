//
//  SideBarCell.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/6/24.
//

import UIKit
import Kingfisher
import RxSwift

final class SideBarCell: UICollectionViewCell {
    //MARK: - UI Properties
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
    
    let actionButton = UIButton().then { view in
        view.frame = CGRect(origin: .zero, size: CGSize(width: 20, height: 20))
        view.backgroundColor = .clear
        view.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        view.tintColor = .label
        view.isHidden = true
    }
    
    var cellOwnData: WorkSpaceModel?
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellOwnData = nil
        disposeBag = DisposeBag()
    }
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCellHierarchy()
        configureCellConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Cell Hierarchy & Constraints
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
    
    //MARK: - Helper
    
    func configureCellItem(cellData: WorkSpaceModel, isSelectedCell: Bool = false) {
        self.cellOwnData = cellData
        guard let cellOwnData else {return}
        
        let imageProcessor = DownsamplingImageProcessor(size: CGSize(width: 44, height: 44))
        workspaceImage.kf.setImageWithHeader(with: URL(string: SecretKeys.severURL_V1+cellOwnData.thumbnail), options: [.processor(imageProcessor)])
        workSpaceTitleLabel.text = cellOwnData.name
        workspaceInitDateLabel.text = cellOwnData.createdAt.stringToDate?.dateToString()
        
        if isSelectedCell {
            self.contentView.backgroundColor = .BrandColor.brandGray
            self.actionButton.isHidden = false
        }
    }
    
    func makingObservableSequence() -> Observable<WorkSpaceModel?> {
        return actionButton.rx.tap.withUnretained(self).map({ $0.0.cellOwnData })
    }
}
