//
//  NJKWebViewProgressView+Extension.swift
//  wanjia2B
//
//  Created by lichao_liu on 17/4/1.
//  Copyright © 2017年 pingan. All rights reserved.
//

import NJKWebViewProgress
extension NJKWebViewProgressView {
    func setProgress(progress:CGFloat,animated:Bool,completion:((Bool)->Void)?){
        let isGrowing = progress > 0
        UIView.animate(withDuration: (isGrowing && animated) ? self.barAnimationDuration : 0.0, delay: 0, options: .curveLinear, animations: {
            var frame = self.progressBarView.frame
            frame.size.width = progress * self.bounds.size.width
            self.progressBarView.frame = frame
        }, completion: completion)
        
        if progress >= 1.0{
            UIView.animate(withDuration: animated ? self.fadeAnimationDuration : 0, delay: self.fadeOutDelay, options: .curveEaseInOut, animations: {
                 self.progressBarView.alpha = 0
            }, completion: { completed in
                 var frame = self.progressBarView.frame
                frame.size.width = 0
                self.progressBarView.frame = frame
            })
        }else{
            UIView.animate(withDuration: animated ? self.fadeAnimationDuration : 0, delay: 0, options: .curveEaseInOut, animations: { 
                self.progressBarView.alpha = 1
            }, completion: nil)
        }
    }
}
