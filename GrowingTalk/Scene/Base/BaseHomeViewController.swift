//
//  BaseHomeViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/18/24.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher
import Then
import SnapKit

class BaseHomeViewController: BaseViewController{
    //MARK: - UI Properties
    let navTitleLabel = UILabel().then { view in
        view.frame = CGRect(x: .zero, y: .zero, width: 400, height: 30)
        view.font = .Custom.appTitle1
        view.textAlignment = .left
        view.autoresizingMask = .flexibleWidth
    }
    
    
    let profileImageButton = UIImageView().then { view in
        view.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        view.layer.cornerRadius = 15
        view.layer.borderColor = UIColor.label.cgColor
        view.layer.borderWidth = 2
        view.clipsToBounds = true
        view.image = UIImage(systemName: "person")
        view.tintColor = .black
        view.contentMode = .scaleAspectFit
        
    }
    
    let workSpaceImageButton = UIButton().then { view in
        view.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        let defaultImage = UIImage(named: "WorkSpace")?.resizingByRenderer(size: CGSize(width: 30, height: 30), tintColor: .BackgroundColor.backgroundPrimaryColor)
        view.setBackgroundImage(defaultImage, for: .normal)
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
    }
    
    lazy var profileImageBarButton = UIBarButtonItem(customView: profileImageButton)
    lazy var workSpaceImageBarButton =  UIBarButtonItem(customView: workSpaceImageButton)
    
    
    //MARK: - Properties
    
    var workspaceInfo: GetUserWorkSpaceResultModel?
    
    var userId: Int?
    
    let disposeBag = DisposeBag()
    
    
    //MARK: - VC Method
    override func configure() {
        super.configure()
    }
    
    override func configureNavigation() {
        super.configureNavigation()
    }
    
    //MARK: - UI Method
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
    }
    
    override func bind() {
        self.workSpaceImageButton.rx.tap
            .bind(with: self) { owner, _ in
                let nextVC = SideBarController(userId: owner.userId,currentWorkspaceId: owner.workspaceInfo?.workspace_id)
                nextVC.modalPresentationStyle = .overFullScreen
                nextVC.modalTransitionStyle = .crossDissolve
                owner.present(nextVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Helper
    
    func makeHomeNavigationBar(title: String?, workSpaceImageURL: String? = nil) {
        navTitleLabel.text = title
        
        navigationItem.titleView = navTitleLabel
        
        if let profileImageURL = UserDefaults.standard.string(forKey: UserDefaultsCase.userProfileImageURL.rawValue){
            KingfisherManager.shared.getImagesWithDownsampling(pathURL: profileImageURL) {[weak self] result in
                switch result {
                case .success(let image):
                    self?.profileImageButton.image = image.image
                case .failure(let error):
                    print(error)
                }
            }
        }
    
        
        if let workSpaceImageURL {
            KingfisherManager.shared.getImagesWithDownsampling(pathURL: workSpaceImageURL) {[weak self] result in
                switch result {
                case .success(let image):
                    self?.workSpaceImageButton.setBackgroundImage(image.image, for: .normal)
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.setRightBarButton(profileImageBarButton, animated: true)
        navigationItem.setLeftBarButton(workSpaceImageBarButton, animated: true)
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    
    }
}
