//
//  PAKWebViewProgressView.swift
//  WebViewApp
//
//  Created by lichao_liu on 2018/5/31.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit

class PAKWebViewProgressView: UIView {
 
    var progress:CGFloat = 0{
        didSet{
            setProgress(progress: progress, animated: false)
        }
    }
    var progressBarView:UIView!
    var barAnimationDuration:TimeInterval = 0.27
    var fadeAnimationDuration:TimeInterval = 0.27
    var fadeOutDelay:TimeInterval = 0.1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureViews() {
        isUserInteractionEnabled = false
        autoresizingMask = .flexibleWidth
        progressBarView = UIView(frame: self.bounds)
        progressBarView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        progressBarView.backgroundColor = UIColor.orange
        addSubview(progressBarView)
    }

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
    
    func setProgress(progress:CGFloat,animated:Bool) {
        let isGrowing = progress > 0.0
        UIView.animate(withDuration: (isGrowing && animated) ? barAnimationDuration : 0, delay: 0, options: .curveEaseInOut, animations: {
            var frame = self.progressBarView.frame
            frame.size.width = self.progress * self.bounds.size.width
            self.progressBarView.frame = frame
        }, completion: nil)
        
        if progress > 1 {
            UIView.animate(withDuration: animated ? fadeAnimationDuration : 0.0, delay: fadeOutDelay, options: .curveEaseInOut, animations: {
                self.progressBarView.alpha = 0
            }, completion: { _ in
                var frame = self.progressBarView.frame
                frame.size.width = 0
                self.progressBarView.frame = frame
            })
        }else {
            UIView.animate(withDuration: animated ? fadeAnimationDuration : 0, delay: 0, options: .curveEaseInOut, animations: {
                self.progressBarView.alpha = 1
            }, completion: nil)
        }
    }
}
