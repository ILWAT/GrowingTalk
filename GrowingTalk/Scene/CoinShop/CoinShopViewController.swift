//
//  CoinShopViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 3/1/24.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift
import SnapKit
import Then
import iamport_ios

final class CoinShopViewController: BaseViewController {
    //MARK: - Type
    enum StoreSectionType {
        case status
        case coinItem
    }
    
    struct CoinShopCellItem: Hashable{
        let section: StoreSectionType
        let title: String
        let description: String
    }
    
    //MARK: - UI Properties
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
    
    private lazy var wkWebView: WKWebView = WKWebView().then { view in
        view.backgroundColor = .clear
    }
    
    //MARK: - Properties
    private var dataSource: UICollectionViewDiffableDataSource<StoreSectionType, CoinShopCellItem>!
    
    private let paymentResponse =  PublishSubject<IamportResponse?>()
    
    private let viewModel = CoinShopViewModel()
    
    private let disposeBag = DisposeBag()
    
    //MARK: - VC Method
    override func configure() {
        super.configure()
        configureCollectionViewDataSource()
    }
    
    override func configureNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.title = "코인샵"
        
        self.tabBarItem.selectedImage = UIImage(named: "ActiveProfile")
        self.tabBarItem.image = UIImage(named: "InactiveProfile")
        self.tabBarItem.title = "코인샵"
    }
    
    //MARK: - UI Method
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubview(collectionView)
    }
    
    override func configureViewConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    override func bind() {
        let selectedItem = collectionView.rx.itemSelected
            .map({[weak self] indexPath in
                guard let owner = self else { throw DeviceError.unknownError }
                return  owner.dataSource.itemIdentifier(for: indexPath)
            })
        
        let input = CoinShopViewModel.Input(
            selectedItem: selectedItem, 
            paymentResultSubject: paymentResponse
        )
        
        let output = viewModel.transform(input)
        
        output.userCoin
            .drive(with: self) { owner, coinStatus in
                owner.deleteCoinStatus()
                owner.addItemIdentifierToDataSource(cellItems: [coinStatus])
            }
            .disposed(by: disposeBag)
        
        output.coinShopItems
            .drive(with: self) { owner, shopCellItem in
                owner.addItemIdentifierToDataSource(cellItems: shopCellItem)
            }
            .disposed(by: disposeBag)
        
        output.paymentSubject
            .subscribe(with: self) { owner, iamportPayment in
                Iamport.shared.payment(
                    viewController: owner,
                    userCode: SecretKeys.portOneUserCode,
                    payment: iamportPayment) { response in
                        owner.paymentResponse.onNext(response)
                    }
            }
            .disposed(by: disposeBag)
        
        output.toastMessage
            .drive(with: self) { owner, message in
                owner.view.makeAppToast(toastMessage: message)
            }
            .disposed(by: disposeBag)
        
    }
    
    //MARK: - CollectionView
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.backgroundColor = .BackgroundColor.backgroundPrimaryColor
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        return layout
    }
    
    private func configureCollectionViewDataSource() {
        let storeItemCellRegist = UICollectionView.CellRegistration<UICollectionViewListCell, CoinShopCellItem> { cell, indexPath, itemIdentifier in
            var contentConfig = UIListContentConfiguration.valueCell()
            contentConfig.text = "🌱"+itemIdentifier.title
            cell.contentConfiguration = contentConfig
            cell.accessories = [.label(text: "₩"+itemIdentifier.description)]
        }
        
        let ownCoinCellRegist = UICollectionView.CellRegistration<UICollectionViewListCell, CoinShopCellItem> { cell, indexPath, itemIdentifier in
            var contentConfig = UIListContentConfiguration.valueCell()
            
            //코인 갯수에 대해서만 색 주입
            let titleText = "🌱현재 보유한 코인"+itemIdentifier.title+"개"
            let attributedString = NSMutableAttributedString(string: titleText)
            let range = (titleText as NSString).range(of: itemIdentifier.title+"개")
            attributedString.addAttributes([.foregroundColor: UIColor.BrandColor.brandGreen], range: range)
            contentConfig.attributedText = attributedString
            //---------------------
            
            cell.contentConfiguration = contentConfig
            cell.accessories = [.label(text: itemIdentifier.description)]
        }
        
        dataSource = UICollectionViewDiffableDataSource<StoreSectionType, CoinShopCellItem>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier.section {
            case .coinItem:
                collectionView.dequeueConfiguredReusableCell(using: storeItemCellRegist, for: indexPath, item: itemIdentifier)
            case .status:
                collectionView.dequeueConfiguredReusableCell(using: ownCoinCellRegist, for: indexPath, item: itemIdentifier)
            }
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<StoreSectionType, CoinShopCellItem>()
        snapshot.appendSections([.status, .coinItem])
        dataSource.apply(snapshot)
    }
    
    private func addItemIdentifierToDataSource(cellItems: [CoinShopCellItem]) {
        var snapshot = dataSource.snapshot()
        for cellItem in cellItems {
            snapshot.appendItems([cellItem], toSection: cellItem.section)
        }
        dataSource.apply(snapshot)
    }
    
    private func deleteCoinStatus() {
        var snapshot = dataSource.snapshot(for: .status)
        snapshot.deleteAll()
        dataSource.apply(snapshot, to: .status)
    }
}
