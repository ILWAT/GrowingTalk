//
//  BaseHomeViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/18/24.
//

import UIKit
import Kingfisher
import Then

class BaseHomeViewController: BaseViewController{
    //MARK: - UI Properties
    let navTitleLabel = UILabel().then { view in
        view.font = .Custom.appTitle1
        view.textAlignment = .left
        view.autoresizingMask = .flexibleWidth
        view.frame = CGRect(x: .zero, y: .zero, width: 400, height: 30)
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
    
    let workSpaceImageView = UIImageView().then { view in
        view.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.image = UIImage(named: "WorkSpace")
        view.tintColor = .black
        view.contentMode = .scaleAspectFit
    }
    
    lazy var profileImageBarButton = UIBarButtonItem(customView: profileImageButton)
    lazy var workSpaceImageBarButton = UIBarButtonItem(customView: workSpaceImageView)
    
    
    
    //MARK: - Properties
    
    //MARK: - VC Method
    override func configure() {
        super.configure()
    }
    
    override func configureNavigation() {
        
    }
    
    //MARK: - UI Method
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
    }
    
    //MARK: - Helper
    
    func makeHomeNavigationBar(title: String?, workSpaceImageURL: String? = nil) {
        self.navTitleLabel.text = title
        
        self.navigationItem.titleView = navTitleLabel
        
        let downSamplingProcessor = DownsamplingImageProcessor(size: CGSize(width: 30, height: 30))
        
        let kingfisherOptions: KingfisherOptionsInfo = [.processor(downSamplingProcessor), .cacheOriginalImage]
        
        if let profileImageURL = UserDefaults.standard.string(forKey: UserDefaultsCase.userProfileImageURL.rawValue){
            let url = URL(string: SecretKeys.severURL+profileImageURL)
            
            profileImageButton.kf.setImage(with: url, options: kingfisherOptions)
        }
        
        if let workSpaceImageURL {
            let url = URL(string: SecretKeys.severURL+workSpaceImageURL)
            
            workSpaceImageView.kf.setImageWithHeader(with: url, options: kingfisherOptions)
        }
        
        self.navigationItem.setRightBarButton(profileImageBarButton, animated: true)
        self.navigationItem.setLeftBarButton(workSpaceImageBarButton, animated: true)
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
    
    }
}
