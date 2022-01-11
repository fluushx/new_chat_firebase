//
//  ViewController.swift
//  Firebase Chat App
//
//  Created by Felipe Ignacio Zapata Riffo on 06-09-21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct Conversation {
    let id:String
    let name:String
    let otherUserEmail: String
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
    
    private let tableView : UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .purple
    
        tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let noConversation : UILabel = {
        let noConversation = UILabel()
        noConversation.text = "No Conversations"
        noConversation.textAlignment = .center
        noConversation.textColor = .gray
        noConversation.font = .systemFont(ofSize:21,weight: .medium)
        noConversation.isHidden = true
        noConversation.translatesAutoresizingMaskIntoConstraints = false
        return noConversation
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        fetchConversation()
        tableView.reloadData()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        startListeningForConversations()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         validateAuth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpTableView()
    }
    
    private func validateAuth(){
      
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    func setUpTableView(){
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func fetchConversation() {
        tableView.isHidden = false
    }
    
    private func startListeningForConversations(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        print("starting to fetch conversations")
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversation(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations_):
                print("successfully got conversation models")
                guard !conversations_.isEmpty else {
                   
           
                    return
                }
             
                
                self?.conversations = conversations_
                print(self?.conversations as Any)

                DispatchQueue.main.async {
                    self!.tableView.reloadData()
                }
            case .failure(let error):
                 
                print("failed to get convos: \(error)")
            }
            
        })
    }
    
    @objc func didTapComposeButton(){
        let vc = NewConversationViewController()
        vc.completion = { [weak self ] result in
            self?.createNewConversation(result: result)
        }
        vc.title = "New Conversation"
        let navVC = UINavigationController(rootViewController: vc)
        
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
         
    }
    
    private func createNewConversation(result: [String:String]){
        guard let name = result["name"], let email = result["email"] else {
            print("error to get name and email from database")
            return
        }
        
        let vc = ChatViewController(with: email, id: nil)
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
        
        for value in conversations {
            print(value.id)
        }
        
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = conversations[indexPath.row]
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode  = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
