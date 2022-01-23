//
//  ProfileViewController.swift
//  Firebase Chat App
//
//  Created by Felipe Ignacio Zapata Riffo on 06-09-21.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}

class ProfileViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var data = [ProfileViewModel]()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ProfileTableViewCell.self,
                                   forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        data.append(ProfileViewModel(viewModelType: .info,
                                             title: "Name: \(UserDefaults.standard.value(forKey:"name") as? String ?? "No Name")",
                                             handler: nil))
        data.append(ProfileViewModel(viewModelType: .info,
                                             title: "Email: \(UserDefaults.standard.value(forKey:"email") as? String ?? "No Email")",
                                             handler: nil))
        data.append(ProfileViewModel(viewModelType: .info,
                                             title: "Log Out",
                                             handler: { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            let actionSheet = UIAlertController(title: "Are you sure?",
                                          message: "Log out",
                                          preferredStyle: .alert)
            actionSheet.addAction(UIAlertAction(title: "Log Out",
                                          style: .destructive,
                                          handler: { [weak self] _ in
                                            guard let strongSelf = self else {
                                                return
                                            }
                
                UserDefaults.standard.set(nil, forKey: "email")
                UserDefaults.standard.set(nil, forKey: "name")
                                            FBSDKLoginKit.LoginManager().logOut()
                                            
                                            GIDSignIn.sharedInstance.signOut()
                                            
                                            do {
                                                try FirebaseAuth.Auth.auth().signOut()
                                                let vc = LoginViewController()
                                                let nav = UINavigationController(rootViewController: vc)
                                                nav.modalPresentationStyle = .fullScreen
                                                strongSelf.present(nav, animated: false)
                                            }
                                            catch {
                                                print("Failed to Log out")
                                            }
                                            
                                          }))
            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
            strongSelf.present(actionSheet, animated: true)
        }))
        setUpTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    func createTableHeader()->UIView{
        
        let headerView : UIView = {
            let headerView = UIView()
            headerView.backgroundColor = UIColor(red: 51/255.0, green: 138/255.0, blue: 255/255.0, alpha: 1.0)
            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 200)
            headerView.layer.borderColor = UIColor.white.cgColor
            headerView.layer.borderWidth =  3
            headerView.layer.masksToBounds = true
            
            return headerView
        }()
        
        let imageView: UIImageView = {
           let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 75
            imageView.layer.borderColor = UIColor.white.cgColor
            imageView.layer.borderWidth =  3
            imageView.frame = CGRect(x: (headerView.frame.width - 150) / 2,
                                     y: 20,
                                     width: 150,
                                     height: 150)
            imageView.backgroundColor = .white
            return imageView
        }()
        
        headerView.addSubview(imageView)
//        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
//            return headerView
//                }
        
         let email = UserDefaults.standard.value(forKey: "email") as? String
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email ?? "no mail")
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images"+fileName
        print(path)
        
        
        storageManager.shared.downloadURL(for: path, completion: { result in
                    switch result {
                    case .success(let url):
                        imageView.sd_setImage(with: url, completed: nil)
                    case .failure(let error):
                        print("Failed to get download url: \(error)")
                    }
                })
        return headerView
    }
    func setUpTableView(){
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
     
}
extension ProfileViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
         
         
    }
    
}
class ProfileTableViewCell: UITableViewCell {

    static let identifier = "ProfileTableViewCell"

    public func setUp(with viewModel: ProfileViewModel) {
        self.textLabel?.text = viewModel.title
        switch viewModel.viewModelType {
        case .info:
            textLabel?.textAlignment = .left
            selectionStyle = .none
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
        }
    }

}
