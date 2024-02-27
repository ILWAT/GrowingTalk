//
//  ChattingViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/19/24.
//

import UIKit
import PhotosUI
import RxCocoa
import RxSwift
import Then

import SwiftUI

final class ChattingViewController: BaseViewController {
    //MARK: - UI Properties
    private let closeButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: nil, action: nil).then { item in
        item.tintColor = .label
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewFlowLayout())
    
    private let userTextView = UITextView().then { view in
        view.font = .Custom.generalBody
        view.textColor = .TextColor.textSecondaryColor
        view.backgroundColor = .BackgroundColor.backgroundPrimaryColor
        view.showsHorizontalScrollIndicator = false
        view.isScrollEnabled = false
    }
    
    private let addFileButton = UIButton().then { view in
        view.setImage(UIImage(systemName: "plus"), for: .normal)
        view.tintColor = .label
    }
    
    private let sendButton = UIButton().then { view in
        view.setImage(UIImage(named: "ChattingSendActive"), for: .normal)
        view.setImage(UIImage(named: "ChattingSend"), for: .disabled)
        view.isEnabled = false
    }
    
    private let textBox = UIView().then { view in
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = .BackgroundColor.backgroundPrimaryColor
    }
    
    private let userTextStackView = UIStackView().then { view in
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.spacing = 5
        view.alignment = .fill

    }
    
    private let inputBox = UIView().then { view in
        view.backgroundColor = .white
    }
    
    private lazy var imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createImageCollectionViewLayout()).then { view in
        view.backgroundColor = .clear
    }
    
    private let tapGesture = UITapGestureRecognizer()
    
    
    //MARK: - Properties
    private let placeHolder = "메세지를 입력해주세요."
    
    private let workspaceID: Int
    
    private let ownName: String
    
    private let ownID: Int
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, ChannelChatModel>!
    
    private var imageDataSource: UICollectionViewDiffableDataSource<Int, UIImage>!
    
    private let imageContentSubject = BehaviorSubject<[UIImage]>(value: [])
    
    private let deleteActionSubject = PublishRelay<UIImage>()
    
    private let viewWillDisappearTrigger = PublishRelay<String>()
    
    private let viewModel = ChattingViewModel()
    
    private let disposBag = DisposeBag()
    
    //MARK: - Initialization
    init(workspaceID: Int, ownID: Int, ownName: String) {
        self.workspaceID = workspaceID
        self.ownID = ownID
        self.ownName = ownName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearTrigger.accept(getLastChatDate())
    }
    
    //MARK: - Configure VC
    override func configure() {
        super.configure()
        self.userTextView.text = placeHolder
        self.view.addGestureRecognizer(tapGesture)
        createDiffableDataSource()
        generateSnapShot()
        createImageDataSource()
    }
    
    override func configureNavigation() {
        self.navigationItem.title = "#"+ownName
    }
    
    override func bind() {
        
        userTextView.rx.text.orEmpty
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, text in
                if text.isEmpty || text == owner.placeHolder {
                    owner.sendButton.isEnabled = false
                } else {
                    owner.sendButton.isEnabled = true
                }
                owner.view.layoutIfNeeded()
            }
            .disposed(by: disposBag)
        
        userTextView.rx.didEndEditing
            .observe(on: MainScheduler.instance)
            .withLatestFrom(userTextView.rx.text.orEmpty)
            .filter({ $0.isEmpty })
            .bind(with: self) { owner, text in
                owner.userTextView.text = owner.placeHolder
                owner.userTextView.textColor = .TextColor.textSecondaryColor
            }
            .disposed(by: disposBag)
        
        userTextView.rx.didBeginEditing
            .observe(on: MainScheduler.instance)
            .withLatestFrom(userTextView.rx.text.orEmpty)
            .filter({[weak self] in
                $0 == self?.placeHolder
            })
            .bind(with: self, onNext: { owner, text in
                let textView = owner.userTextView
                textView.text = ""
                textView.textColor = .label
            })
            .disposed(by: disposBag)
        
        addFileButton.rx.tap
            .bind(with: self) { owner, _ in
                var config = PHPickerConfiguration()
                config.selectionLimit = 5
                config.filter = .any(of: [.images, .screenshots])
                
                let selectionVC = PHPickerViewController(configuration: config)
                selectionVC.delegate = owner
                owner.present(selectionVC, animated: true)
            }
            .disposed(by: disposBag)
        
        tapGesture.rx.event
            .bind(with: self) { owner, tapGesture in
                owner.view.endEditing(true)
            }
            .disposed(by: disposBag)
        
        imageContentSubject
            .subscribe(with: self) { owner, images in
                if images.isEmpty {
                    owner.imageCollectionView.isHidden = true
                    if owner.userTextView.text == owner.placeHolder {
                        owner.sendButton.isEnabled = false
                    }
                } else {
                    owner.imageCollectionView.isHidden = false
                    owner.sendButton.isEnabled = true
                }
            }
            .disposed(by: disposBag)
        
        deleteActionSubject
            .bind(with: self) { owner, image in
                owner.deleteImage(deleteImage: [image])
            }
            .disposed(by: disposBag)
        
        let input = ChattingViewModel.Input(
            workspaceID: workspaceID,
            ownName: ownName,
            ownID: ownID,
            sendButtonTap: sendButton.rx.tap,
            contentText: userTextView.rx.text.orEmpty,
            imageContent: imageContentSubject,
            viewWillDisappearTrigger: viewWillDisappearTrigger
        )
        
        let output = viewModel.transform(input)
        
        output.willUpdateChatData
            .drive(with: self) { owner, chatDatas in
                owner.updateNewDataSnapshot(updateData: chatDatas)
                owner.scrollToBottom(collectionView: owner.collectionView, animated: true)
            }
            .disposed(by: disposBag)
        
        output.postChatIsSuccess
            .drive(with: self) { owner, _ in
                owner.userTextView.text = ""
                owner.deleteAllImage()
            }
            .disposed(by: disposBag)
        
    }
    
    //MARK: - Configure UI
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubViews([collectionView, inputBox])
        inputBox.addSubview(textBox)
        userTextStackView.addArrangedSubview(userTextView)
        userTextStackView.addArrangedSubview(imageCollectionView)
        textBox.addSubViews([addFileButton, userTextStackView, sendButton])
    }
    
    override func configureViewConstraints() {
        inputBox.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        }
        textBox.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        addFileButton.snp.makeConstraints { make in
            make.size.equalTo(22)
            make.leading.equalToSuperview().inset(12)
            make.top.greaterThanOrEqualToSuperview().inset(9)
            make.bottom.equalToSuperview().inset(9)
        }
        userTextStackView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(textBox)
            make.leading.equalTo(addFileButton.snp.trailing).offset(8)
            make.height.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).multipliedBy(0.3)
        }
        imageCollectionView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
        sendButton.snp.makeConstraints { make in
            make.size.equalTo(22)
            make.leading.equalTo(userTextView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalTo(addFileButton)
        }
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(inputBox.snp.top)
        }
    }
    
    //MARK: - Modern CollectionView
    
    private func createCollectionViewFlowLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(87)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(87)
        )
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func createDiffableDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ChattingCollectionViewCell, ChannelChatModel> { cell, indexPath, itemIdentifier in
            cell.setUpCell(channelChat: itemIdentifier)
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func generateSnapShot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ChannelChatModel>()
        snapshot.appendSections([0])
        dataSource.apply(snapshot)
    }
    
    private func updateNewDataSnapshot(updateData: [ChannelChatModel]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(updateData, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    //MARK: - Image CollectionView
    private func createImageCollectionViewLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(50),
            heightDimension: .absolute(50)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .continuous
        
        section.interGroupSpacing = 5
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    
    private func createImageDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ImageCollectionViewCell, UIImage> { [weak self] cell, indexPath, itemIdentifier in
            guard let owner = self else {return}
            cell.configureCell(targetImage: itemIdentifier)
            cell.bindButton(deleteActionSubject: owner.deleteActionSubject, itemIdentifier: itemIdentifier)
        }
        
        imageDataSource = UICollectionViewDiffableDataSource(collectionView: imageCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, UIImage>()
        snapshot.appendSections([0])
        imageDataSource.apply(snapshot)
    }
    
    func regenerateImageDataSource(addImages: [UIImage]) {
        var snapshot = imageDataSource.snapshot()
        snapshot.appendItems(addImages)
        imageDataSource.apply(snapshot)
        emitImageContent()
    }
    
    private func deleteImage(deleteImage: [UIImage]) {
        var snapshot = imageDataSource.snapshot()
        snapshot.deleteItems(deleteImage)
        imageDataSource.apply(snapshot)
        emitImageContent()
    }
    
    private func deleteAllImage() {
        var snapshot = imageDataSource.snapshot(for: 0)
        snapshot.deleteAll()
        imageDataSource.apply(snapshot, to: 0)
        emitImageContent()
    }
    
    private func emitImageContent() {
        let snapshot = imageDataSource.snapshot()
        let images = snapshot.itemIdentifiers
        imageContentSubject.onNext(images)
    }
    
    
    
    //MARK: - Helper
    
    private func getLastChatDate() -> String {
        let snapshot = dataSource.snapshot()
        guard let lastItem = snapshot.itemIdentifiers(inSection: 0).last else {return ""}
        return lastItem.createdAt
    }
    
    private func scrollToBottom(collectionView: UICollectionView, animated: Bool) {
        if collectionView.contentSize.height < collectionView.bounds.size.height {
            return
        }
        
        print(collectionView.contentSize.height, collectionView.bounds.size.height, collectionView.frame.size.height)
        let bottomOffset = CGPoint(x: 0, y: collectionView.contentSize.height - collectionView.bounds.size.height)
        print(bottomOffset)
        collectionView.setContentOffset(bottomOffset, animated: animated)
    }
}

extension ChattingViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        deleteAllImage()
        
        picker.dismiss(animated: true)
        
        guard !results.isEmpty else {return}
        
        results.forEach { pickerResult in
            
            let provider = pickerResult.itemProvider
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    guard let typeCastingImage = image as? UIImage, let owner = self else {return}
                    DispatchQueue.main.async {
                        owner.regenerateImageDataSource(addImages: [typeCastingImage])
                    }
                }
            }
        }
    }
}
