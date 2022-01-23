//
//  ChatViewController.swift
//  Firebase Chat App
//
//  Created by Felipe Ignacio Zapata Riffo on 09-09-21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation

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

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Location: LocationItem {
    var location: CLLocation
    var size: CGSize
    
    
}


class ChatViewController: MessagesViewController {
    
    private var senderPhotoURL: URL?
    private var otherUserPhotoURL: URL?
    
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
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.inputTextView.becomeFirstResponder()
        setUpInputButton()
        
    
    }
    
    
    private func setUpInputButton(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
     
    private func presentInputActionSheet(){
        let actionSheet = UIAlertController(
            title: "Attach Media",
            message: "What would you like attache?",
            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(
            title: "Photo",
            style: .default,
            handler: { [weak self] _ in
                self?.presentPhotoInputActionSheet()
            }))
        
        actionSheet.addAction(UIAlertAction(
            title: "Video",
            style: .default,
            handler: { [weak self] _ in
                
                self?.presentVideoInputActionSheet()
            }))
        
        actionSheet.addAction(UIAlertAction(
            title: "Audio",
            style: .default,
            handler: { [weak self] _ in
                
                
            }))
        
        actionSheet.addAction(UIAlertAction(
            title: "Location",
            style: .default,
            handler: { [weak self] _ in
                self?.presentLocationPicker()
                
            }))
        actionSheet.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentLocationPicker() {
            let vc = LocationPickerViewController(coordinates: nil)
            vc.title = "Pick Location"
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.completion = { [weak self] selectedCoorindates in

                guard let strongSelf = self else {
                    return
                }

                guard let messageId = strongSelf.createMessageId(),
                    let conversationId = strongSelf.conversationId,
                    let name = strongSelf.title,
                    let selfSender = strongSelf.selfSender else {
                        return
                }

                let longitude: Double = selectedCoorindates.longitude
                let latitude: Double = selectedCoorindates.latitude

                print("long=\(longitude) | lat= \(latitude)")


                let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                     size: .zero)

                let message = Message(sender: selfSender,
                                      messageId: messageId,
                                      sentDate: Date(),
                                      kind: .location(location))

                DatabaseManager.shared.sendMessages(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                    if success {
                        print("sent location message")
                    }
                    else {
                        print("failed to send location message")
                    }
                })
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    
    private func presentPhotoInputActionSheet(){
        
        let actionSheet = UIAlertController(
            title: "Attach Photo",
            message: "Where would you like to attach photo from",
            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(
            title: "Camera",
            style: .default,
            handler: { [weak self] _ in
                
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                picker.allowsEditing = true
                self?.present(picker,animated: true)
                
            }))
        
        actionSheet.addAction(UIAlertAction(
            title: "Photo Library",
            style: .default,
            handler: { [weak self] _ in
                
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                picker.allowsEditing = true
                self?.present(picker,animated: true)
                
            }))
        
        actionSheet.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
            ))
        
        present(actionSheet, animated: true)
    }
    
    
    private func presentVideoInputActionSheet(){
        
        let actionSheet = UIAlertController(
            title: "Attach Video",
            message: "Where would you like to attach photo from",
            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(
            title: "Camera",
            style: .default,
            handler: { [weak self] _ in
                
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                picker.mediaTypes = ["public_movie"]
                picker.videoQuality = .typeMedium
                picker.allowsEditing = true
                self?.present(picker,animated: true)
                
            }))
        
        actionSheet.addAction(UIAlertAction(
            title: "Video Library",
            style: .default,
            handler: { [weak self] _ in
                
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                picker.mediaTypes = ["public_movie"]
                picker.videoQuality = .typeMedium
                picker.allowsEditing = true
                self?.present(picker,animated: true)
                
            }))
        
        actionSheet.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
            ))
        
        present(actionSheet, animated: true)
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

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true, completion: nil)
       }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let conversationId = conversationId,
        let name = self.title,
        let selfSender = selfSender,
        let messageId = createMessageId() else {
            return
        }
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
           let imageData = image.pngData(){
            
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
            
            //upload image
            storageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let urlString):
                    //ready to sent message
                    print("Uploaded Message Photho: \(urlString)")
                   
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                              return
                          }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    print("media:\(media)")
                    
                    let message = Message(sender: selfSender  ,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .photo(media))
                    
                    DatabaseManager.shared.sendMessages(to: conversationId,
                                                        otherUserEmail: strongSelf.otherUserEmail,
                                                        name: name,
                                                        newMessage: message,
                                                        completion: { success in
                        if success {
                            //
                            print("sent photo message")
                        } else {
                            print("failed to send photo message")
                        }
                        
                    })
                case .failure(let error):
                    print("message photo upload error: \(error)")
                }
                
            })
        }else if let videoUrl  =  info[.mediaURL] as? URL{
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            //upload video
            storageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let urlString):
                    //ready to sent message
                    print("Uploaded Message Video: \(urlString)")
                   
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                              return
                          }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    print("media:\(media)")
                    
                    let message = Message(sender: selfSender  ,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .video(media))
                    
                    DatabaseManager.shared.sendMessages(to: conversationId,
                                                        otherUserEmail: strongSelf.otherUserEmail,
                                                        name: name,
                                                        newMessage: message,
                                                        completion: { success in
                        if success {
                            //
                            print("sent photo message")
                        } else {
                            print("failed to send photo message")
                        }
                        
                    })
                case .failure(let error):
                    print("message photo upload error: \(error)")
                }
                
            })
        }
         
        //send message
        
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
                                                                let newConversationId = "conversation_\(message.messageId)"
                                                                self?.conversationId = newConversationId
                                                                self?.listenMessages(id: newConversationId, shouldScrollToBottom: true)
                                                                self?.messageInputBar.inputTextView.text = nil

                                                                
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
            DatabaseManager.shared.sendMessages(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { [weak self] success in
                if success {
                    print("message send")
                    self?.messageInputBar.inputTextView.text = nil
                    
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
        let randomizer = Int.random(in: 0...1000000000000000000)
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
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            //our message that we sent
            return .link
        }
        return .secondarySystemBackground
    }
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let sender = message.sender
        if sender.senderId == selfSender?.senderId{
            //show our image
            if let currentImageURL = self.senderPhotoURL{
                avatarView.sd_setImage(with: currentImageURL, completed: nil)
            } else {
                //fetch url
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    return
                }
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images\(safeEmail)_profile_picture.png"
                
                storageManager.shared.downloadURL(for: path, completion: {
                    [weak self] result in
                    switch result{
                        
                    case .success(let url):
                        self?.senderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("Error:\(error)")
                    }
                })
            }
        }else {
            //show our image
            if let otherUserPhotoURL = self.otherUserPhotoURL{
                avatarView.sd_setImage(with: otherUserPhotoURL, completed: nil)
            } else {
                //fetch url
                let email = self.otherUserEmail
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images\(safeEmail)_profile_picture.png"
                
                storageManager.shared.downloadURL(for: path, completion: {
                    [weak self] result in
                    switch result{
                        
                    case .success(let url):
                        self?.otherUserPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("Error:\(error)")
                    }
                })
            }
        }
    }
}

extension ChatViewController: MessageCellDelegate {
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
           guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
               return
           }

           let message = messages[indexPath.section]

           switch message.kind {
           case .location(let locationData):
               let coordinates = locationData.location.coordinate
               let vc = LocationPickerViewController(coordinates: coordinates)
               
               vc.title = "Location"
               navigationController?.pushViewController(vc, animated: true)
           default:
               break
           }
       }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            let vc = PhotoViewerViewController(with: imageUrl)
            self.navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true, completion: nil)
        default:
            break
        }
    }
}

