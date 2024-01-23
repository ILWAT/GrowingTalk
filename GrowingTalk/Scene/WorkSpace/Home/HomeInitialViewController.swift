//
//  HomeInitialViewcontroller.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/22/24.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Then

import SwiftUI

private enum SectionType: Int, CaseIterable {
    case channel, directMessage
    
    var ownTitle: String{
        switch self {
        case .channel:
            return "채널"
        case .directMessage:
            return "다이렉트 메세지"
        }
    }
}

private struct HomeItemModel: Hashable {
    let title: String
    let notification: Int
    let itemType: ItemType
    let image: UIImage?
    
    enum ItemType {
        case header, cell
    }
}



final class HomeInitialViewController: BaseHomeViewController {
    //MARK: - UI Properties
    private lazy var modernCollectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then { view in
        view.backgroundColor = .BackgroundColor.backgroundPrimaryColor
    }
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<SectionType, HomeItemModel>!
    
    //MARK: - Properties
    private let viewModel = HomeInitialViewModel()
    
    private let disposeBag = DisposeBag()
    
    //MARK: - VC Method
    override func configure() {
        super.configure()
        configureDataSource()
    }
    
    override func configureNavigation() {
        self.tabBarItem.title = "홈"
        self.tabBarItem.image = UIImage(named: "")
        self.tabBarItem.selectedImage = UIImage(named: "")
    }
    
    override func bind() {
    }
    
    //MARK: - UI Method
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubview(modernCollectionView)
    }
    
    override func configureViewConstraints() {
        modernCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func generateLayout() -> UICollectionViewLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .sidebar)
        listConfiguration.headerMode = .firstItemInSection
        listConfiguration.backgroundColor = .clear
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        return layout
    }
    
    //MARK: - Helper
    func configureDataSource() {
        let headerCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, HomeItemModel> { cell, indexPath, itemIdentifier in
            var configuration = cell.defaultContentConfiguration()
            configuration.attributedText = NSAttributedString(AttributedString(itemIdentifier.title, attributes: AttributeContainer([.font: UIFont.boldSystemFont(ofSize: 17)])))
            
            cell.contentConfiguration = configuration
            cell.accessories = [.outlineDisclosure()]
            cell.tintColor = .label
        }
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, HomeItemModel> { cell, indexPath, itemIdentifier in
            var configuration = cell.defaultContentConfiguration()
            configuration.attributedText = NSAttributedString(AttributedString(itemIdentifier.title, attributes: AttributeContainer([.font: UIFont.Custom.generalBody])))
            configuration.image = itemIdentifier.image
            configuration.imageProperties.tintColor = .label
            
            cell.contentConfiguration = configuration
        }
        
        
        
        diffableDataSource = UICollectionViewDiffableDataSource(collectionView: modernCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier.itemType {
            case .header:
                return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: itemIdentifier)
            case .cell:
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            }
        })
        
        SectionType.allCases.forEach { sectionType in
            var addButton: HomeItemModel
            
            switch sectionType {
            case .channel:
                addButton = HomeItemModel(title: "채널 추가", notification: 0, itemType: .cell, image: UIImage(systemName: "plus"))
                diffableDataSource.apply(createSectionSnapShot(sectionTitle: sectionType.ownTitle, items: [addButton]), to: sectionType)
            case .directMessage:
                addButton = HomeItemModel(title: "새 메세지 추가", notification: 0, itemType: .cell, image: UIImage(systemName: "plus"))
                var snapShot = createSectionSnapShot(sectionTitle: sectionType.ownTitle, items: [addButton])
                snapShot.append([HomeItemModel(title: "팀원 추가", notification: 0, itemType: .cell, image: UIImage(systemName: "plus"))])
                diffableDataSource.apply(snapShot, to: sectionType)
            }
        }
    }
    
    private func createSectionSnapShot(sectionTitle: String, items: [HomeItemModel]) -> NSDiffableDataSourceSectionSnapshot<HomeItemModel> {
        let headerItem = HomeItemModel(title: sectionTitle, notification: 0, itemType: .header, image: nil)
        
        var snapshot = NSDiffableDataSourceSectionSnapshot<HomeItemModel>()
        snapshot.append([headerItem])
        snapshot.expand([headerItem])
        
        
        snapshot.append(items, to: headerItem)
        
        return snapshot
    }
        
    
    
    
}


#Preview {
    UINavigationController(rootViewController: HomeInitialViewController())
}
