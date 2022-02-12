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
         imageView.translatesAutoresizingMaskIntoConstraints = false
         imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    let containerImage : UIView = {
        let containerImage = UIView()
        containerImage.translatesAutoresizingMaskIntoConstraints = false
        containerImage.layer.borderWidth =  7
        containerImage.layer.masksToBounds = true
        return containerImage
    }()
    
    
    private let userNameLabel: UILabel = {
       let label = UILabel()
//        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize:21,weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userMessageLabel: UILabel = {
       let label = UILabel()
//        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize:19,weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
       
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
      
        
        
       
    }
    
    func setUpView(){
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
        contentView.addSubview(containerImage)
        containerImage.addSubview(userImageView)

        containerImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        containerImage.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        containerImage.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -250).isActive = true
        containerImage.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        containerImage.layer.cornerRadius = containerImage.frame.height/2.5
         
        userImageView.topAnchor.constraint(equalTo: containerImage.topAnchor, constant: 5).isActive = true
        userImageView.leadingAnchor.constraint(equalTo: containerImage.leadingAnchor, constant: 1).isActive = true
        userImageView.trailingAnchor.constraint(equalTo: containerImage.trailingAnchor, constant: -1).isActive = true
        userImageView.bottomAnchor.constraint(equalTo: containerImage.bottomAnchor, constant: -5).isActive = true
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        
        userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 10).isActive = true
        userNameLabel.leadingAnchor.constraint(equalTo: containerImage.leadingAnchor, constant: 150).isActive = true
        userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        userNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50).isActive = true
        
        userMessageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10).isActive = true
        userMessageLabel.leadingAnchor.constraint(equalTo: containerImage.trailingAnchor, constant: 30).isActive = true
    
            
        }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpView()
      
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure (with model:Conversation){
        userMessageLabel.text = model.lastedMessage.text
        userNameLabel.text = model.name
        
        
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
