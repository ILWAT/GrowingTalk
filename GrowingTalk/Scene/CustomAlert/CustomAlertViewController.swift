//
//  CustomAlertViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/7/24.
//

import UIKit
import RxCocoa
import RxSwift

final class CustomAlertViewController: BaseViewController {
    //MARK: - UI Properties
    private let popUpView = UIView().then { view in
        view.layer.cornerRadius = 16
        view.backgroundColor = .white
    }
    
    private let popUpTitleLabel = UILabel().then { view in
        view.font = .Custom.appTitle2
        view.textAlignment = .center
        view.numberOfLines = 1
    }
    
    private let popUpBodyLabel = UILabel().then { view in
        view.font = .Custom.generalBody
        view.textAlignment = .center
        view.numberOfLines = 0
        view.textColor = .TextColor.textSecondaryColor
    }
    
    private lazy var popUpTextStack = UIStackView().then { view in
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .center
        view.distribution = .equalSpacing
        view.addArrangedSubview(popUpTitleLabel)
        view.addArrangedSubview(popUpBodyLabel)
    }
    
    private let acceptButton = UIButton().then { view in
        view.backgroundColor = .BrandColor.brandGreen
        view.layer.cornerRadius = 8
        view.tintColor = .white
    }
    
    private let cancelButton = UIButton().then { view in
        view.isHidden = true
        view.backgroundColor = .BrandColor.brandGray
        view.layer.cornerRadius = 8
        view.tintColor = .white
    }
    
    private lazy var buttonStack = UIStackView().then { view in
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .fill
        view.distribution = .fillEqually
        view.addArrangedSubview(cancelButton)
        view.addArrangedSubview(acceptButton)
    }
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    init(popUpTitle: String, popUpBody: String, colorButtonTitle: String, cancelButtonTitle: String?) {
        popUpTitleLabel.text = popUpTitle
        popUpBodyLabel.text = popUpBody
        acceptButton.setTitle(colorButtonTitle, for: .normal)
        acceptButton.titleLabel?.font = .Custom.appTitle2
        if let cancelButtonTitle = cancelButtonTitle {
            cancelButton.isHidden = false
            cancelButton.setTitle(cancelButtonTitle, for: .normal)
            cancelButton.titleLabel?.font = .Custom.appTitle2
        } else {
            cancelButton.isHidden = true
        }
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("CustomAlert deinit")
    }
    
    //MARK: - Configure VC
    override func configure() {
        super.configure()
    }
    
    override func bind() {
        cancelButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Configure UI
    override func configureViewHierarchy() {
        self.view.backgroundColor = .black.withAlphaComponent(0.5)
        self.view.addSubview(popUpView)
        self.popUpView.addSubViews([popUpTextStack, buttonStack])
    }
    
    override func configureViewConstraints() {
        popUpView.snp.makeConstraints { make in
            make.center.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(25)
        }
        popUpTextStack.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview().inset(16)
        }
        buttonStack.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.horizontalEdges.equalTo(popUpTextStack)
            make.top.equalTo(popUpTextStack.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    //MARK: - Helper
    
    func transform(okObservable: PublishSubject<Void>?){
        acceptButton.rx.tap.bind(with: self) { owner, _ in
            okObservable?.onNext(())
            owner.dismiss(animated: true)
        }
        .disposed(by: disposeBag)
    }
    
}
