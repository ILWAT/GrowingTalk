//
//  SearchChannelViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/17/24.
//

import UIKit
import RxCocoa
import RxSwift
import Then

final class SearchChannelViewController: BaseViewController {
    //MARK: - UI Properties
    private let closedButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil).then { item in
        item.tintColor = .label
    }
    
    private let requestCompletionEvent: BehaviorRelay<Void>
    
    private let tableView = UITableView(frame: .zero).then { view in
        view.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
    }
    
    //MARK: - Properties
    private let workspaceID: Int
    
    private let viewModel = SearchChannelViewModel()

    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    init(workspaceID: Int, completionEvent: BehaviorRelay<Void>) {
        self.workspaceID = workspaceID
        self.requestCompletionEvent = completionEvent
        super.init(nibName: nil, bundle: nil)
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
        navigationAppearance.backgroundColor = .white
        self.navigationItem.scrollEdgeAppearance = navigationAppearance
        self.navigationItem.title = "채널 탐색"
        self.navigationItem.setLeftBarButtonItems([closedButton], animated: true)
    }
    
    override func bind() {
//        let presentingChattingVC = PublishRelay<ChannelModel>()
        let nextVCEvent = PublishSubject<Void>()
        
        let input = SearchChannelViewModel.Input(
            closedButtonTap: closedButton.rx.tap,
            workspaceID: workspaceID,
            selectedChannel: tableView.rx.modelSelected(ChannelModel.self)
        )
        
        let output = viewModel.transform(input)
        
        output.allChannelInWorkspace
            .drive(tableView.rx.items) { (tableView, row, element) in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description()) else { return UITableViewCell() }
                var cellConfig = cell.defaultContentConfiguration()
                cellConfig.text = element.name
                cellConfig.textProperties.font = .Custom.appTitle2 ?? cellConfig.textProperties.font
                cellConfig.image = UIImage(named: "ThickTag")
                cell.contentConfiguration = cellConfig
                return cell
            }
            .disposed(by: disposeBag)
        
        output.closedButtonTap
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        
        output.isUserParticipated
            .drive(with: self) { owner, combineValue in
                if combineValue.1 {
                    let alert = CustomAlertViewController(popUpTitle: "채널 참여", popUpBody: "[\(combineValue.0.name)] 채널에 참여하시겠습니까?", colorButtonTitle: "확인", cancelButtonTitle: "취소")
                    alert.transform(okObservable: nextVCEvent)
                    owner.present(alert, animated: true)
                    print("ChannelJoin 뷰 전환")
                } else {
                    nextVCEvent.onNext(())
                }
            }
            .disposed(by: disposeBag)
        
        nextVCEvent
            .withLatestFrom(output.isUserParticipated)
            .subscribe(with: self) { owner, combineValue in
                print("다음페이지 띄우기", combineValue.0)
            }
            .disposed(by: disposeBag)
        
    }
    
    //MARK: - UI Method
    override func configureViewHierarchy() {
        super.configureViewHierarchy()
        self.view.addSubview(tableView)
    }
    
    override func configureViewConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    //MARK: - Helper
}
