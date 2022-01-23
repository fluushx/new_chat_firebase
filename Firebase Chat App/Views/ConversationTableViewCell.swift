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
         imageView.layer.borderColor = UIColor.white.cgColor
         imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    private let userNameLabel: UILabel = {
       let label = UILabel()
//        label.textAlignment = .center
        label.font = .systemFont(ofSize:21,weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userMessageLabel: UILabel = {
       let label = UILabel()
//        label.textAlignment = .center
    
        label.font = .systemFont(ofSize:19,weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
       
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
      
        
        
       
    }
    
    func setUpView(){
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
            
        userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        userImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -250).isActive = true
        userImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        userImageView.layer.cornerRadius = userImageView.frame.height/2.5
        
        userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 10).isActive = true
        userNameLabel.leadingAnchor.constraint(equalTo: userImageView.leadingAnchor, constant: 140).isActive = true
        userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        userNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50).isActive = true
        
        userMessageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10).isActive = true
        userMessageLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 32).isActive = true
        userMessageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        userMessageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
            
        }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpView()
      
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure (with model:Conversation){
        self.userMessageLabel.text = model.lastedMessage.text
        self.userNameLabel.text = model.name
        
        
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
