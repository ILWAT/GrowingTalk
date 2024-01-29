//
//  Extension+UIImage.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/14/24.
//

import UIKit

extension UIImage {
    func resizingByRenderer(size: CGSize, tintColor: UIColor?) -> UIImage {
        let render = UIGraphicsImageRenderer(size: size)
        let newImage = render.image { context in
            draw(in: CGRect(origin: .zero, size: CGSize(width: render.format.bounds.width, height: render.format.bounds.height)))
        }
        guard let wrapColor = tintColor else { return newImage }
        let newImageWithTintColor = newImage.withTintColor(wrapColor)
        
        return newImageWithTintColor
    }
    
    func compressionUnderMBjpegData(megabyteSize: Int) -> Data?{
        let targetMegabyte = megabyteSize*1024*1024
        var compressionValue: CGFloat = 1
        guard var compressedImageDataResult = self.jpegData(compressionQuality: compressionValue) else { return nil }
        
        while compressedImageDataResult.count > targetMegabyte {
            compressionValue /= 2
            guard let compressedImageData = self.jpegData(compressionQuality: compressionValue) else { return nil }
            compressedImageDataResult = compressedImageData
        }
        return compressedImageDataResult
    }
}
