//
//  RoundedButton.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/3/24.
//

import UIKit

final class InteractionButton: UIButton {
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
        super.init(frame: .zero)
        self.setTitle(titleString, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = .BrandColor.brandGreen
        isValid = isActive
        if let imageString { self.setImage(UIImage(named: imageString), for: .normal) }
        self.layer.cornerRadius = 8
        versionSwitching()
    }
    
    func versionSwitching(){
        if #available(iOS 15.0, *){
            var config = UIButton.Configuration.filled()
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ incoming in
                var outgoing = incoming
                outgoing.font = .Custom.appTitle2
                return outgoing
            })
            config.baseForegroundColor = .white
            config.baseBackgroundColor = .BrandColor.brandGreen
            self.configuration = config
        } else {
            self.titleLabel?.font = .Custom.appTitle2
            self.titleLabel?.textColor = .white
        }
    }
    
    private func changedButtonValid() {
        if self.isValid {
            if #available(iOS 15.0, *){ self.configuration?.baseBackgroundColor = .BrandColor.brandGreen}
            else { self.backgroundColor = .BrandColor.brandGreen }}
        else {
            if #available(iOS 15.0, *) { self.configuration?.baseBackgroundColor = .BrandColor.brandInactive }
            else { self.backgroundColor = .BrandColor.brandInactive }
             }
    }
    
}
