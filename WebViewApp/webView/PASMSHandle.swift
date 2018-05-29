//
//  PASMSHandle.swift
//  wanjia2B
//
//  Created by lichao_liu on 17/1/9.
//  Copyright © 2017年 pingan. All rights reserved.
//

import UIKit
import MessageUI

class PASMSHandle: NSObject,MFMessageComposeViewControllerDelegate , UINavigationControllerDelegate{
    
    static let sharedSMSHandle = PASMSHandle()
    weak var controller:UIViewController!
    
    func sms(phoneNumber:String,controller:UIViewController){
        sms(phoneNumber: phoneNumber, content: nil,controller:controller)
    }
    
    func sms(content:String,controller:UIViewController){
        sms(phoneNumber: nil, content: content,controller:controller)
    }
    
    func sms(phoneNumber:String?,content:String?,controller:UIViewController){
        if MFMessageComposeViewController.canSendText(){
            self.controller = controller
            let pickerController = MFMessageComposeViewController()
            pickerController.messageComposeDelegate = self
            if let phone = phoneNumber {
                pickerController.recipients = [PATELHandle.cleanPhoneNumber(mobile: phone)]
            }
            if let content = content {
                pickerController.body = content
            }
            controller.present(pickerController, animated: true, completion: nil)
        }else{
            let alert = UIAlertView.init(title: "提示", message: "你的设备不支持发短信", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult){
        if result == .failed{
            let alert = UIAlertView.init(title: "提示", message: "短信发送失败", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
