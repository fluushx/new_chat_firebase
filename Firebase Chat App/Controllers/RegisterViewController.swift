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
        logoImageView.image = UIImage(named: "lee-sin")
        logoImageView.tintColor = .gray
        return logoImageView
    }()
    
    let bgView : UIView = {
        let bgView = UIView()
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = UIColor(displayP3Red: 9.0/255.0, green: 33.0/255.0, blue: 47.0/255.0, alpha: 1.0).withAlphaComponent(0.7)
        return bgView
    }()
    let bgImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "project-vayne-league-of-legends-3126")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    //MARK: firstNameField
    private let firstNameField : UITextField = {
       let firstNameField = UITextField()
     
        firstNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        firstNameField.translatesAutoresizingMaskIntoConstraints = false
        firstNameField.autocapitalizationType = .none
        firstNameField.attributedPlaceholder = NSAttributedString(
            string: "Ingrese Nombre",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        firstNameField.layer.cornerRadius = 10
        firstNameField.layer.masksToBounds = true
        firstNameField.font = .systemFont(ofSize: 15)
        firstNameField.layer.shadowRadius = 3
        firstNameField.layer.borderWidth = 0.5
        firstNameField.layer.borderColor = UIColor.black.cgColor
        firstNameField.autocorrectionType = .no
        firstNameField.textColor = .white

        return firstNameField
    }()
    //MARK: lasttNameField
    private let lasttNameField : UITextField = {
       let lasttNameField = UITextField()
     
        lasttNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        lasttNameField.autocapitalizationType = .none
        lasttNameField.attributedPlaceholder = NSAttributedString(
            string: "Ingrese Apellido",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        lasttNameField.layer.cornerRadius = 10
        lasttNameField.layer.masksToBounds = true
        lasttNameField.font = .systemFont(ofSize: 15)
        lasttNameField.leftViewMode = .always
        lasttNameField.layer.shadowColor = UIColor.lightGray.cgColor
        lasttNameField.layer.shadowRadius = 3
        lasttNameField.layer.borderWidth = 0.5
        lasttNameField.layer.borderColor = UIColor.black.cgColor
        lasttNameField.autocorrectionType = .no
        lasttNameField.translatesAutoresizingMaskIntoConstraints = false
        lasttNameField.textColor = .white
        return lasttNameField
    }()
    
    //MARK: mailTextField
    private let mailTextField : UITextField = {
       let mailTextField = UITextField()
        
        mailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        mailTextField.translatesAutoresizingMaskIntoConstraints = false
        mailTextField.autocapitalizationType = .none
        mailTextField.attributedPlaceholder = NSAttributedString(
            string: "Ingresar Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        mailTextField.layer.cornerRadius = 10
        mailTextField.layer.masksToBounds = true
        mailTextField.font = .systemFont(ofSize: 15)
        mailTextField.leftViewMode = .always
        mailTextField.layer.shadowColor = UIColor.lightGray.cgColor
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
            string: "Ingresar Contraseña",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.layer.masksToBounds = true
        passwordTextField.font = .systemFont(ofSize: 15)
        passwordTextField.leftViewMode = .always
        passwordTextField.layer.shadowColor = UIColor.lightGray.cgColor

        passwordTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderColor = UIColor.black.cgColor
        passwordTextField.textColor = .white
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
        loginButton.setTitle("Registrar", for: .normal)
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
        loginButton.backgroundColor = UIColor(red: 160 / 255.0, green: 170 / 255.0, blue: 200 / 255.0, alpha: 1.0)

        loginButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        return loginButton
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
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
        self.view.endEditing(true)
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
                strongSelf.alertUserLoginError(message: "Parece que esta cuenta ya existe en nuestros registros")
                return
            }
            
            let hashedPassoword = CommonFunctions.sharedInstance.MD5(string: password)
            print("hashedPassoword\(hashedPassoword)")
            
            //Register in firebase
            FirebaseAuth.Auth.auth().createUser(withEmail: mail, password: hashedPassoword, completion: { [weak self] authResult, error in
                guard let strongSelf = self else {
                     
                    return
                }
                guard authResult != nil, error == nil else {
                    let alert = UIAlertController(title: "Woops",
                                                  message: "Error creando cuenta",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss",
                                                  style: .cancel,
                                                  handler: nil))
                    return
                }
                UserDefaults.standard.set(mail, forKey: "email")
                UserDefaults.standard.set("\(firstName) \(lasttNameField)", forKey: "name")
                
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
    func alertUserLoginError(message:String = "Por favor de ingresar toda la información para crear una neuva cuenta"){
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok",
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
//        containerView.addSubview(mailTextField)
//        containerView.addSubview(passwordTextField)
//        containerView.addSubview(firstNameField)
//        containerView.addSubview(lasttNameField)
//        view.addSubview(loginButton)
        self.view.addSubview(bgImageView)
    }
    //MARK:- setUpConstraints
    func setUpConstraints(){
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
        containerView.heightAnchor.constraint(equalToConstant: 280).isActive = true
        
        //MARK:- firstNameField
        view.insertSubview(firstNameField, aboveSubview: containerView)
        firstNameField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15).isActive = true
        firstNameField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        firstNameField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        firstNameField.heightAnchor.constraint(equalToConstant: 50).isActive = true

           //MARK:- lastNameField
        view.insertSubview(lasttNameField, aboveSubview: containerView)
        lasttNameField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: 15).isActive = true
        lasttNameField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        lasttNameField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        lasttNameField.heightAnchor.constraint(equalToConstant: 50).isActive = true

           //MARK:- mailTextField
        view.insertSubview(mailTextField, aboveSubview: containerView)
        mailTextField.topAnchor.constraint(equalTo: lasttNameField.bottomAnchor, constant: 15).isActive = true
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
        view.insertSubview(loginButton, aboveSubview: passwordTextField)
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
        let actionSheet = UIAlertController(title: "Imagen de perfil", message: "¿ Le gustaria seleccionar una foto ?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Tomar una foto",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentCamera()
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Elegir una imagen",
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
