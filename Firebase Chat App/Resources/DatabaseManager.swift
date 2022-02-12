//
//  DatabaseManager.swift
//  Firebase Chat App
//
//  Created by Felipe Ignacio Zapata Riffo on 07-09-21.
//

import Foundation
import FirebaseDatabase
import MessageKit
import UIKit
import CoreLocation
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

extension DatabaseManager {

    /// Returns dictionary node at child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DataseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }

}

//MARK:- Account Management
extension DatabaseManager {
    

    public func userExists (with mail:String,completion: @escaping((Bool)->Void)){
        
//        var safeMail = mail.replacingOccurrences(of: ".", with: "-")
//        safeMail = safeMail.replacingOccurrences(of: "@", with: "-")
//        safeMail = safeMail.replacingOccurrences(of: "#", with: "-")
//        safeMail = safeMail.replacingOccurrences(of: "$", with: "-")
//        safeMail = safeMail.replacingOccurrences(of: "' '", with: "-")
//        safeMail = safeMail.replacingOccurrences(of: "[' ']", with: "-")
        let safeMail = DatabaseManager.safeEmail(emailAddress: mail)
        database.child(safeMail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String:Any] != nil else {
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
            
        ],withCompletionBlock: { [weak self] error, _ in
            
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            strongSelf.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                    if var usersColecction = snapshot.value as? [[String:String]] {
                    //append  to user dictionary
                        let newElement = [
                                "name":user.firstName + " " + user.lastName,
                                "email":user.safeMail
                            ]
                        
                        usersColecction.append(newElement)
                        strongSelf.database.child("users").setValue(usersColecction,withCompletionBlock: { error, _ in
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
                        strongSelf.database.child("users").setValue(newCollection,withCompletionBlock: { error, _ in
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
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
        let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
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
                    "is_read": false
                ]
                
            ]
            
            let recipient_newConversation : [String :Any ] = [
                
                "id" : conversationId,
                "name":currentName,
                "other_user_email": safeEmail,
                "lasted_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
                
            ]
            //update recipient conversation
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String:Any]]{
                    //append
                    conversations.append(recipient_newConversation)
                    self?.database.child("\(otherUserEmail)/conversations").setValue([conversations])

                }else {
                    //create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversation])
                }
            }
            //Update current user conversation entry
            
            
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
                    self?.finishCreatingConversation(name: name,conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                    
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
                   
                    self?.finishCreatingConversation(name: name,conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                    
                })
            }
        })
        
        
    }
    
    private func finishCreatingConversation(name:String, conversationID: String,firstMessage: Message, completion: @escaping (Bool)->Void){
        
        let messageDate = firstMessage.sentDate
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
        
    
     
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
                    "id": firstMessage.messageId,
                    "type": firstMessage.kind.messageKindString,
                    "content": message,
                    "date": dateString,
                    "sender_email": currentUserEmail,
                    "is_read": false,
                    "name": name
                ]
        
        let value: [String:Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        print("adding convo \(conversationID)")
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
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
    public func getAllMessagesForConversations(with id:String, completion: @escaping (Result<[Message],Error>)->Void){
        database.child("\(id)/messages").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DataseError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else {
                          return nil
                      }
                        
                    var kind: MessageKind?
                    if type == "photo" {
                        //photo
                        guard let imageUrl = URL(string: content),
                        let placeHolder = UIImage(systemName: "plus") else {
                            return nil
                        }
                        let media = Media(url: imageUrl,
                                          image: nil,
                                          placeholderImage: placeHolder,
                                          size: CGSize(width: 300, height: 300))
                        kind = .photo(media)
                    }
                    else if type == "video" {
                        //photo
                        guard let videoUrl = URL(string: content),
                        let placeHolder = UIImage(named: "video_placeholder") else {
                            return nil
                        }
                        let media = Media(url: videoUrl,
                                          image: nil,
                                          placeholderImage: placeHolder,
                                          size: CGSize(width: 300, height: 300))
                        kind = .video(media)
                        
                    } else if type == "location" {
                        let locationComponents = content.components(separatedBy: ",")
                        guard let longitude = Double(locationComponents[0]),
                            let latitude = Double(locationComponents[1]) else {
                            return nil
                        }
                        print("Rendering location; long=\(longitude) | lat=\(latitude)")
                        let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                                size: CGSize(width: 300, height: 300))
                        kind = .location(location)
                    }
                    else {
                        //text
                        kind = .text(content)
                    }
                    guard let finalKind = kind else {
                        return nil
                    }
                
                      let sender = Sender(senderId: senderEmail,
                                          displayName: name,
                                          photoURL: "")
                
                      return Message(sender: sender,
                                     messageId: messageID,
                                     sentDate: date ,
                                     kind: finalKind)
            })

            completion(.success(messages))
            print("\(completion(.success(messages)))")
           
             
            
         })
    }
    
    //Send messages with target user conversations and messages
    public func sendMessages(to conversation:String, otherUserEmail: String, name:String, newMessage:Message, completion: @escaping (Bool) -> Void){
        //add new message to messages
        //update sender lastet message
        //update recipient lastest message
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else  {
            completion(false)
            return
        }
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self ] snaptshot in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = snaptshot.value as? [[String:Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
                    let dateString = ChatViewController.dateFormatter.string(from: messageDate)

                    var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
                break
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrl = mediaItem.url?.absoluteString {
                    message = targetUrl
                }
                break
            case .video(let mediaItem):
                if let targetUrl = mediaItem.url?.absoluteString {
                    message = targetUrl
                }
                break
            case .location(let locationData):
                            let location = locationData.location
                            message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
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
            
        
         
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
            
            let newMessageEntry: [String: Any] = [
                        "id": newMessage.messageId,
                        "type": newMessage.kind.messageKindString,
                        "content": message,
                        "date": dateString,
                        "sender_email": currentUserEmail,
                        "is_read": false,
                        "name": name
                    ]
            
            currentMessages.append(newMessageEntry)

                        strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }

                            strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                                var databaseEntryConversations = [[String: Any]]()
                                let updatedValue: [String: Any] = [
                                    "date": dateString,
                                    "is_read": false,
                                    "message": message
                                ]

                                if var currentUserConversations = snapshot.value as? [[String: Any]] {
                                    var targetConversation: [String: Any]?
                                    var position = 0

                                    for conversationDictionary in currentUserConversations {
                                        if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                            targetConversation = conversationDictionary
                                            break
                                        }
                                        position += 1
                                    }

                                    if var targetConversation = targetConversation {
                                        targetConversation["lasted_message"] = updatedValue
                                        currentUserConversations[position] = targetConversation
                                        databaseEntryConversations = currentUserConversations
                                    }
                                    else {
                                        let newConversationData: [String: Any] = [
                                            "id": conversation,
                                            "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                                            "name": name,
                                            "lasted_message": updatedValue
                                        ]
                                        currentUserConversations.append(newConversationData)
                                        databaseEntryConversations = currentUserConversations
                                    }
                                }
                                else {
                                    let newConversationData: [String: Any] = [
                                        "id": conversation,
                                        "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                                        "name": name,
                                        "lasted_message": updatedValue
                                    ]
                                    databaseEntryConversations = [
                                        newConversationData
                                    ]
                                }

                                strongSelf.database.child("\(currentEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                    guard error == nil else {
                                        completion(false)
                                        return
                                    }


                                    // Update latest message for recipient user
                                    strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                                        let updatedValue: [String: Any] = [
                                            "date": dateString,
                                            "is_read": false,
                                            "message": message
                                        ]
                                        var databaseEntryConversations = [[String: Any]]()

                                        guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                                            return
                                        }

                                        if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                            var targetConversation: [String: Any]?
                                            var position = 0

                                            for conversationDictionary in otherUserConversations {
                                                if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                                    targetConversation = conversationDictionary
                                                    break
                                                }
                                                position += 1
                                            }

                                            if var targetConversation = targetConversation {
                                                targetConversation["lasted_message"] = updatedValue
                                                otherUserConversations[position] = targetConversation
                                                databaseEntryConversations = otherUserConversations
                                            }
                                            else {
                                                // failed to find in current colleciton
                                                let newConversationData: [String: Any] = [
                                                    "id": conversation,
                                                    "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                                    "name": currentName,
                                                    "lasted_message": updatedValue
                                                ]
                                                otherUserConversations.append(newConversationData)
                                                databaseEntryConversations = otherUserConversations
                                            }
                                        }
                                        else {
                                            // current collection does not exist
                                            let newConversationData: [String: Any] = [
                                                "id": conversation,
                                                "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                                "name": currentName,
                                                "lasted_message": updatedValue
                                            ]
                                            databaseEntryConversations = [
                                                newConversationData
                                            ]
                                        }

                                        strongSelf.database.child("\(otherUserEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                            guard error == nil else {
                                                completion(false)
                                                return
                                            }

                                            completion(true)
                                        })
                                    })
                                })
                            })
                        }
                    })
                }
