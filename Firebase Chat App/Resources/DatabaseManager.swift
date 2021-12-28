//
//  DatabaseManager.swift
//  Firebase Chat App
//
//  Created by Felipe Ignacio Zapata Riffo on 07-09-21.
//

import Foundation
import FirebaseDatabase
final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress:String)->String{
        var safeMail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeMail = safeMail.replacingOccurrences(of: "@", with: "-")
        safeMail = safeMail.replacingOccurrences(of: "#", with: "-")
        safeMail = safeMail.replacingOccurrences(of: "$", with: "-")
        safeMail = safeMail.replacingOccurrences(of: "' '", with: "-")
        return safeMail
    }
    
}

struct ChatAppUser {
    let firstName:String
    let lastName: String
    let mail: String
     var safeMail:String{
        var safeMail = mail.replacingOccurrences(of: ".", with: "-")
        safeMail = safeMail.replacingOccurrences(of: "@", with: "-")
        safeMail = safeMail.replacingOccurrences(of: "#", with: "-")
        safeMail = safeMail.replacingOccurrences(of: "$", with: "-")
        safeMail = safeMail.replacingOccurrences(of: "' '", with: "-")
        return safeMail
    }
    var profilePictureFileName: String{
        //profile_picture.png
        return "\(safeMail)_profile_picture.png"
    }
  
   
}

//MARK:- Account Management
extension DatabaseManager {
    public func userExists (with mail:String,completion: @escaping((Bool)->Void)){
        
        var safeMail = mail.replacingOccurrences(of: ".", with: "-")
        safeMail = safeMail.replacingOccurrences(of: "@", with: "-")
        safeMail = safeMail.replacingOccurrences(of: "#", with: "-")
        safeMail = safeMail.replacingOccurrences(of: "$", with: "-")
        safeMail = safeMail.replacingOccurrences(of: "' '", with: "-")
        database.child(safeMail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    ///insert new user database
    public func insertUser(with user:ChatAppUser, completion: @escaping(Bool)->Void){
        database.child(user.safeMail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
            
        ],withCompletionBlock: { error, _ in
            guard error == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                    if var usersColecction = snapshot.value as? [[String:String]] {
                    //append  to user dictionary
                        let newElement = [
                                "name":user.firstName + " " + user.lastName,
                                "email":user.safeMail
                            ]
                        
                        usersColecction.append(newElement)
                        self.database.child("users").setValue(usersColecction,withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            completion(true)
                        })
                }
                    else {
                        //create that  array
                        let newCollection : [[String:String]] = [
                            [
                                "name":user.firstName + " " + user.lastName,
                                "email":user.safeMail
                            ]
                        ]
                        self.database.child("users").setValue(newCollection,withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            completion(true)
                        })
                    }
            })
             
        })
    }
    public func getAllUsers (completion: @escaping (Result<[[String:String]],Error>)->Void){
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String:String]] else {
                completion(.failure(DataseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
        
    }
}

public enum DataseError: Error{
    case failedToFetch
}

extension Notification.Name {
    static let didLogInNotification = Notification.Name("didLogInNotification")
}

//MARK:- Sending Message / Conversations
extension DatabaseManager {
    
    //Create a new conversation with target user email and first message send
    public func createNewConversation (with otherUserEmail : String, name:String, firstMessage: Message, completion: @escaping (Bool)->Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard var userNode = snapshot.value as? [String:Any] else {
                completion(false)
                print("error not found ")
                return
            }
            let messageDate  = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
                break
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let conversationId = "conversation_\(firstMessage.messageId)"
            let newConversation : [String :Any ] = [
                
                "id" : conversationId,
                "name":name,
                "other_user_email": otherUserEmail,
                "lasted_message": [
                    "date": dateString,
                    "message": message,
                    "isRed": false
                ]
                
            ]
            
             
    
            if var conversations = userNode["conversations"] as? [[String:Any]] {
                //conversation array exist for current user
                //append conversation
                userNode["conversations"] = conversations
                conversations.append(newConversation)
                ref.setValue(userNode, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self.finishCreatingConversation(name: name,conversationID: conversationId, firstMessage: firstMessage, complation: completion)
                    
                })
            } else {
             //conversation not created
                userNode["conversations"] = [
                    newConversation
                ]
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                   
                    self?.finishCreatingConversation(name: name,conversationID: conversationId, firstMessage: firstMessage, complation: completion)
                    
                })
            }
        })
        
        
    }
    
    private func finishCreatingConversation(name:String, conversationID: String,firstMessage: Message, complation: @escaping (Bool)->Void){
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
            break
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let messageDate  = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            complation(false)
            return
        }
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String:Any] = [
            "id": firstMessage.messageId,
            "type":firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_Read": false,
            "name":name
        ]
        
        let value: [String:Any] = [
            "message": [
                collectionMessage
            ]
        ]
        print("adding convo \(conversationID)")
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                complation(false)
                return
            }
            complation(true)
        })
    }
    //Fetch and return all conversations for the user with pass and email
    public func getAllConversation(for email:String, completion: @escaping (Result<[Conversation],Error>)->Void){
        database.child("\(email)/conversations").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DataseError.failedToFetch))
                return
            }
            let conversations_: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                    let name = dictionary["name"] as? String,
                    let otherUserEmail = dictionary["other_user_email"] as? String,
                    let latestMessage = dictionary["lasted_message"] as? [String: Any],
                    let date = latestMessage["date"] as? String,
                    let message = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool else {
                        return nil
                }
                
                
                let latestMmessageObject = LastedMessage(date: date,
                                                         text: message,
                                                         isRead: isRead)
                print(latestMmessageObject)
                
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    lastedMessage: latestMmessageObject)
            })

            completion(.success(conversations_))
            print("\(completion(.success(conversations_)))")
           
             
            
         })
        
    }
    //Get all message for a given converstions
    public func getAllMessagesForConversations(with id:String, completion: @escaping (Result<String,Error>)->Void){
        
    }
    
    //Send messages with target user conversations and messages
    public func sendMessages(to conversations:String, message:Message, completion: @escaping (Result<String,Error>)->Void){
        
    }
}
