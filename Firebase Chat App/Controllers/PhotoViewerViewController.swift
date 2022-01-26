//
//  PhotoViewerViewController.swift
//  Firebase Chat App
//
//  Created by Felipe Ignacio Zapata Riffo on 06-09-21.
//

import UIKit

class PhotoViewerViewController: UIViewController {
    
    private let url: URL

    
    private let imageView: UIImageView = {
     let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    init(with url:URL){
        self.url = url
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo"
         
        navigationItem.largeTitleDisplayMode = .never
        view.addSubview(imageView)
        imageView.sd_setImage(with: self.url, completed: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
}
