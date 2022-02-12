//
//  LoginViewController.swift
//  Firebase Chat App
//
//  Created by Felipe Ignacio Zapata Riffo on 06-09-21.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import Firebase
import JGProgressHUD
import CryptoKit

class LoginViewController: UIViewController {
    
    private let signInConfig = GIDConfiguration.init(clientID: "615508120088-b20etkckkp7above483ajrj854eo629i.apps.googleusercontent.com")
    
    
    private let spinner = JGProgressHUD(style: .dark)
    
//    private let logoImageView: UIImageView = {
//        let logoImageView = UIImageView()
//        logoImageView.contentMode = .scaleAspectFit
//        logoImageView.translatesAutoresizingMaskIntoConstraints = false
//        logoImageView.image = UIImage(named: "logo")
//
//
//        return logoImageView
//    }()
    
    //MARK: mailTextField
    private let mailTextField : UITextField = {
        let mailTextField = UITextField()
      
        mailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        mailTextField.translatesAutoresizingMaskIntoConstraints = false
        mailTextField.autocapitalizationType = .none
        mailTextField.attributedPlaceholder = NSAttributedString(
            string: "Type Your Mail",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        mailTextField.layer.cornerRadius = 10
        mailTextField.layer.masksToBounds = true
        mailTextField.font = .systemFont(ofSize: 15)
        mailTextField.leftViewMode = .always
        mailTextField.layer.shadowRadius = 3
        mailTextField.layer.borderWidth = 0.5
        mailTextField.layer.borderColor = UIColor.black.cgColor
        mailTextField.autocorrectionType = .no
        mailTextField.textColor = .white
        return mailTextField
    }()
    
    //MARK: passwordTextField
    private let passwordTextField : UITextField = {
        let passwordTextField = UITextField()
 
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.autocapitalizationType = .none
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Type Your Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.layer.masksToBounds = true
        passwordTextField.font = .systemFont(ofSize: 15)
        passwordTextField.leftViewMode = .always
        passwordTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderColor = UIColor.black.cgColor
        passwordTextField.returnKeyType = .done
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.textColor = .white
        return passwordTextField
    }()
    
    //MARK: loginButton
    private let loginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.setTitle("Login", for: .normal)
        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.layer.shadowRadius = 3
        loginButton.layer.borderWidth = 5
        loginButton.backgroundColor = UIColor(red: 160 / 255.0, green: 170 / 255.0, blue: 200 / 255.0, alpha: 1.0)
        loginButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        return loginButton
    }()
    private let facebokButton : FBLoginButton = {
        let facebokButton = FBLoginButton()
        facebokButton.layer.cornerRadius = 12
        facebokButton.layer.cornerRadius = 12
        facebokButton.layer.shadowColor = UIColor.lightGray.cgColor
        facebokButton.layer.shadowOffset = CGSize(width:3, height:3)
        facebokButton.layer.shadowOpacity = 3
        facebokButton.layer.shadowRadius = 3
        facebokButton.layer.borderColor = UIColor.black.cgColor
        facebokButton.addTarget(self, action: #selector(didTapButtonFB), for: .touchUpInside)
        facebokButton.permissions = ["email","public_profile"]
        facebokButton.translatesAutoresizingMaskIntoConstraints = false
        return facebokButton
    }()
    
    
    //MARK: containerView
    private let containerView : UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12

        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.backgroundColor = .black
        return containerView
    }()
    
    //MARK: containerGoogleLogin
    private let googleButton : GIDSignInButton = {
        let googleButton = GIDSignInButton()
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        googleButton.layer.cornerRadius = 12
        googleButton.layer.cornerRadius = 12
        googleButton.layer.shadowColor = UIColor.lightGray.cgColor
        googleButton.layer.shadowOffset = CGSize(width:3, height:3)
        googleButton.layer.shadowOpacity = 3
        googleButton.layer.shadowRadius = 3
        googleButton.layer.borderColor = UIColor.black.cgColor
        googleButton.addTarget(self, action: #selector(didTapButtonGoogle), for: .touchUpInside)
        return googleButton
    }()
    
    
    //------------------------------------new-------
    
    
    let bgImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "screen")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let logoImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0.8
        imageView.image = UIImage(named: "anonymus")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let bgView : UIView = {
        let bgView = UIView()
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = UIColor(displayP3Red: 9.0/255.0, green: 33.0/255.0, blue: 47.0/255.0, alpha: 1.0).withAlphaComponent(0.7)
        return bgView
    }()
    
