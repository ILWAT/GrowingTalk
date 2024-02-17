//
//  CreationChannelViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/15/24.
//

import UIKit
import RxCocoa
import RxSwift
import Then

final class CreationChannelViewController: BaseViewController {
    //MARK: - UI Properties
    private let closedButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil).then { item in
        item.tintColor = .label
    }
    
    private let channelNameLabelField = LabelTextField(labelString: "채널 이름", textFieldPlaceHolder: "채널 이름을 입력하세요 (필수)")
    
    private let channelDescriptionLabelField = LabelTextField(labelString: "채널 설명", textFieldPlaceHolder: "채널을 설명하세요 (옵션)")
    
    private let createButton = InteractionButton(titleString: "생성", isActive: false)
    
    //MARK: - Properties
    private let workspaceID: Int
    
    private let completionEvent: BehaviorRelay<Void>
    
    private let viewModel = CreationViewModel()
    
    private let disposeBag = DisposeBag()
    
    
    //MARK: - Initialization
    init(workspaceID: Int, completionEventSubject: BehaviorRelay<Void>) {
        self.workspaceID = workspaceID
        self.completionEvent = completionEventSubject
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit { print("CreateChannelVC",#function)}
    
    //MARK: - VC Method
    override func configure() {
        super.configure()
    }
    
    override func configureNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        self.navigationItem.scrollEdgeAppearance = appearance
        
        self.navigationItem.title = "채널 생성"
        self.navigationItem.setLeftBarButton(closedButton, animated: true)
    }
    
    override func bind() {
        let input = CreationViewModel.Input(
            workspaceID: workspaceID, 
            closeButtonTap: closedButton.rx.tap,
            createButtonTap: createButton.rx.tap,
            channelNameText: channelNameLabelField.textField.rx.text.orEmpty,
            channelDescriptionText: channelDescriptionLabelField.textField.rx.text.orEmpty
        )
        
        let output = viewModel.transform(input)
        
        output.closedButtonTap
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.creationButtonIsEnabled
            .drive(with: self) { owner, isEnabled in
                owner.createButton.changedButtonValid(newValue: isEnabled)
            }
            .disposed(by: disposeBag)
        
        output.createChannelResult
            .drive(with: self) { owner, result in
                switch result {
                case .success(_):
                    owner.completionEvent.accept(())
                    owner.dismiss(animated: true)
                case .failure(let error):
                    break
                }
            }
            .disposed(by: disposeBag)
        
        output.toastMessage
            .drive(with: self) { owner, message in
                owner.view.makeAppBottomToast(toastMessage: message, point: CGPoint(x: owner.view.safeAreaLayoutGuide.layoutFrame.midX, y: owner.createButton.frame.minY - 24))
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - UI Method
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubViews([
            channelNameLabelField,
            channelDescriptionLabelField,
            createButton
        ])
    }
    
    override func configureViewConstraints() {
        channelNameLabelField.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(self.view.safeAreaLayoutGuide).inset(24)
        }
        channelDescriptionLabelField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(channelNameLabelField)
            make.top.equalTo(channelNameLabelField.snp.bottom).offset(24)
        }
        createButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-12)
        }
    }
    
}
