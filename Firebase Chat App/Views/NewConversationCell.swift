//
//  NewConversationCell.swift
//  Firebase Chat App
//
//  Created by MAC-DESMOBILE on 18-01-22.
//

import Foundation

import UIKit
import SDWebImage


class NewConversationCell: UITableViewCell {
    
    static let identifier = "NewConversationCell"

    private let userImageView : UIImageView = {
        let imageView = UIImageView()
         imageView.contentMode = .scaleAspectFill
         imageView.layer.masksToBounds = true
          
         imageView.layer.borderColor = UIColor.white.cgColor
         imageView.translatesAutoresizingMaskIntoConstraints = false
//         imageView.backgroundColor = .red
        return imageView
    }()
    private let userNameLabel: UILabel = {
       let label = UILabel()
//        label.textAlignment = .center
        label.font = .systemFont(ofSize:21,weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.backgroundColor = .red
        return label
    }()
    
    let containerImage : UIView = {
        let containerImage = UIView()
        containerImage.translatesAutoresizingMaskIntoConstraints = false
        containerImage.layer.borderWidth =  7
        containerImage.layer.masksToBounds = true
        return containerImage
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
       
    }
    
    func setUpView(){
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
 
        
        contentView.addSubview(containerImage)
        containerImage.addSubview(userImageView)

        containerImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        containerImage.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        containerImage.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -250).isActive = true
        containerImage.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        containerImage.layer.cornerRadius = containerImage.frame.height/2.5
      
         
        userImageView.topAnchor.constraint(equalTo: containerImage.topAnchor, constant: 1).isActive = true
        userImageView.leadingAnchor.constraint(equalTo: containerImage.leadingAnchor, constant: 1).isActive = true
        userImageView.trailingAnchor.constraint(equalTo: containerImage.trailingAnchor, constant: -1).isActive = true
        userImageView.bottomAnchor.constraint(equalTo: containerImage.bottomAnchor, constant: -1).isActive = true
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        
        userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 30).isActive = true
        userNameLabel.leadingAnchor.constraint(equalTo: containerImage.leadingAnchor, constant: 170).isActive = true
        userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        userNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
            
        }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpView()
      
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure (with model:SearchResult){
        self.userNameLabel.text = model.name
        
        
        let path = "images\(model.email)_profile_picture.png"
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
