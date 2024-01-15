//
//  WorkSpaceAddViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/14/24.
//

import UIKit
import PhotosUI
import RxCocoa
import RxSwift
import Then

final class WorkSpaceAddViewController: BaseViewController {
    //MARK: - UIProperties
    private let closeButton = UIBarButtonItem().then { item in
        item.tintColor = .label
        item.image = UIImage(systemName: "xmark")
    }
    
    private let workSpaceImage = UIButton().then { view in
        view.setImage(UIImage(named: "WorkSpace")?.resizingByRenderer(size: CGSize(width: 50, height: 60)), for: .normal)
        view.backgroundColor = .BrandColor.brandGreen
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
    }
    
    private let imgAddButton = UIButton().then { item in
        item.tintColor = .white
        item.backgroundColor = .BrandColor.brandGreen
        item.layer.borderWidth = 3
        item.layer.borderColor = UIColor.white.cgColor
        let image = UIImage(systemName: "camera.fill")?.resizingByRenderer(size: CGSize(width: 12, height:12))
        item.setImage(image, for: .normal)
        item.clipsToBounds = true
    }
    
    private let spaceNameLabelField = LabelTextField(labelString: "워크스페이스 이름", textFieldPlaceHolder: "워크스페이스 이름을 입력하세요 (필수)")
    
    private let spaceDiscription = LabelTextField(labelString: "워크 스페이스 설명", textFieldPlaceHolder: "워크스페이스를 설명하세요 (옵션)")
    
    private let completeButton = InteractionButton(titleString: "완료", isActive: false)
    
    private var imageProviders: [NSItemProvider] = []
    
    //MARK: - Properties
    private let viewModel = WorkSpaceAddViewModel()
    
    private let spaceImage = PublishRelay<UIImage?>()
    
    private let disposeBag = DisposeBag()
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
        let input = WorkSpaceAddViewModel.Input(
            closeButtonTap: closeButton.rx.tap,
            imgButtonTap: workSpaceImage.rx.tap,
            imgAddButtonTap: imgAddButton.rx.tap,
            spaceNameText: spaceNameLabelField.textField.rx.text.orEmpty,
            spaceDiscriptionText: spaceDiscription.textField.rx.text.orEmpty,
            spaceImage: spaceImage
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


extension WorkSpaceAddViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        self.imageProviders = results.map(\.itemProvider)
        
        saveImage()
    }
    

}
