//
//  HomeInitialViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/22/24.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

final class HomeInitialViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        let workSpaceID: Int
    }
    
    struct Output {
        let channelCell: Driver<[HomeItemModel]>
        let dmCell: Driver<[HomeItemModel]>
    }
    
    func transform(_ input: Input) -> Output {
        let cellDefaultImage = UIImage(named: "ThinTag")
        let channelCellData = PublishRelay<[HomeItemModel]>()
        let directMessageCellData = PublishRelay<[HomeItemModel]>()
        
        APIManger.shared.requestByRx(requestType: .getMyAllChannelInWorkspace(workSpaceID: input.workSpaceID), decodableType: [GetMyAllChannelResultModel].self, defaultErrorType: NetworkError.GetMyChannelError.self)
            .subscribe(with: self) { owner, result in
                switch result{
                case .success(let channels):
                    print(channels)
                    var cellData: [HomeItemModel] = []
                    for channelData in channels {
                        let newCellData = HomeItemModel(title: channelData.name, notification: 0, itemType: .cell, image: cellDefaultImage)
                        cellData.append(newCellData)
                    }
                    channelCellData.accept(cellData)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        APIManger.shared.requestByRx(requestType: .getMyAllDMInWorkspace(workspaceID: input.workSpaceID), decodableType: [GetMyDMResultModel].self, defaultErrorType: NetworkError.GetMyAllDMInWorkspaceError.self)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let resultModel):
                    print(resultModel)
                    var cellData: [HomeItemModel] = []
                    for dmCelldata in resultModel{
                        var image: UIImage?
                        if let userProfileURL = dmCelldata.user.profileImage {
                            if let imageURL = URL(string: SecretKeys.severURL+userProfileURL){
                                KingfisherManager.shared.retrieveImage(with: imageURL) { result in
                                    switch result{
                                    case .success(let imageResult):
                                        let resizeImage = imageResult.image.resizingByRenderer(size: CGSize(width: 24, height: 24), tintColor: nil)
                                        image = resizeImage
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            }
                        } else {
                            image = UIImage(named: "DefaultProfile_A")
                        }
                        let newCellData = HomeItemModel(title: dmCelldata.user.nickname, notification: 0, itemType: .cell, image: image)
                        cellData.append(newCellData)
                    }
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
            
        
        return Output(
            channelCell: channelCellData.asDriver(onErrorJustReturn: []),
            dmCell: directMessageCellData.asDriver(onErrorJustReturn: [])
        )
    }
}