    let imgView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let lineView : UIView = {
        let bgView = UIView()
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = UIColor.white
        return bgView
    }()
    
    
    private var loginObserve : NSObjectProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
 //        setUpView()
        setUpRightBarButton()
//        setUpConstraints()
        addingUIElements()
        mailTextField.delegate = self
        passwordTextField.delegate = self
        logoImageView.isUserInteractionEnabled = true
        containerView.isUserInteractionEnabled =  true
        facebokButton.delegate = self
        _ = NotificationCenter.default.addObserver(forName: .didLogInNotification,
                                                   object: nil,
                                                   queue: .main,
                                                   using: { [weak self] _ in
                                                    guard let strongSelf = self else {
                                                        return
                                                    }
                                                    strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                                                   })
        
        
    }
    deinit {
        if loginObserve != nil {
            NotificationCenter.default.removeObserver(loginObserve!)
        }
    }
    @objc func didTapRegisterButton(){
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: didTapButtonGoogle
    @objc func didTapButtonGoogle (){ 
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                // ...
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            spinner.show(in: view)
            guard let user = user else {
                return
            }
            
            print("Did Sign in with user \(user)")
            guard let email = user.profile?.email,
                  let firstName = user.profile?.givenName,
                  let lastName = user.profile?.familyName else {
                print("Fail to get first, last name and email from goole")
                return
            }
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            
            UserDefaults.standard.setValue(email, forKey: "email")
            UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")

            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: lastName,
                                               mail: email)
                    DatabaseManager.shared.insertUser(with: chatUser,completion: { success in
                        if success {
                            if user.profile?.hasImage != nil{
                                guard let url = user.profile?.imageURL(withDimension: 200) else {
                                    return
                                }
                                URLSession.shared.dataTask(with: url, completionHandler: { data,_,_ in
                                    guard let data = data else {
                                        return
                                    }
                                    let fileName = chatUser.profilePictureFileName
                                    storageManager.shared.uploadProfilePicture(with: data,
                                                                               fileName: fileName,
                                                                               completion: { results in
                                                                                
                                                                                switch results {
                                                                                case .success(let downloadURL):
                                                                                    UserDefaults.standard.setValue(downloadURL, forKey: "profile_picture_url")
                                                                                    print(downloadURL)
                                                                                case .failure(let error):
                                                                                    print("storage manager error: \(error)")
                                                                                }
                                                                                
                                                                               })
                                }).resume()
                                
                            }
                            
                        
                        }
                        
                    })
                }
                
            })
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    print("failed to log in with google credential")
                    return
                }
                print("Successfully sign in with google cred.")
                NotificationCenter.default.post(name: .didLogInNotification, object: nil)
                
            })
            
        }
    }
    //MARK: didTapLoginButton
    @objc private func didTapLoginButton(){
        self.view.endEditing(true)
        guard let mail = mailTextField.text, let password = passwordTextField.text,
              !mail.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        let hashedPassoword = CommonFunctions.sharedInstance.MD5(string: password)
        
        spinner.show(in: view)
        
        //Log in firebase
        FirebaseAuth.Auth.auth().signIn(withEmail: mail, password: hashedPassoword, completion: {
            [weak self] authResult, error in
            guard let strongSelf = self else {
                
                return
            }
            DispatchQueue.main.async {
                self!.spinner.dismiss()
            }
            guard let result = authResult, error == nil else {
                let alert = UIAlertController(title: "Woops",
                                              message: "Incorrect Password o Email",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss",
                                              style: .cancel,
                                              handler: nil))
                self!.present(alert, animated: true)
                return
            }
            let user = result.user
            print(" Log in User: \(user)")
            let safeEmail = DatabaseManager.safeEmail(emailAddress: mail)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                            switch result {
                            case .success(let data):
                                guard let userData = data as? [String: Any],
                                    let firstName = userData["first_name"] as? String,
                                    let lastName = userData["last_name"] as? String else {
                                        return
                                }
                                UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")

                            case .failure(let error):
                                print("Failed to read data with error \(error)")
                            }
                        })
            UserDefaults.standard.setValue(mail, forKey: "email")
             
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
            
            
        })
        
    }
    
    @objc private func didTapButtonFB(){
        
    }
    
  
    func alertUserLoginError(message:String = "Please enter information to log in"){
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
        
    }
    
    func setUpRightBarButton (){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegisterButton))
    }
    
    
    
