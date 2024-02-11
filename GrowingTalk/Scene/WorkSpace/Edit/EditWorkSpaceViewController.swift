//
//  EditWorkSpaceViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/10/24.
//

import UIKit
import PhotosUI
import RxCocoa
import RxSwift
import Then
import Kingfisher

protocol EditWorkSpaceProtocol: AnyObject {
    func changeWorkSpaceInfo(changedWorkspaceInfo: WorkSpaceModel)
}

final class EditWorkSpaceViewController: BaseViewController {
    //MARK: - UIProperties
    private let closeButton = UIBarButtonItem().then { item in
        item.tintColor = .label
        item.image = UIImage(systemName: "xmark")
    }
    
    private let workSpaceImage = UIButton().then { view in
        view.setImage(UIImage(named: "WorkSpace")?.resizingByRenderer(size: CGSize(width: 50, height: 60), tintColor: .white), for: .normal)
        view.backgroundColor = .BrandColor.brandGreen
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
    }
    
    private let imgAddButton = UIButton().then { item in
        item.tintColor = .white
        item.backgroundColor = .BrandColor.brandGreen
        item.layer.borderWidth = 3
        item.layer.borderColor = UIColor.white.cgColor
        let image = UIImage(systemName: "camera.fill")?.resizingByRenderer(size: CGSize(width: 12, height:12), tintColor: .white)
        item.setImage(image, for: .normal)
        item.clipsToBounds = true
    }
    
    private let spaceNameLabelField = LabelTextField(labelString: "워크스페이스 이름", textFieldPlaceHolder: "워크스페이스 이름을 입력하세요 (필수)")
    
    private let spaceDiscription = LabelTextField(labelString: "워크 스페이스 설명", textFieldPlaceHolder: "워크스페이스를 설명하세요 (옵션)")
    
    private let completeButton = InteractionButton(titleString: "완료", isActive: false)
    
    private var imageProviders: [NSItemProvider] = []
    
    //MARK: - Properties
    private let viewModel = EditWorkSpaceViewModel()
    
    private let spaceImage = PublishRelay<UIImage?>()
    
    private let workspaceID: Int
    
    private let userID: Int
    
    weak var delegate: EditWorkSpaceProtocol?
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    init(workspaceID: Int, userID: Int, workSpaceInfo: WorkSpaceModel) {
        self.workspaceID = workspaceID
        self.userID = userID
        super.init(nibName: nil, bundle: nil)
        spaceNameLabelField.textField.rx.text.onNext(workSpaceInfo.name)
        spaceDiscription.textField.rx.text.onNext(workSpaceInfo.description)
        KingfisherManager.shared.getImagesWithDownsampling(pathURL: workSpaceInfo.thumbnail, downSamplingSize: CGSize(width: 70, height: 90)) { [weak self] result in
            switch result{
            case .success(let imageResult):
                self?.spaceImage.accept(imageResult.image)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - VC Method
    override func configure() {
        super.configure()
    }
    
    override func configureNavigation() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 17)]
        navigationAppearance.backgroundColor = .white
        
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationAppearance
        self.navigationItem.setLeftBarButton(closeButton, animated: true)
        self.title = "워크스페이스 생성"
        
    }
    
    override func bind() {
        let input = EditWorkSpaceViewModel.Input(
            workspaceID: workspaceID,
            userID: userID,
            closeButtonTap: closeButton.rx.tap,
            imgButtonTap: workSpaceImage.rx.tap,
            imgAddButtonTap: imgAddButton.rx.tap,
            spaceNameText: spaceNameLabelField.textField.rx.text.orEmpty,
            spaceDiscriptionText: spaceDiscription.textField.rx.text.orEmpty,
            spaceImage: spaceImage,
            completeButtonTap: completeButton.rx.tap
        )
        let output = viewModel.transform(input)
        
        output.closeButtonTap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.imgAddReactive
            .drive(with: self, onNext: { owner, _ in
                var pickerConfig = PHPickerConfiguration()
                pickerConfig.selectionLimit = 1
                pickerConfig.filter = .images
                
                let picker = PHPickerViewController(configuration: pickerConfig)
                
                picker.delegate = self
                
                owner.present(picker, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.spaceImage
            .drive(with: self) { owner, image in
                guard let image = image else {
                    owner.workSpaceImage.setImage(UIImage(named: "WorkSpace"), for: .normal)
                    return
                }
                owner.workSpaceImage.setImage(image, for: .normal)
            }
            .disposed(by: disposeBag)
        
        output.buttonActive
            .drive(with: self) { owner, bool in
                owner.completeButton.changedButtonValid(newValue: bool)
            }
            .disposed(by: disposeBag)
        
        output.editedWorkspaceInfo
            .drive(with: self) { owner, result in
                owner.delegate?.changeWorkSpaceInfo(changedWorkspaceInfo: result)
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
    }
    //MARK: - UI Method
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubViews([workSpaceImage, imgAddButton, spaceNameLabelField, spaceDiscription, completeButton])
    }
    
    override func configureViewConstraints() {
        workSpaceImage.snp.makeConstraints { make in
            make.size.equalTo(70)
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(24)
        }
        imgAddButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.centerY.equalTo(workSpaceImage.snp.bottom).inset(3)
            make.centerX.equalTo(workSpaceImage.snp.trailing).inset(3)
        }
        DispatchQueue.main.async{
            self.imgAddButton.layer.cornerRadius = self.imgAddButton.bounds.width/2
        }
        spaceNameLabelField.snp.makeConstraints { make in
            make.top.equalTo(workSpaceImage.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(24)
        }
        spaceDiscription.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(spaceNameLabelField)
            make.top.equalTo(spaceNameLabelField.snp.bottom).offset(24)
        }
        completeButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).inset(12)
        }
        
        
    }
    //MARK: - Helper
    func saveImage() {
        guard let provider = imageProviders.first else {return}
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) {[weak self] item, error in
                guard let owner = self, let image = item as? UIImage else {return}
                
                owner.spaceImage.accept(image)
            }
        }
    }
}

extension EditWorkSpaceViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        self.imageProviders = results.map(\.itemProvider)
        
        saveImage()
    }
}
