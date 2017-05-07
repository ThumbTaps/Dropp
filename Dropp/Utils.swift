//
//  Utils.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 5/3/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit


class Utils: NSObject {
 
	public dynamic class func scaleImage(_ image: UIImage, to size: CGSize) -> UIImage? {

		guard let cgImage = image.cgImage else {
			return nil
		}
		
		let aspectRatio = CGFloat(max(cgImage.width, cgImage.height) / min(cgImage.width, cgImage.height))
		let width = CGFloat(max(size.width, size.height) / aspectRatio) * UIScreen.main.scale
		let height = CGFloat(min(size.width, size.height) * aspectRatio) * UIScreen.main.scale
		let bitsPerComponent = cgImage.bitsPerComponent
		let bytesPerRow = 0
		guard let colorSpace = cgImage.colorSpace else {
			return nil
		}
		let bitmapInfo = cgImage.bitmapInfo
		
		guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
			return nil
		}
		
		context.interpolationQuality = .high
		
		context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: CGFloat(width), height: CGFloat(height))))
		
		let scaledImage = context.makeImage().flatMap { UIImage(cgImage: $0) }
		
		return scaledImage
	}}
