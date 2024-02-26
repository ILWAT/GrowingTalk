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
    let ownID: Int
    let itemType: ItemType
    let image: UIImage?
    
    enum ItemType {
        case header, defaultCell, addChannel, addDM, addMember
    }
}



final class HomeInitialViewController: BaseHomeViewController {
    //MARK: - UI Properties
    
    private let inviteButton = UIButton().then { view in
        view.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        view.layer.cornerRadius = 27
        view.backgroundColor = .BrandColor.brandGreen
        view.tintColor = .white
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
    }
    private lazy var modernCollectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then { view in
        view.backgroundColor = .BackgroundColor.backgroundPrimaryColor
    }
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<SectionType, HomeItemModel>!
    
    private lazy var channelAddButtonModel = HomeItemModel(title: "채널 추가", ownID: 0, itemType: .addChannel, image: plusImage)
    
    private lazy var dmAddButtonItem = HomeItemModel(title: "새 메세지 추가", ownID: 0, itemType: .addDM, image: plusImage)
    
    private lazy var addTeamButtonItem = HomeItemModel(title: "팀원 추가", ownID: 0, itemType: .addMember, image: plusImage)
    
    //MARK: - Properties
    private let viewModel = HomeInitialViewModel()
    
    private var channelTitleItem = HomeItemModel(title: "채널", ownID: 0, itemType: .header, image: nil)
    
    private var directMessageTitle = HomeItemModel(title: "다이렉트 메세지", ownID: 0, itemType: .header, image: nil)
    
    private var plusImage: UIImage? = UIImage(systemName: "plus")?.resizingByRenderer(size: CGSize(width: 18, height: 18), tintColor: .TextColor.textSecondaryColor)
    
    private let channelEvent = BehaviorRelay<Void>(value: ())
    
    private let dmEvent = BehaviorRelay<Void>(value: ())
    
    
    //MARK: - Initialization
    init(currentWorkspaceInfo: WorkSpaceModel, userId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.workspaceInfo = currentWorkspaceInfo
        self.userId = userId
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
        makeHomeNavigationBar(title: workspaceInfo!.name, workSpaceImageURL: workspaceInfo!.thumbnail)
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backButton.tintColor = .label
        self.navigationItem.backBarButtonItem = backButton
        self.tabBarItem.title = "홈"
        self.tabBarItem.image = UIImage(named: "InactiveHome")
        self.tabBarItem.selectedImage = UIImage(named: "ActiveHome")
    }
    
    override func bind() {
        super.bind()
        
        let input = HomeInitialViewModel.Input(
            channelUpdate: channelEvent,
            dmUpdate: dmEvent,
            workSpaceID: self.workspaceInfo!.workspace_id,
            inviteButtonTap: inviteButton.rx.tap
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
        
        output.inviteButtonTap
            .drive(with: self) { owner, _ in
                guard let workSpaceID = owner.workspaceInfo?.workspace_id else {return}
                let nextVC = InviteMemberViewController(workspaceID: workSpaceID)
                let navVC = UINavigationController(rootViewController: nextVC)
                owner.present(navVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        modernCollectionView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                guard let item = owner.diffableDataSource.itemIdentifier(for: indexPath) else {return}
                switch item.itemType {
                case .header:
                    break
                case .defaultCell:
                    guard let workSpaceID = owner.workspaceInfo?.workspace_id else {return}
                    let chattingVC = ChattingViewController(workspaceID: workSpaceID, ownID: item.ownID, ownName: item.title)
                    owner.navigationController?.pushViewController(chattingVC, animated: true)
                    print(item)
                case .addChannel:
                    owner.selectedAddChannel()
                    print("addChannel")
                case .addDM:
                    print("addDM")
                case .addMember:
                    print("addMember")
                }
            }
            .disposed(by: disposeBag)
        

    }
    
    //MARK: - UI Method
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubview(modernCollectionView)
        self.view.addSubview(inviteButton)
    }
    
    override func configureViewConstraints() {
        modernCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        inviteButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(16)
            make.size.equalTo(54)
        }
    }
    
    func generateLayout() -> UICollectionViewLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .sidebar)
        listConfiguration.headerMode = .firstItemInSection
        listConfiguration.backgroundColor = .white
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        return layout
    }
    
    //MARK: - compositional CollectionView
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
            default:
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            }
        })
        
        SectionType.allCases.forEach { sectionType in
            switch sectionType {
            case .channel:
                diffableDataSource.apply(createSectionSnapShot(headerItem: channelTitleItem, subItems: [channelAddButtonModel]), to: sectionType)
            case .directMessage:
                let snapShot = createSectionSnapShot(headerItem: directMessageTitle, subItems: [dmAddButtonItem], items: [addTeamButtonItem])
                diffableDataSource.apply(snapShot, to: sectionType)
            }
        }
    }
    
    private func createSectionSnapShot(headerItem: HomeItemModel, subItems: [HomeItemModel], items: [HomeItemModel] = []) -> NSDiffableDataSourceSectionSnapshot<HomeItemModel> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<HomeItemModel>()
        snapshot.append([headerItem])
        snapshot.expand([headerItem]) //해당 스냅샷을 펼침
        
        snapshot.append(subItems, to: headerItem)
        snapshot.append(items)
        
        return snapshot
    }
        
    
    private func regenerateSectionSnapshot(sectionType: SectionType, subItems: [HomeItemModel], item: [HomeItemModel]) {
        var sectionSnapshot = diffableDataSource.snapshot(for: sectionType)
        
        let addButton: HomeItemModel
        
        switch sectionType {
        case .channel:
            addButton = channelAddButtonModel
        case .directMessage:
            addButton = dmAddButtonItem
        }
        
        if let headerItem = sectionSnapshot.items.first {
            sectionSnapshot.deleteAll()
            let changedSnapshot = createSectionSnapShot(headerItem: headerItem, subItems: subItems+[addButton], items: item)
            diffableDataSource.apply(changedSnapshot, to: sectionType)
        }
    }
    
    private func selectedAddChannel() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let creation = UIAlertAction(title: "채널 생성", style: .default) { action in
            guard let workspaceID = self.workspaceInfo?.workspace_id else {return}
            let creationChannelVC = CreationChannelViewController(workspaceID: workspaceID, completionEventSubject: self.channelEvent)
            let navVC = UINavigationController(rootViewController: creationChannelVC)
            self.present(navVC, animated: true)
        }
        let searching = UIAlertAction(title: "채널 탐색", style: .default) { action in
            guard let workspaceID = self.workspaceInfo?.workspace_id else {return}
            let creationChannelVC = SearchChannelViewController(workspaceID: workspaceID, completionEvent: self.dmEvent)
            let navVC = UINavigationController(rootViewController: creationChannelVC)
            self.present(navVC, animated: true)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        [creation, searching, cancel].forEach { action in
            alert.addAction(action)
        }
        
        self.present(alert, animated: true)
    }
    
}


