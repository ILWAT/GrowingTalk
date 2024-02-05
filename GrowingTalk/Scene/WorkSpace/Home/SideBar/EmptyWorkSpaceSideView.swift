//
//  EmptyWorkSpaceSideView.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/3/24.
//

import UIKit

final class EmptyWorkSpaceSideView: BaseView {
    private let titleLabel = UILabel().then { label in
        label.text = "워크스페이스를\n찾을 수 없어요."
        label.font = .Custom.appTitle1
        label.textAlignment = .center
        label.numberOfLines = 2
    }
    
    private let subTitleLabel = UILabel().then { label in
        label.text = "관리자에게 초대를 요청하거나,\n다른 이메일로 시도하거나\n새로운 워크스페이스를 생성해주세요."
        label.font = .Custom.generalBody
        label.textAlignment = .center
        label.numberOfLines = 3
    }
    
    private let addWorkspaceButton = InteractionButton(titleString: "워크스페이스 생성")
    
    override func configureHierarchy() {
        self.addSubViews([titleLabel, subTitleLabel, addWorkspaceButton])
    }
    
    override func configureConstraints() {
        let interSpace = 19
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(interSpace)
            make.horizontalEdges.equalTo(titleLabel)
        }
        addWorkspaceButton.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(interSpace)
            make.horizontalEdges.equalTo(titleLabel)
            make.bottom.equalToSuperview()
        }
    }
    
}
