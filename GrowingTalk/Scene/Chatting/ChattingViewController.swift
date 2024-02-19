//
//  ChattingViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/19/24.
//

import UIKit
import RxCocoa
import RxSwift
import Then

import SwiftUI

final class ChattingViewController: BaseViewController {
    //MARK: - UI Properties
    private let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil).then { item in
        item.tintColor = .label
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewFlowLayout())
    
    private let userTextView = UITextView().then { view in
        view.text = "메세지를 입력하세요."
        view.font = .Custom.generalBody
        view.textColor = .TextColor.textSecondaryColor
        view.backgroundColor = .BackgroundColor.backgroundPrimaryColor
        view.isScrollEnabled = false
        view.sizeToFit()
    }
    
    private let addFileButton = UIButton().then { view in
        view.setImage(UIImage(systemName: "plus"), for: .normal)
        view.tintColor = .label
    }
    
    private let sendButton = UIButton().then { view in
        view.setImage(UIImage(named: "ChattingSend"), for: .normal)
    }
    
    private let textBox = UIView().then { view in
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = .BackgroundColor.backgroundPrimaryColor
    }
    
    private let inputBox = UIView().then { view in
        view.backgroundColor = .white
    }
    
    
    
    
    //MARK: - Properties
    
    
    //MARK: - Configure VC
    override func configure() {
        super.configure()
    }
    
    override func configureNavigation() {
        
    }
    
    //MARK: - Configure UI
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubViews([collectionView, inputBox])
        inputBox.addSubview(textBox)
        textBox.addSubViews([addFileButton, userTextView, sendButton])
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
            make.top.lessThanOrEqualToSuperview().inset(9)
            make.bottom.equalToSuperview().inset(9)
        }
        userTextView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(textBox)
            make.leading.equalTo(addFileButton.snp.trailing).offset(8)
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
        inputBox.autoresizingMask = .flexibleHeight
        textBox.autoresizingMask = .flexibleHeight
        userTextView.autoresizingMask = .flexibleHeight
    }
    
    //MARK: - Modern CollectionView
    
    private func createCollectionViewFlowLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
}
