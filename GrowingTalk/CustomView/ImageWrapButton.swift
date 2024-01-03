//
//  ImageWrapButton.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/3/24.
//

import UIKit

final class ImageWrapButton: UIButton{
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("cannot making view with coder")
    }
    
    init(imageString: String){
        super.init(frame: .zero)
        self.setBackgroundImage(UIImage(named: imageString), for: .normal)
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
}
