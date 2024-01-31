//
//  SideBarController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/30/24.
//

import UIKit
import SnapKit
import Then

final class SideBarController: BaseViewController {
    //MARK: - UIProperties
    private let titleLabel = UILabel().then { label in
        label.text = "워크스페이스"
        label.font = .Custom.appTitle1
    }
    private lazy var sideBarView = UIView().then { view in
        view.backgroundColor = .BackgroundColor.backgroundPrimaryColor
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        view.addSubViews([titleLabel, collectionView])
    }
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createUICollectionViewLayout())
    
    //MARK: - Properties
    
    //MARK: - Override
    override func configure() {
        super.configure()
    }
    
    override func configureViewHierarchy() {
        self.view.backgroundColor = .black.withAlphaComponent(0.5)
        self.view.addSubview(sideBarView)
    }
    
    override func configureViewConstraints() {
        sideBarView.snp.makeConstraints { make in
            make.width.equalTo(self.view.safeAreaLayoutGuide).multipliedBy(0.8)
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(-sideBarView.frame.width)
            make.top.bottom.equalTo(self.view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sideBarAnimation()
    }
    
    //MARK: - Helper
    func createUICollectionViewLayout() -> UICollectionViewLayout {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.backgroundColor = .white
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        return layout
    }
    
    func sideBarAnimation() {
        print(#function)
        print(sideBarView.frame.origin.x, sideBarView.frame)
        sideBarView.snp.updateConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide)
        }
//        UIView.animate(withDuration: 0.5, delay: 0) {
//            self.sideBarView.snp.updateConstraints { make in
//                make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(self.sideBarView.frame.width)
//            }
//            
//        }
    }
    
}
