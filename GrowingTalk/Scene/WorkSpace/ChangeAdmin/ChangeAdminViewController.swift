//
//  ChangeAdminViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/11/24.
//

import UIKit
import RxCocoa
import RxSwift

final class ChangeAdminViewController: BaseViewController {
    //MARK: - UI Properties
    private lazy var closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(tappedCloseButton)).then { item in
        item.tintColor = .label
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureUICollectionViewLayout())
    
    
    //MARK: - Properties
    private let viewModel = ChangeAdminViewModel()
    
    private let viewUpdateTrigger = BehaviorSubject<Void>(value: ())
    
    private let workspaceID: Int
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, UserInfo>?
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    init(workspaceID: Int) {
        self.workspaceID = workspaceID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure VC
    override func configure() {
        super.configure()
        configureDataSource()
    }
    
    override func configureNavigation() {
        self.navigationItem.title = "워크스페이스 관리자 변경"
        self.navigationItem.setLeftBarButton(closeButton, animated: true)
    }
    
    override func bind() {
        let viewDismissTrigger = PublishSubject<Void>()
        
        let input = ChangeAdminViewModel.Input(
            viewUpdateTrigger: viewUpdateTrigger,
            workspaceID: workspaceID
        )
        
        let output = viewModel.transform(input)
        
        output.getMembersResult
            .drive(with: self) { owner, result in
                switch result {
                case .success(let users):
                    owner.applySnapshot(items: users)
                case .failure(let error):
                    if let error = error as? DeviceError {
                        if error == DeviceError.intentionalError {
                            let alert = CustomAlertViewController(popUpTitle: "워크스페이스 관리자 변경 불가", popUpBody: "워크스페이스 멤버가 없어 관리자 변경을 할 수 없습니다. 새로운 멤버를 워크스페이스에 초대해보세요", colorButtonTitle: "확인", cancelButtonTitle: nil)
                            alert.transform(okObservable: viewDismissTrigger)
                            owner.present(alert, animated: true)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        viewDismissTrigger
            .debug("viewDismissTrigger")
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                guard let dataSource = owner.dataSource, let cellData = dataSource.itemIdentifier(for: indexPath) else {return}
                
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Configure UI
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubview(collectionView)
    }
    
    override func configureViewConstraints() {
        collectionView.snp.makeConstraints { make in
            make.size.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    //MARK: - CollectionView
    private func configureUICollectionViewLayout() -> UICollectionViewLayout {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.backgroundColor = .BackgroundColor.backgroundPrimaryColor
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        return layout
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<MembersCollectionViewCell, UserInfo> { cell, indexPath, itemIdentifier in
            cell.settingUI(userInfo: itemIdentifier)
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func applySnapshot(items: [UserInfo]) {
        var snapshot = NSDiffableDataSourceSectionSnapshot<UserInfo>()
        snapshot.append(items)
        
        dataSource?.apply(snapshot, to: 0)
    }
    //MARK: - Helper
    
    
    @objc func tappedCloseButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}
