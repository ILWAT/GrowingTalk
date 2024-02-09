//
//  SideBarController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/30/24.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class SideBarController: BaseViewController {
    //MARK: - UIProperties
    private let backgroundView = UIView().then { view in
        view.backgroundColor = .black.withAlphaComponent(0.5)
    }
    private let titleLabel = UILabel().then { label in
        label.text = "워크스페이스"
        label.font = .Custom.appTitle1
    }
    
    private let addWorkspaceButton = UIButton().then { button in
        var config = UIButton.Configuration.plain()
        let plusimage = UIImage(systemName: "plus")//?.resizingByRenderer(size: CGSize(width: 18, height: 18), tintColor: .BrandColor.brandGray)
        config.image = plusimage
        config.baseForegroundColor = .TextColor.textSecondaryColor
        config.imagePadding = CGFloat(16)
        button.configuration = config
        
        button.backgroundColor = .white
        button.setTitle("워크스페이스 추가", for: .normal)
        button.contentHorizontalAlignment = .leading
        
    }
    
    private let infoButton = UIButton().then { button in
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .white
        let questionIcon = UIImage(systemName: "questionmark.circle")//?.resizingByRenderer(size: CGSize(width: 18, height: 18), tintColor: .BrandColor.brandGray)
        config.image = questionIcon
        config.baseForegroundColor = .TextColor.textSecondaryColor
        config.imagePadding = CGFloat(16)
        button.configuration = config
        
        button.backgroundColor = .white
        button.setTitle("도움말", for: .normal)
        button.contentHorizontalAlignment = .leading
    }
    
    private lazy var sideBarView = UIView().then { view in
        view.frame = CGRect(origin: .zero, size: CGSize(width: self.view.safeAreaLayoutGuide.layoutFrame.width * 0.8, height: self.view.safeAreaLayoutGuide.layoutFrame.height))
        view.backgroundColor = .BackgroundColor.backgroundPrimaryColor
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        view.addSubViews([titleLabel, collectionView, addWorkspaceButton, infoButton])
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createUICollectionViewLayout())
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
    
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture)).then { gesture in
        gesture.minimumNumberOfTouches = 1
    }
    
    private lazy var emptyView = EmptyWorkSpaceSideView()
    
    //MARK: - Properties
    private var shownWorkspaceID: Int?
    
    private var userId: Int?
    
    private let viewModel = SideBarViewModel()
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, GetUserWorkSpaceResultModel>!
    
    private var moreActionBTNObservable = PublishSubject<GetUserWorkSpaceResultModel?>()
    
    private let exitAction = PublishSubject<Void>()
    
    private let editAction = PublishSubject<Void>()
    
    private let changeAdminAction = PublishSubject<Void>()
    
    private let deleteWorkspaceAction = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()

    
    //MARK: - Initialization
    init(userId: Int? = nil, currentWorkspaceId: Int? = nil, dataSource: UICollectionViewDiffableDataSource<Int, GetUserWorkSpaceResultModel>! = nil) {
        self.dataSource = dataSource
        self.shownWorkspaceID = currentWorkspaceId
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit { print("Sidebar deinit") }
    
    
    //MARK: - Override
    override func configure() {
        super.configure()
        configureDataSource()
    }
    
    override func bind() {
        let input = SideBarViewModel.Input(
            workspaceID: shownWorkspaceID,
            ownerID: userId,
            exitAction: exitAction,
            editAction: editAction,
            changeAdminAction: changeAdminAction,
            deleteWorkspaceAction: deleteWorkspaceAction
        )
        
        let output = viewModel.transform(input)
        
        output.userOwnWorkspace
            .drive(with: self) { owner, workspaces in
                if workspaces.count == 0 {
                    owner.emptyView.isHidden = false
                } else {
                    owner.emptyView.isHidden = true
                }
                owner.cellUpdate(data: workspaces)
            }
            .disposed(by: disposeBag)
        
        moreActionBTNObservable
            .bind(with: self) { owner, model in
                if let data = model {
                    owner.tappedWorkspaceActionButton(data)
                }
        }
        .disposed(by: disposeBag)
        
        output.isUserAdmin
            .drive(with: self) { owner, _ in
                let customAlert = CustomAlertViewController(popUpTitle: "워크스페이스 나가기", popUpBody: "회원님은 워크스페이스 관리자입니다. 워크스페이스 관리자를 다른 멤버로 변경한 후 나갈 수 있습니다.", colorButtonTitle: "확인", cancelButtonTitle: nil)
                customAlert.transform(okObservable: nil)
                owner.present(customAlert, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureViewHierarchy() {
        self.view.backgroundColor = .black.withAlphaComponent(0.5)
        self.view.addSubViews([backgroundView, sideBarView])
        self.view.addGestureRecognizer(panGesture)
        self.backgroundView.addGestureRecognizer(tapGesture)
        self.collectionView.addSubview(emptyView)
    }
    
    override func configureViewConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        sideBarView.snp.makeConstraints { make in
            make.width.equalTo(self.view.safeAreaLayoutGuide).multipliedBy(0.8)
            make.leading.equalTo(self.view.snp.leading).offset(-self.sideBarView.frame.width)
            make.verticalEdges.equalTo(self.view)
        }
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().inset(16)
        }
        infoButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(self.sideBarView)
        }
        addWorkspaceButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.infoButton.snp.top)
            make.horizontalEdges.equalTo(self.sideBarView)
        }
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(sideBarView)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.bottom.equalTo(addWorkspaceButton.snp.top)
        }
        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(24)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sideBarAppearAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sideBarDisAppearAnimation()
    }
    
    //MARK: - CollectionView
    private func createUICollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(72)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 8, bottom: 3, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(72))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
        
    }
    
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<SideBarCell, GetUserWorkSpaceResultModel> {[weak self] cell, indexPath, itemIdentifier in
            let isCurrentWorkspace = (self?.shownWorkspaceID == itemIdentifier.workspace_id)
            cell.configureCellItem(cellData: itemIdentifier, isSelectedCell: isCurrentWorkspace)
            cell.makingObservableSequence().bind(with: cell.self) { owner, model in
                self?.moreActionBTNObservable.onNext(model)
            }
            .disposed(by: cell.disposeBag)
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func cellUpdate(data: [GetUserWorkSpaceResultModel]) {
        var snapshot = NSDiffableDataSourceSectionSnapshot<GetUserWorkSpaceResultModel>()
        snapshot.append(data)
        dataSource.apply(snapshot, to: 0)
    }
    
    //MARK: - Animation Function
    private func sideBarAppearAnimation() {
        self.view.layoutIfNeeded() //AutoLayout을 통해 뷰의 초기 위치와 크기를 잡았기에 애니메이션을 해당 메서드 실행 -> 뷰가 실제로 보여지기 전까지 초기 AutoLayout은 실행되지 않음
        sideBarView.snp.updateConstraints { make in
            make.leading.equalTo(self.view)
        }
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func sideBarDisAppearAnimation() {
        sideBarView.snp.updateConstraints { make in
            make.leading.equalTo(self.view).offset(-self.sideBarView.frame.width)
        }
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func tapGesture(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    @objc func panGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        let sidebarWidth = sideBarView.frame.width
        switch sender.state {
        case .changed:
            if abs(translation.x) <= sidebarWidth{
                let changedMinX = sideBarView.frame.minX + translation.x
                guard changedMinX <= 0, changedMinX >= -sidebarWidth else { return }
                updateSidebarOffset(delta: changedMinX)
            }
        @unknown default:
            if sideBarView.frame.maxX <= (sidebarWidth/2) {
                self.dismiss(animated: true)
            } else {
                updateSidebarOffset(delta: 0)
            }
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    //MARK: - Helper
    private func updateSidebarOffset(delta: CGFloat) {
        sideBarView.snp.updateConstraints { make in
            make.leading.equalTo(self.view).offset(delta)
        }
        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func tappedWorkspaceActionButton(_ input: GetUserWorkSpaceResultModel) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        var alertActions: [UIAlertAction]
        if userId == input.owner_id {
            let editWorkspace = UIAlertAction(title: "워크스페이스 편집", style: .default) { action in
                
            }
            let exitWorkspace = UIAlertAction(title: "워크스페이스 나가기", style: .default) { [weak self] action in
                let customAlert = CustomAlertViewController(popUpTitle: "워크스페이스 나가기", popUpBody: "정말 이 워크스페이스를 떠나시겠습니까?", colorButtonTitle: "나가기", cancelButtonTitle: "취소")
                customAlert.modalTransitionStyle = .crossDissolve
                customAlert.modalPresentationStyle = .overFullScreen
                if let self = self {
                    customAlert.transform(okObservable: self.exitAction)
                }
                self?.present(customAlert, animated: true)
            }
            let modifyAdmin = UIAlertAction(title: "워크스페이스 관리자 변경", style: .default) { action in
                
            }
            let delete = UIAlertAction(title: "워크스페이스 삭제", style: .destructive) { action in
                
            }
            
            alertActions = [editWorkspace, exitWorkspace, modifyAdmin, delete]
        } else {
            let getOutWorkspace = UIAlertAction(title: "워크스페이스 나가기", style: .default) { action in
                print("나가기")
            }
            alertActions = [getOutWorkspace]
        }
        
        alertActions.append(cancelAction)
        
        for action in alertActions {
            alert.addAction(action)
        }
        
        self.present(alert, animated: true)
    }
}

