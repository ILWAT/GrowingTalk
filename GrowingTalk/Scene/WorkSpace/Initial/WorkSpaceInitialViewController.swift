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

final class WorkSpaceInitialViewController: BaseViewController {
    //MARK: - UIProperties
    private let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark")).then { item in
        item.tintColor = .label
    }
    
    private let mainTitle = UILabel().then { view in
        view.text = "출시 준비 완료!"
        view.font = .Custom.appTitle1
        view.textColor = .label
        view.textAlignment = .center
    }
    
    private let subTitle = UILabel().then { view in
        view.font = .Custom.generalBody
        view.text = "사용자님의 조직을 위해 새로운 성장톡 워크스페이스를 시작할 준비가 완료되었어요!"
        view.numberOfLines = 2
        view.textAlignment = .center
    }
    
    private let image = UIImageView().then { view in
        view.image = UIImage(named: "launchingImage")
    }
    
    private let button = InteractionButton(titleString: "워크스페이스 생성")
    
    //MARK: - Properties
    private let viewModel = WorkSpaceInitialViewModel()
    
    private var userNickname = "사용자"
    
    let disposeBag = DisposeBag()
    
    //MARK: - Override Method
    override func configure() {
        super.configure()
    }
    
    override func configureNavigation() {
        self.title = "시작하기"
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem = closeButton
        
        
    }
    
    override func bind() {
        let input = WorkSpaceInitialViewModel.Input(
            makingButtonTap: button.rx.tap,
            closeButtonTap: closeButton.rx.tap
        )
        
        let output = viewModel.transform(input)
        
        output.makingButtonTap
            .bind(with: self) { owner, _ in
                let addWorkSpace = WorkSpaceAddViewController()
                let navVC = UINavigationController(rootViewController: addWorkSpace)
                if let sheet = navVC.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.prefersGrabberVisible = true
                }
                owner.present(navVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.closeButtonTap
            .bind(with: self) { owner, _ in
                print("close")
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
            make.height.equalTo(44)
        }
    }
    
    func changeSubTitle(nickName: String){
        self.subTitle.text = "\(nickName)님의 조직을 위해 새로운 성장톡 워크스페이스를 시작할 준비가 완료되었어요!"
    }
}
