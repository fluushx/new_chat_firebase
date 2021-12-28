//
//  ConversationTableViewCell.swift
//  Firebase Chat App
//
//  Created by Felipe Ignacio Zapata Riffo on 03-12-21.
//

import UIKit
import SDWebImage


class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"

    private let userImageView : UIImageView = {
        let imageView = UIImageView()
         imageView.contentMode = .scaleAspectFill
         imageView.layer.masksToBounds = true
         imageView.layer.cornerRadius = 50
         imageView.layer.borderColor = UIColor.white.cgColor
         imageView.layer.borderWidth =  3
//         imageView.backgroundColor = .white
        return imageView
    }()
    private let userNameLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize:21,weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userMessageLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize:19,weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userImageView)
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
      
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure (with model:Conversation){
        self.userMessageLabel.text = model.lastedMessage.text
        self.userNameLabel.text = model.name
        
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
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
