//
//  HomeViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/17/24.
//

import UIKit
import RxCocoa
import RxSwift
import Then

import SwiftUI

final class HomeEmptyViewController: BaseHomeViewController {
    //MARK: - UI Properties
    private let titleLabel = UILabel().then { label in
        label.font = .Custom.appTitle1
        label.text = "워크 스페이스를 찾을 수 없어요."
        label.textAlignment = .center
    }
    
    private let subTitleLabel = UILabel().then { label in
        label.font = .Custom.generalBody
        label.text = "관리자에게 초대를 요청하거나, 다른 이메일로 시도하거나 새로운 워크스페이스를 생성해주세요."
        label.textAlignment = .center
        label.numberOfLines = 2
    }
    
    private let imageView = UIImageView(image: UIImage(named: "EmptyWorkSpace"))
    
    private let addSpaceButton = InteractionButton(titleString: "워크스페이스 생성")
    
    
    
    //MARK: - Properties
    private let viewModel = HomeEmptyViewModel()
    
    private let disposeBag = DisposeBag()
    
    //MARK: - VC Method
    override func configure() {
        super.configure()
    }
    
    override func configureNavigation() {
        makeHomeNavigationBar(title: "No WorkSpace")
    }
    
    override func bind() {
        let input = HomeEmptyViewModel.Input(
            addWorkSpaceButtonTap: addSpaceButton.rx.tap
        )
        
        let output = viewModel.transform(input)
        
        output.addWorkSpaceButtonTap
            .bind(with: self) { owner, _ in
                owner.showNavVCSheetController(nextVC: WorkSpaceAddViewController.self)
            }
            .disposed(by: disposeBag)
    }
    //MARK: - UI Method
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubViews([titleLabel, subTitleLabel, imageView, addSpaceButton])
    }
    
    override func configureViewConstraints() {
        imageView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(12)
            make.height.equalTo(imageView.snp.width)
            make.center.equalTo(self.view.safeAreaLayoutGuide)
        }
        subTitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(imageView.snp.top).offset(-15)
        }
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(subTitleLabel.snp.top).offset(-24)
            make.horizontalEdges.equalTo(subTitleLabel)
        }
        addSpaceButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(44)
        }
        

        
    }
    //MARK: - Helper
}

#Preview{
    UINavigationController(rootViewController: HomeEmptyViewController())
}
