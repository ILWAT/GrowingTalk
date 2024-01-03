//
//  RoundedButton.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/3/24.
//

import UIKit

final class InteactionButton: UIButton {
    var isValid: Bool = true{
        didSet{
            changedButtonValid()
        }
    }
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("cannot init using coder")
    }
    
    init(titleString: String, imageString: String? = nil, isActive: Bool = true){
        self.setTitle(titleString, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = .BrandColor.brandGreen
        isValid = isActive
    }
    
    func versionSwitching(image: String){
        if #available(iOS 15.0, *){
            var config = UIButton.Configuration.filled()
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ incoming in
                var outgoing = incoming
                outgoing.font = .Custom.appTitle2
            })
        } else {
            self.titleLabel?.font = .Custom.appTitle2
        }
    }
    
    private func changedButtonValid() {
        if self.isValid { self.backgroundColor = .BrandColor.brandGreen }
        else { self.backgroundColor = .BrandColor.brandInactive }
    }
    
}
