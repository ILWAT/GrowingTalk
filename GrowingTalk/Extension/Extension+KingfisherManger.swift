//
//  Extension+KingfisherManger.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/30/24.
//

import UIKit
import Kingfisher

extension KingfisherManager {
    func getImagesWithDownsampling(pathURL: String, completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?) {
        
        let downSamplingProcessor = DownsamplingImageProcessor(size: CGSize(width: 30, height: 30))
        
        let modifier = AnyModifier { request in
            var r = request
            r.addValue(UserDefaultsManager.shared.obtainTokenFromUserDefaults(tokenCase: .accessToken), forHTTPHeaderField: "Authorization")
            r.addValue(SecretKeys.serverSecretKey, forHTTPHeaderField: "SesacKey")
            return r
        }
        
        let kingfisherOptions: KingfisherOptionsInfo = [.processor(downSamplingProcessor), .cacheOriginalImage, .requestModifier(modifier)]
        

        let imageURLString = SecretKeys.severURL_V1+pathURL
        
        guard let imageURL = URL(string: imageURLString) else { return }
        
        let resource = KF.ImageResource(downloadURL: imageURL, cacheKey: imageURLString)
        
        retrieveImage(with: resource, options: kingfisherOptions, completionHandler: completionHandler)
    }
}