public func deleteConversation(conversationId:String,completion: @escaping(Bool)->Void){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        print("deleting conversation with id : \(conversationId)")
        //get all conversation for current user
        //delete conversation in collection with target id
        //reset those conversation for the user in database
        let ref = database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if var conversations = snapshot.value as? [[String:Any]] {
                 var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                       id == conversationId{
                        break
                    }
                    positionToRemove += 1
                }
                conversations.remove(at: positionToRemove)
                ref.setValue(conversations, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        print("failed to write new conversation array")
                        return
                    }
                    print("delete conversation")
                    completion(true)
                })
            }
            
        })
    }
    public func converstionExists(with targetRecipientEmail: String, completion: @escaping (Result<String,Error>)->Void){
        
        let safeRecipientEmail = DatabaseManager.safeEmail(emailAddress: targetRecipientEmail)
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)
        
        database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value, with: {
            snapshopt in
            guard let collection = snapshopt.value as? [[String:Any]] else {
                completion(.failure(DataseError.failedToFetch))
                return
            }
            //iterate and find conversations with target sender
            if let conversation = collection.first(where: {
                            guard let targetSenderEmail = $0["other_user_email"] as? String else {
                                return false
                            }
                            return safeSenderEmail == targetSenderEmail
                        }) {
                            // get id
                            guard let id = conversation["id"] as? String else {
                                completion(.failure(DataseError.failedToFetch))
                                return
                            }
                            completion(.success(id))
                            return
                        }

                        completion(.failure(DataseError.failedToFetch))
                        return
        })
        
    }
}
