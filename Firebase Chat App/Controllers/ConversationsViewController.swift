//
//  ViewController.swift
//  Firebase Chat App
//
//  Created by Felipe Ignacio Zapata Riffo on 06-09-21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import simd
import FirebaseMessaging


struct Conversation {
    let id:String
    let name:String
    let otherUserEmail: String
    let otherUserToken: String
    let lastedMessage: LastedMessage
    
}
struct LastedMessage {
    let date: String
    let text: String
    let isRead: Bool
}

class ConversationsViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
    var notificationTappedEmail : String = "rsdm55@gmail.com"
    
    private let tableView : UITableView = {
        let tableView = UITableView()
        tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.scroll(to: .top, animated: true)
        
        return tableView
    }()
    
    private let noConversation : UILabel = {
        let noConversation = UILabel()
        noConversation.text = "Sin conversaciones"
        noConversation.textAlignment = .center
        noConversation.font = .systemFont(ofSize:21,weight: .medium)
        noConversation.isHidden = true
        noConversation.translatesAutoresizingMaskIntoConstraints = false
        return noConversation
    }()
    override open var shouldAutorotate: Bool {
        return false
    }
    
    private var loginObserver: NSObjectProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        //        view.backgroundColor = .black
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        //        tableView.backgroundColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        startListeningForConversations()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification,
                                                               object: nil,
                                                               queue: .main,
                                                               using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.startListeningForConversations()
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "notificationTapped"), object: nil, queue: .main, using: { notificationData in
            print(notificationData)
            
            if let userInfo = notificationData.userInfo as? [String : Any] {
                if let email = userInfo["user_email"] as? String {
                    let emailToCheck = DatabaseManager.safeEmail(emailAddress: email)
                    for conversation in self.conversations {
                        if conversation.otherUserEmail == emailToCheck {
                            let model = conversation
                            self.openConversation(model)
                            UserDefaults.standard.removeObject(forKey: "notificationTappedEmail")
                            break
                        }
                    }
                }
            }
            
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpTableView()
        setUpNoConversaationLabel()
        
    }
    
    func setUpNoConversaationLabel(){
        view.addSubview(noConversation)
        noConversation.topAnchor.constraint(equalTo: tableView.topAnchor,constant: 350).isActive = true
        noConversation.leadingAnchor.constraint(equalTo: tableView.leadingAnchor,constant: 100).isActive = true
    }
    
    private func validateAuth(){
        
        guard let currentUser = FirebaseAuth.Auth.auth().currentUser else {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
            return
        }
        
        Messaging.messaging().token { token, error in
            if let token = token {
                print("FCM registration token: \(token)")
                DatabaseManager.shared.updateDeviceToken(email: currentUser.email ?? "N/A", deviceToken: token)
            }
        }
    }
    
    func setUpTableView(){
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    
    
    private func startListeningForConversations(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        print("starting to fetch conversations")
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversation(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations_):
                print("successfully got conversation models")
                guard !conversations_.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.noConversation.isHidden = false
                    return
                }
                self?.noConversation.isHidden = true
                self?.tableView.isHidden = false
                self?.conversations = conversations_
                
                print(self?.conversations as Any)
                
                DispatchQueue.main.async {
                    self!.tableView.reloadData()
                    self!.tableView.scroll(to: .top, animated: true)
                }
                
                
                if let emailTapped = UserDefaults.standard.string(forKey: "notificationTappedEmail") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        guard let strongSelf = self else { return }
                        let emailToCheck = DatabaseManager.safeEmail(emailAddress: emailTapped)
                        for conversation in strongSelf.conversations {
                            if conversation.otherUserEmail ==  emailToCheck {
                                let model = conversation
                                strongSelf.openConversation(model)
                                UserDefaults.standard.removeObject(forKey: "notificationTappedEmail")
                                break
                            }
                        }
                    })
                    
                }
                
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noConversation.isHidden = false
                print("failed to get convos: \(error)")
            }
            
        })
    }
    
    @objc func didTapComposeButton(){
        let vc = NewConversationViewController()
        vc.completion = { [weak self ] result in
            guard let strongSelf = self else {
                return
            }
            let currentConversation = strongSelf.conversations
            
            if let tarjetConversations = currentConversation.first(where: {
                $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: result.email)
            }){
                let vc = ChatViewController(with: tarjetConversations.otherUserEmail, id:tarjetConversations.id, token: tarjetConversations.otherUserToken)
                vc.isNewConverstion = false
                vc.title = tarjetConversations.name
                vc.navigationItem.largeTitleDisplayMode  = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }else {
                strongSelf.createNewConversation(result: result)
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
        
    }
    
    private func createNewConversation(result: SearchResult){
        let name = result.name
        let email =  DatabaseManager.safeEmail(emailAddress: result.email)
        let token = result.deviceToken
        
        //check in database if conversation with these two user exist
        //if it does, reuse conversation id,
        //othewise user existing code
        
        DatabaseManager.shared.converstionExists(with: email, completion: {
            [weak self] result in
            guard let strongSelf =  self else {
                return
            }
            switch result{
                
            case .success(let conversationId):
                let vc = ChatViewController(with: email, id: conversationId, token: token)
                vc.isNewConverstion = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode  = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: email, id:nil, token: token)
                vc.isNewConverstion = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode  = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
        let vc = ChatViewController(with: email, id: nil, token: token)
        vc.isNewConverstion = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode  = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ConversationsViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier ,for: indexPath) as! ConversationTableViewCell
        let model = conversations[indexPath.row]
        cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: cell.frame.width, height: cell.frame.height))
        
        //        let image = UIImage(named: "lcu-beta-update-2-banner")
        //        imageView.image = image
        imageView.layer.cornerRadius = 10
        //        imageView.contentMode = .scaleAspectFill
        cell.backgroundView = UIView()
        cell.backgroundView!.addSubview(imageView)
        //        cell.backgroundColor = .black
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = conversations[indexPath.row]
        openConversation(model)
        
    }
    
    func openConversation(_ model : Conversation){
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id, token: model.otherUserToken)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode  = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //delete conve
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let conversationId = conversations[indexPath.row].id
        if editingStyle == .delete{
            //begin delete
            tableView.beginUpdates()
            DatabaseManager.shared.deleteConversation(conversationId: conversationId, completion: { [weak self] success in
                if !success {
                    //                    self?.conversations.remove(at: indexPath.row)
                    //                    tableView.deleteRows(at: [indexPath], with: .left)
                    
                }
                
            })
            
            tableView.endUpdates()
        }
    }
    
}

extension UITableView {
    
    public func reloadData(_ completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion:{ _ in
            completion()
        })
    }
    
    func scroll(to: scrollsTo, animated: Bool) {
        print("scrolling")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            switch to{
            case .top:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
                break
            case .bottom:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
                break
            }
        }
    }
    
    enum scrollsTo {
        case top,bottom
    }
}
