//
//  HomeConversationsTableViewCell.swift
//  Firebase Chat App
//
//  Created by Rahul Dhiman on 20/03/22.
//

import UIKit

class HomeConversationsTableViewCell: UITableViewCell {
    
    static let identifier = "HomeConversationsTableViewCell"

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLastMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        setupView()
    }
    
    private func setupView() {
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        userImageView.layer.borderColor = UIColor.lightGray.cgColor
        userImageView.layer.borderWidth = 1
        
        userName.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        userLastMessage.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    }
    
    public func configure(with model:Conversation) {
        userLastMessage.text = model.lastedMessage.text
        userName.text = model.name
        
        
        let path = "images\(model.otherUserEmail)_profile_picture.png"
        print("path: \(path)")
        storageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to get image \(error)")
            }
        })
        
    }

}