//    func setUpView(){
//        view.addSubview(logoImageView)
//        view.addSubview(containerView)
//        containerView.addSubview(mailTextField)
//        containerView.addSubview(passwordTextField)
//        view.addSubview(loginButton)
//        view.addSubview(facebokButton)
//        view.addSubview(googleButton)
//
//    }
    
    
    func setUpConstraints(){
        
        //MARK:- imageLoginCenter
        logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 135).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        //MARK:- containerView
        containerView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        //MARK:- mailTextField
        mailTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15).isActive = true
        mailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        mailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        mailTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //MARK:- passwordTextField
        passwordTextField.topAnchor.constraint(equalTo: mailTextField.bottomAnchor, constant: 15).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //MARK:- loginButton
        loginButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        //MARK:- facebookButton
        facebokButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10).isActive = true
        facebokButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        facebokButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        //MARK:- googleButton
        googleButton.topAnchor.constraint(equalTo: facebokButton.bottomAnchor, constant: 10).isActive = true
        googleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        googleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    }
    
    //----------new-------
    func addingUIElements() {
        let padding: CGFloat = 40.0
        let signInButtonHeight: CGFloat = 50.0
        let textFieldViewHeight: CGFloat = 60.0
        
        // Background imageview
        self.view.addSubview(bgImageView)
        bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        bgImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        
        // Background layer view
        view.insertSubview(bgView, aboveSubview: bgImageView)
        bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        bgView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        
        // Logo at top
        view.insertSubview(logoImageView, aboveSubview: bgView)
        logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60.0).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0).isActive = true
        logoImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4).isActive = true
        logoImageView.widthAnchor.constraint(equalTo: logoImageView.heightAnchor, constant: 0.0).isActive = true
        
        
        //MARK:- containerView
        view.insertSubview(containerView, aboveSubview: logoImageView)
        containerView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        //MARK:- mailTextField
        view.insertSubview(mailTextField, aboveSubview: containerView)
        mailTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15).isActive = true
        mailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        mailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        mailTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //MARK:- passwordTextField
        view.insertSubview(passwordTextField, aboveSubview: containerView)
        passwordTextField.topAnchor.constraint(equalTo: mailTextField.bottomAnchor, constant: 15).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //MARK:- loginButton
        view.insertSubview(loginButton, aboveSubview: containerView)
        loginButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        //MARK:- facebookButton
//        view.insertSubview(facebokButton, aboveSubview: loginButton)
//        facebokButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10).isActive = true
//        facebokButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 33).isActive = true
//        facebokButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22).isActive = true
//
//        //MARK:- googleButton
//        view.insertSubview(googleButton, aboveSubview: facebokButton)
//        googleButton.topAnchor.constraint(equalTo: facebokButton.bottomAnchor, constant: 10).isActive = true
//        googleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
//        googleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
    }
    
}
extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == mailTextField{
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            didTapLoginButton()
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate{
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("user to fail login with facebook")
            return
        }
        
        spinner.show(in: view)
        let facebokRequest = FBSDKLoginKit.GraphRequest.init(graphPath: "me",
                                                             parameters: ["fields":"email,first_name,last_name,picture.type(large)"],
                                                             tokenString: token,
                                                             version: nil,
                                                             httpMethod: .get)
        
        facebokRequest.start(completion: { _, result, error in
            guard let result = result as? [String:Any], error == nil else {
                print("error to get result from graphRequest")
                return
            }
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            print("\(result)")
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let userMail = result["email"] as? String,
                  let picture = result["picture"] as? [String:Any],
                  let data = picture["data"] as? [String:Any],
                  let pictureUrl = data["url"] as? String else {
                return
            }
            UserDefaults.standard.setValue(userMail, forKey: "email")
            UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
            DatabaseManager.shared.userExists(with: userMail, completion:{ exits in
                if !exits {
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: lastName,
                                               mail: userMail)
                    DatabaseManager.shared.insertUser(with: chatUser,completion: { succes in
                        if succes{
                            
                            guard let url = URL(string: pictureUrl) else {
                                print("Error to get URL from facebok")
                                return
                            }
                            print("Download data from facebook image")
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _ , _ in
                                guard let data = data else {
                                    print("Failed to get data from facebook")
                                    return
                                }
                                print("got data from facebook, uploading ")
                                let fileName = chatUser.profilePictureFileName
                                storageManager.shared.uploadProfilePicture(with: data,
                                                                           fileName: fileName,
                                                                           completion: { results in
                                                                            
                                                                            switch results {
                                                                            case .success(let downloadURL):
                                                                                UserDefaults.standard.setValue(downloadURL, forKey: "profile_picture_url")
                                                                                print(downloadURL)
                                                                            case .failure(let error):
                                                                                print("storage manager error: \(error)")
                                                                            }
                                                                            
                                                                           })
                            }).resume()
                            
                        }
                        
                    })
                }
                
            })
        })
        
        
        
        
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard authResult != nil, error == nil else {
                if let error = error {
                    print("Facebook credential login failed ")
                }
                return
            }
            print("Successfully logged user in")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
}
