//
//  ChatViewController.swift
//  Firebase Chat App
//
//  Created by Felipe Ignacio Zapata Riffo on 09-09-21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message:MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}
extension MessageKind {
    var messageKindString:String{
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
     
}

struct Sender:SenderType {
    var senderId: String
    var displayName: String
    var photoURL: String
}

struct Media:MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}


class ChatViewController: MessagesViewController {
    
    public static var dateFormatter : DateFormatter = {
       let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = .current
        return dateFormatter
    }()
    public var isNewConverstion = false
    public var otherUserEmail :  String = ""
    private var conversationId :  String?
    
    private var selfSender:Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(senderId: safeEmail,
                             displayName: "Me",
                             photoURL: "")
         
    }
     
   
    private var messages = [Message]()
    
    init(with email:String, id:String?) {
        self.conversationId = id
        self.otherUserEmail = email
        
        super.init(nibName: nil, bundle: nil)
        if let conversationId = conversationId {
            listenMessages(id: conversationId, shouldScrollToBottom: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor  = .red
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate =  self
        messageInputBar.delegate = self
        messageInputBar.inputTextView.becomeFirstResponder()
        
    
    }
     
    private func listenMessages(id:String, shouldScrollToBottom: Bool){
        DatabaseManager.shared.getAllMessagesForConversations(with: id) { [weak self] result in
            switch result {
            case .success(let messages):
                    print("success in getting messages")
                guard !messages.isEmpty else {
                    print("messages are empty")
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    }
                }
            case .failure(let error):
                print("failed to get messages \(error)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }

    
}
extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = self.selfSender,
        let messageId = createMessageId() else {
            return
        }
        let message = Message(sender: selfSender  ,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        //send message
        print("Sendind Text: \(text)")
        if isNewConverstion {
             
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name:self.title ?? "user",
                                                         firstMessage: message,
                                                         completion: { [weak self] success in
                                                            if success{
                                                                print("message send")
                                                                self?.isNewConverstion = false
                                                            } else {
                                                                print("failed to send")
                                                            }
                                                            
                                                         })
        }
        else {
            guard let conversationId = conversationId, let name = self.title else {
                return
            }
            //append existing conversation data
            DatabaseManager.shared.sendMessages(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { success in
                if success {
                    print("message send")
                    
                }else {
                    print("message failed")
                }
                
            })
            
        }
    }
    private func createMessageId() -> String?{
        let dateString = Self.dateFormatter.string(from: Date())
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let randomizer = Int.random(in: 0...1000000000000000)
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
//        //ojo aqui
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(randomizer)"
        print("created messageId \(newIdentifier)")
        
        return newIdentifier
    }
}
extension ChatViewController:MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("error to send message   ")
        return Sender(senderId: "", displayName: "", photoURL: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
}
