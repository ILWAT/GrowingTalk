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
    
    private var workSpaceInfo: [GetUserWorkSpaceResultModel] = []
    
    //MARK: - Initialization
    init(userOwnWorkSpaceInfo: [GetUserWorkSpaceResultModel]? = nil) {
        if let userOwnWorkSpaceInfo {
            for item in userOwnWorkSpaceInfo {
                self.workSpaceInfo.append(item)
            }
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Override
    override func configure() {
        super.configure()
//        addChildVC()
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
    
    //MARK: - Helper
    func createUICollectionViewLayout() -> UICollectionViewLayout {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.backgroundColor = .white
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        return layout
    }
    
    func sideBarAppearAnimation() {
        self.view.layoutIfNeeded() //AutoLayout을 통해 뷰의 초기 위치와 크기를 잡았기에 애니메이션을 해당 메서드 실행 -> 뷰가 실제로 보여지기 전까지 초기 AutoLayout은 실행되지 않음
        sideBarView.snp.updateConstraints { make in
            make.leading.equalTo(self.view)
        }
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    func sideBarDisAppearAnimation() {
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
            if abs(translation.x) <= sidebarWidth, sideBarView.frame.maxX <= sidebarWidth{
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
    
    func updateSidebarOffset(delta: CGFloat) {
        sideBarView.snp.updateConstraints { make in
            make.leading.equalTo(self.view).offset(delta)
        }
        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
        }
    }
}

