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
    
   
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
      
        
        
       
    }
    
    func setUpView(){
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
 
        
        userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        userImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -250).isActive = true
        userImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        
        userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 30).isActive = true
        userNameLabel.leadingAnchor.constraint(equalTo: userImageView.leadingAnchor, constant: 120).isActive = true
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
