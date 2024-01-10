//
//  WorkSpaceInitialViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/9/24.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Then

import SwiftUI

final class WorkSpaceInitialViewController: BaseViewController {
    //MARK: - UIProperties
//    private
    
    private let mainTitle = UILabel().then { view in
        view.text = "출시 준비 완료!"
        view.font = .Custom.appTitle1
        view.textColor = .label
        view.textAlignment = .center
    }
    
    private let subTitle = UILabel().then { view in
        view.font = .Custom.generalBody
        view.text = "사용자님의 조직을 위해 새로운 새싹톡 워크스페이스를 시작할 준비가 완료되었어요!"
        view.numberOfLines = 2
        view.textAlignment = .center
    }
    
    private let image = UIImageView().then { view in
        view.image = UIImage(named: "launchingImage")
    }
    
    private let button = InteractionButton(titleString: "워크스페이스 생성")
    
    //MARK: - Properties
    private let viewModel = WorkSpaceInitialViewModel()
    
    private var userData = PublishRelay<SignupResultModel>()
    
    let disposeBag = DisposeBag()
    
    //MARK: - Override Method
    override func configure() {
        super.configure()
    }
    
    override func configureNavigation() {
        self.title = "시작하기"
        self.navigationController?.navigationBar.backgroundColor = .white
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: nil)
        navigationItem.leftBarButtonItem = closeButton
        
        
    }
    
    override func bind() {
        let input = WorkSpaceInitialViewModel.Input(
            userData: userData,
            buttonTap: button.rx.tap
        )
        
        let output = viewModel.transform(input)
        
        output.subTitleText
            .debug("subTitle")
            .drive(with: self) { owner, subTitleText in
                self.subTitle.rx.text.onNext(subTitleText)
            }
            .disposed(by: disposeBag)
        
        output.buttonTap
            .subscribe(with: self) { owner, _ in
                owner.navigationController?.pushViewController(UIViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        
    }
    
    //MARK: - UIMethod
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubViews([mainTitle, subTitle, image, button])
    }
    
    override func configureViewConstraints() {
        image.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(image.snp.width)
            make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(12)
        }
        subTitle.snp.makeConstraints { make in
            make.centerX.equalTo(image)
            make.bottom.equalTo(image.snp.top).offset(-15)
            make.horizontalEdges.equalTo(image)
        }
        mainTitle.snp.makeConstraints { make in
            make.centerX.equalTo(image)
            make.bottom.equalTo(subTitle.snp.top).offset(-24)
            make.horizontalEdges.equalTo(image)
        }
        button.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
    }
    
    func emitUserData(data: SignupResultModel) {
        self.userData.accept(data)
    }
}

#Preview{
    UINavigationController(rootViewController: WorkSpaceInitialViewController())
}
