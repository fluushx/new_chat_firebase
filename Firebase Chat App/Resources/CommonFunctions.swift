//
//  CommonFunctions.swift
//  Firebase Chat App
//
//  Created by Rahul Dhiman on 26/01/22.
//

import UIKit
import CryptoKit

class CommonFunctions: NSObject {
    
    static let sharedInstance = CommonFunctions()
    
    func MD5(string: String) -> String {
        guard let data = string.data(using: .utf8) else { return string }
        let digest = Insecure.MD5.hash(data: data)
        
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
}
