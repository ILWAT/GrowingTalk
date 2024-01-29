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

struct HomeItemModel: Hashable {
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
    
    private lazy var channelAddButtonModel = HomeItemModel(title: "채널 추가", notification: 0, itemType: .cell, image: plusImage)
    
    private lazy var dmAddButtonItem = HomeItemModel(title: "새 메세지 추가", notification: 0, itemType: .cell, image: plusImage)
    
    private lazy var addTeamButtonItem = HomeItemModel(title: "팀원 추가", notification: 0, itemType: .cell, image: plusImage)
    
    //MARK: - Properties
    private let viewModel = HomeInitialViewModel()
    
    private let disposeBag = DisposeBag()
    
    private var workSpaceInfo: GetUserWorkSpaceResultModel //현 워크스페이스 정보
    
    private var channelTitleItem = HomeItemModel(title: "채널", notification: 0, itemType: .header, image: nil)
    
    private var directMessageTitle = HomeItemModel(title: "다이렉트 메세지", notification: 0, itemType: .header, image: nil)
    
    private var plusImage: UIImage? = UIImage(systemName: "plus")?.resizingByRenderer(size: CGSize(width: 18, height: 18), tintColor: .TextColor.textSecondaryColor)
    
    
    //MARK: - Initialization
    init(workspaceInfo: GetUserWorkSpaceResultModel){
        self.workSpaceInfo = workspaceInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - VC Method
    override func configure() {
        super.configure()
        configureDataSource()
    }
    
    override func configureNavigation() {
        super.configureNavigation()
        makeHomeNavigationBar(title: workSpaceInfo.name, workSpaceImageURL: workSpaceInfo.thumbnail)
        self.tabBarItem.title = "홈"
        self.tabBarItem.image = UIImage(named: "InactiveHome")
        self.tabBarItem.selectedImage = UIImage(named: "ActiveHome")
    }
    
    override func bind() {
        let input = HomeInitialViewModel.Input(
            workSpaceID: self.workSpaceInfo.workspace_id
        )
        
        let output = viewModel.transform(input)
        
        output.channelCell
            .drive(with: self) { owner, channelCell in
                
                owner.regenerateSectionSnapshot(sectionType: .channel, subItems: channelCell, item: [])
            }
            .disposed(by: disposeBag)
        
        output.dmCell
            .drive(with: self) { owner, dmCell in
                owner.regenerateSectionSnapshot(sectionType: .directMessage, subItems: dmCell, item: [])
            }
            .disposed(by: disposeBag)
        
        output.profileImage
            .drive(with: self) { owner, image in
                if let image {
                    owner.profileImageButton.image = image
                }
            }
            .disposed(by: disposeBag)

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
        listConfiguration.backgroundColor = .white
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
            configuration.attributedText = NSAttributedString(AttributedString(itemIdentifier.title, attributes: AttributeContainer([.font: UIFont.Custom.generalBody ?? .systemFont(ofSize: 17), .foregroundColor: UIColor.TextColor.textSecondaryColor])))
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
            switch sectionType {
            case .channel:
                diffableDataSource.apply(createSectionSnapShot(headerItem: channelTitleItem, items: [channelAddButtonModel]), to: sectionType)
            case .directMessage:
                var snapShot = createSectionSnapShot(headerItem: directMessageTitle, items: [dmAddButtonItem])
                snapShot.append([addTeamButtonItem])
                diffableDataSource.apply(snapShot, to: sectionType)
            }
        }
    }
    
    private func createSectionSnapShot(headerItem: HomeItemModel, items: [HomeItemModel]) -> NSDiffableDataSourceSectionSnapshot<HomeItemModel> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<HomeItemModel>()
        snapshot.append([headerItem])
        snapshot.expand([headerItem])
        
        snapshot.append(items, to: headerItem)
        
        return snapshot
    }
        
    
    private func regenerateSectionSnapshot(sectionType: SectionType, subItems: [HomeItemModel], item: [HomeItemModel]) {
        
        var snapshot = diffableDataSource.snapshot(for: sectionType)
        
        let addButton: HomeItemModel
        
        switch sectionType {
        case .channel:
            addButton = channelAddButtonModel
        case .directMessage:
            addButton = dmAddButtonItem
        }
        
        if let firstItems = snapshot.items.first {
            snapshot.append(subItems, to: firstItems)
            snapshot.delete([addButton])
            snapshot.append([addButton], to: firstItems)
            snapshot.append(item)
        }
        
        diffableDataSource.apply(snapshot, to: sectionType)
    }
    
}


//#Preview {
//    UINavigationController(rootViewController: HomeInitialViewController(workspaceInfo: GetMyAllChannelResultModel(workspaceId: 116, channelId: 148, name: "일반", description: nil, ownerId: 213, isPrivate: 0, createdAt: "2024-01-16T10:30:58.900Z")))
//}
