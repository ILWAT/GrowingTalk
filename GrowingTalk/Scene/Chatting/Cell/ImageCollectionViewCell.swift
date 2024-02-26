//
//  ImageCollectionViewCell.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/26/24.
//

import UIKit
import RxCocoa
import RxSwift
import Then

final class ImageCollectionViewCell: UICollectionViewCell {
    //MARK: - UI Properties
    private let imageView = UIImageView().then { view in
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
    }
    
    private let deleteButton = UIButton().then { button in
        button.frame = CGRect(origin: .zero, size: CGSize(width: 16, height: 16))
        button.setImage(UIImage(systemName: "xmark")?.resizingByRenderer(size: CGSize(width: 10, height: 10), tintColor: nil), for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.tintColor = .label
        button.backgroundColor = .white
    }
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViewHierarchy()
        configureViewConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Method
    private func configureViewHierarchy() {
        self.contentView.addSubViews([imageView, deleteButton])
    }
    
    private func configureViewConstraint() {
        imageView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.size.equalTo(44)
        }
        deleteButton.snp.makeConstraints { make in
            make.size.equalTo(16)
            make.centerX.equalTo(imageView.snp.trailing)
            make.centerY.equalTo(imageView.snp.top)
            make.trailing.top.equalToSuperview().inset(2)
        }
    }
    
    func bindButton(deleteActionSubject: PublishRelay<UIImage>, itemIdentifier: UIImage) {
        deleteButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                deleteActionSubject.accept(itemIdentifier)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - configureCell
    func configureCell(targetImage: UIImage) {
        imageView.image = targetImage
    }
}
