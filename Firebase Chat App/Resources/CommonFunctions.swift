//
//  CommonFunctions.swift
//  Firebase Chat App
//
//  Created by Rahul Dhiman on 26/01/22.
//

import UIKit
import CryptoKit
import Alamofire

class CommonFunctions: NSObject {
    
    static let sharedInstance = CommonFunctions()
    
    func MD5(string: String) -> String {
        guard let data = string.data(using: .utf8) else { return string }
        let digest = Insecure.MD5.hash(data: data)
        
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
    func sendMessagePush(toDeviceToken: String, title: String, message: String, url: String? = nil) {
        
        let notificationObject : [String : Any] = [
            "title": title,
            "body": message,
            "mutable_content": true,
            "sound": "Tri-tone"
        ]
        
        var dataObject : [String : Any] = [
            "user_email" : UserDefaults.standard.value(forKey: "email") as? String ?? "N/A"
        ]
        
        if let url = url {
            dataObject["image"] = url
        }
        
        let parameters : [String : Any] = [
            "to" : toDeviceToken,
            "priority": "high",
            "content_available": true,
            "notification": notificationObject,
            "data" : dataObject
        ]
        
        let headersObject : [String : String] = [
            "Content-Type": "application/json",
            "Authorization": "key=AAAAeMVrWxU:APA91bGlG3ww-HAErTVoNH5MqbCU4J6ayqTK1W_XekQ2q0PzD2n098stRV1hVDiEqpQRCcPu0daK6w-8geikwmw2TMiSN4rr5iSRoa1MFGWfie7WW9nqfEZazxR4i8uBYglFId5-db0h"
        ]
        
        print("FCM PUSH PARAMS ---->>")
        print(parameters)
        
        AF.request("https://fcm.googleapis.com/fcm/send", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders(headersObject))
            .responseJSON { response in
                print("FCM MESSAGE PUSH RESPONSE -->>")
                print(response)
            }
        
    }
}
