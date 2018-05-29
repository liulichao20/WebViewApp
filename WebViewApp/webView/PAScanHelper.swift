//
//  PAScanHelper.swift
//  WebViewApp
//
//  Created by lichao_liu on 2018/5/29.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit

class PAScanHelper {
    //识别图片二维码
    class func scanQRImage(image:UIImage)->String? {
        var result:String?
        let context = CIContext()
        let detector:CIDetector? = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        if let ciImage = image.ciImage,let detector = detector {
            let features = detector.features(in: ciImage)
            if !features.isEmpty {
                for feature in features {
                    if feature .isKind(of: CIQRCodeFeature.self) {
                        result = (feature as! CIQRCodeFeature).messageString
                        break
                    }
                }
            }
        }
        return result
    }
}
