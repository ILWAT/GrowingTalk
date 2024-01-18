//
//  Extension+Kingfisher.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/18/24.
//

import UIKit
import Kingfisher

extension KingfisherWrapper where Base: UIImageView {
    func setImageWithHeader(
        with: Resource?,
        placeholder: Placeholder? = nil,
        options: KingfisherOptionsInfo? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
    ) {
        let modifier = AnyModifier { request in
            var r = request
            r.addValue(UserDefaultsManager.shared.obtainTokenFromUserDefaults(tokenCase: .accessToken), forHTTPHeaderField: "AccessToken")
            r.addValue(SecretKeys.serverSecretKey, forHTTPHeaderField: "Authorization")
            return r
        }
        
        var newOptions = options ?? []
        newOptions.append(.requestModifier(modifier))
        
        self.setImage(with: with, placeholder: placeholder, options: newOptions, completionHandler: completionHandler)
    }
}
