//
//  RegisterViewController.swift
//  Firebase Chat App
//
//  Created by Felipe Ignacio Zapata Riffo on 06-09-21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
class RegisterViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    private var logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(systemName: "person.circle")
        logoImageView.tintColor = .gray
        return logoImageView
    }()
    
    //MARK: firstNameField
    private let firstNameField : UITextField = {
       let firstNameField = UITextField()
     
        firstNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        firstNameField.translatesAutoresizingMaskIntoConstraints = false
        firstNameField.autocapitalizationType = .none
        firstNameField.placeholder =  "Type Your First Name"
        firstNameField.backgroundColor = .secondarySystemBackground
        firstNameField.layer.cornerRadius = 10
        firstNameField.layer.masksToBounds = true
        firstNameField.font = .systemFont(ofSize: 15)
        firstNameField.leftViewMode = .always
        firstNameField.layer.shadowColor = UIColor.lightGray.cgColor
        firstNameField.layer.shadowOffset = CGSize(width:3, height:3)
        firstNameField.layer.shadowOpacity = 3
        firstNameField.layer.shadowRadius = 3
        firstNameField.layer.borderWidth = 0.5
        firstNameField.layer.borderColor = UIColor.black.cgColor
        firstNameField.autocorrectionType = .no
        return firstNameField
    }()
    //MARK: lasttNameField
    private let lasttNameField : UITextField = {
       let lasttNameField = UITextField()
     
        lasttNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        lasttNameField.autocapitalizationType = .none
        lasttNameField.placeholder =  "Type Your Last Name"
        lasttNameField.backgroundColor = .secondarySystemBackground
        lasttNameField.layer.cornerRadius = 10
        lasttNameField.layer.masksToBounds = true
        lasttNameField.font = .systemFont(ofSize: 15)
        lasttNameField.leftViewMode = .always
        lasttNameField.layer.shadowColor = UIColor.lightGray.cgColor
        lasttNameField.layer.shadowOffset = CGSize(width:3, height:3)
        lasttNameField.layer.shadowOpacity = 3
        lasttNameField.layer.shadowRadius = 3
        lasttNameField.layer.borderWidth = 0.5
        lasttNameField.layer.borderColor = UIColor.black.cgColor
        lasttNameField.autocorrectionType = .no
        lasttNameField.translatesAutoresizingMaskIntoConstraints = false
        return lasttNameField
    }()
    
    //MARK: mailTextField
    private let mailTextField : UITextField = {
       let mailTextField = UITextField()
        
        mailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        mailTextField.translatesAutoresizingMaskIntoConstraints = false
        mailTextField.autocapitalizationType = .none
        mailTextField.placeholder =  "Type Your Mail"
        mailTextField.backgroundColor = .secondarySystemBackground
        mailTextField.layer.cornerRadius = 10
        mailTextField.layer.masksToBounds = true
        mailTextField.font = .systemFont(ofSize: 15)
        mailTextField.leftViewMode = .always
        mailTextField.layer.shadowColor = UIColor.lightGray.cgColor
        mailTextField.layer.shadowOffset = CGSize(width:3, height:3)
        mailTextField.layer.shadowOpacity = 3
        mailTextField.layer.shadowRadius = 3
        mailTextField.layer.borderWidth = 0.5
        mailTextField.layer.borderColor = UIColor.black.cgColor
        mailTextField.autocorrectionType = .no
        return mailTextField
    }()
    //MARK: passwordTextField
    private let passwordTextField : UITextField = {
       let passwordTextField = UITextField()
        
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.autocapitalizationType = .none
        passwordTextField.placeholder = "Type Your Password"
        passwordTextField.backgroundColor = .secondarySystemBackground
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.layer.masksToBounds = true
        passwordTextField.font = .systemFont(ofSize: 15)
        passwordTextField.leftViewMode = .always
        passwordTextField.layer.shadowColor = UIColor.lightGray.cgColor
        passwordTextField.layer.shadowOffset = CGSize(width:3, height:3)
        passwordTextField.layer.shadowOpacity = 3
        passwordTextField.layer.shadowRadius = 3
        passwordTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderColor = UIColor.black.cgColor
        passwordTextField.textColor = .black
        passwordTextField.returnKeyType = .done
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        return passwordTextField
    }()
     
    //MARK: loginButton
    private let loginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.setTitle("Register", for: .normal)
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.backgroundColor = .link
        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.layer.shadowColor = UIColor.lightGray.cgColor
        loginButton.layer.shadowOffset = CGSize(width:3, height:3)
        loginButton.layer.shadowOpacity = 3
        loginButton.layer.shadowRadius = 3
        loginButton.layer.borderWidth = 0.5
        loginButton.layer.borderColor = UIColor.black.cgColor
        loginButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        loginButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        return loginButton
    }()
    
    //MARK: containerView
    private let containerView : UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemFill
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOffset = CGSize(width:3, height:3)
        containerView.layer.shadowOpacity = 3
        containerView.layer.shadowRadius = 3
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.backgroundColor = .systemGray6
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Register"
        setUpView()
        setUpConstraints()
        mailTextField.delegate = self
        passwordTextField.delegate = self
        
        logoImageView.isUserInteractionEnabled = true
        let gesture =  UITapGestureRecognizer(target: self, action: #selector(didTapChangePic))
        logoImageView.addGestureRecognizer(gesture)
        
    }
   
    //MARK:- didTapRegisterButton

    @objc private func didTapRegisterButton(){
        mailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lasttNameField.resignFirstResponder()
        guard let firstName = firstNameField.text,
              let lasttNameField = lasttNameField.text,
              let mail = mailTextField.text,
              let password = passwordTextField.text,
              !firstName.isEmpty, !lasttNameField.isEmpty,
              !mail.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        spinner.show(in: view)
        DatabaseManager.shared.userExists(with: mail, completion: { [weak self]exists in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                //user already exists
                strongSelf.alertUserLoginError(message: "Looks like user account for thath email addres already exists")
                return
            }
            //Register in firebase
            FirebaseAuth.Auth.auth().createUser(withEmail: mail, password: password, completion: { [weak self] authResult, error in
                guard let strongSelf = self else {
                     
                    return
                }
                guard authResult != nil, error == nil else {
                    let alert = UIAlertController(title: "Woops",
                                                  message: "Error creating account",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss",
                                                  style: .cancel,
                                                  handler: nil))
                    return
                }
                let chatUser =  ChatAppUser(firstName: firstName, lastName: lasttNameField, mail: mail)
                DatabaseManager.shared.insertUser(with: chatUser,completion: { success in
                    if success{
                        //upload image
                        guard let image = strongSelf.logoImageView.image,
                              let data = image.pngData() else {
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
                    }
                    
                })
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
        

    }
    //MARK:- alertUserLoginError
    func alertUserLoginError(message:String = "Please enter all information to create new account"){
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
        
    }
    
    @objc private func didTapChangePic(){
        print("tapped")
        presentPhotoActionSheet()
        
    }
    //MARK:- setUpView
    func setUpView(){
        view.addSubview(logoImageView)
        view.addSubview(containerView)
        containerView.addSubview(mailTextField)
        containerView.addSubview(passwordTextField)
        containerView.addSubview(firstNameField)
        containerView.addSubview(lasttNameField)
        view.addSubview(loginButton)
         
    }
    //MARK:- setUpConstraints
    func setUpConstraints(){
         
        //MARK:- imageLoginCenter
        logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 120).isActive = true
        logoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -120).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 180).isActive = true
 
        
        //MARK:- containerView
        containerView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 280).isActive = true
         
        //MARK:- firstNameField
        firstNameField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15).isActive = true
        firstNameField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        firstNameField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        firstNameField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //MARK:- lastNameField
        lasttNameField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: 15).isActive = true
        lasttNameField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        lasttNameField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        lasttNameField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //MARK:- mailTextField
        mailTextField.topAnchor.constraint(equalTo: lasttNameField.bottomAnchor, constant: 15).isActive = true
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
    }
}
extension RegisterViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == mailTextField{
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            didTapRegisterButton()
        }
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "Would you like to select a picture", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentCamera()
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
                                            }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true,completion: nil)
    }
    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true,completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.logoImageView.image = selectedImage
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
