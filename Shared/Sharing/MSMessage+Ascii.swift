//
//  MSMessage+Ascii.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 7/15/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import Messages
import CloudKit

extension MSMessage {
    
    static let database = CKContainer(identifier: "iCloud.com.liamrosenfeld.ImageToAsciiArt").publicCloudDatabase
    
    // MARK: - ASCII -> Message
    static func messageFromAscii(_ ascii: String, font: UIFont, completion: @escaping (Result<MSMessage, Error>) -> ()) {
        // generate preview image
        let maxImageSize = CGSize(width: 500, height: 500)
        let image = ascii.toImage(withFont: font).imageConstrainedToMaxSize(maxImageSize)
        
        let message = makeMessage(asciiArt: ascii, image: image)
        
        saveToDatabase(asciiArt: ascii) { result in
            switch result {
            case .success(let id):
                message.url = self.makeMessageURL(dbID: id)
                
                completion(.success(message))
                
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    private static func saveToDatabase(asciiArt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let asciiRecord = CKRecord(recordType: "AsciiArt")
        asciiRecord["text"] = asciiArt as NSString
        
        database.save(asciiRecord) { (record, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                if let record = record {
                    completion(.success(record.recordID.recordName))
                } else {
                    preconditionFailure("There was no error or record created")
                }
            }
        }
        
    }
    
    private static func makeMessage(asciiArt: String, image: UIImage) -> MSMessage {
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = "Ascii Art"
        message.layout = layout
        return message
    }
    
    private static func makeMessageURL(dbID: String) -> URL {
        var components = URLComponents()
        let qID = URLQueryItem(name: "dbID", value: dbID )
        components.queryItems = [qID]
        return components.url!
    }
    
    // MARK: - Message -> Ascii
    func toAscii(completion: @escaping (String?) -> ()) {
        guard let dbID = dbID else {
            completion(nil)
            return
        }
        
        MSMessage.database.fetch(withRecordID: .init(recordName: dbID)) { (record, error) in
            if error != nil {
                completion(nil)
            } else {
                if let record = record {
                    if let fetchedAscii = record["text"] as? NSString {
                        completion(fetchedAscii as String)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private var dbID: String? {
        guard let url = self.url else { return nil }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        return components.queryItems?.first(where: { $0.name == "dbID" })?.value
    }
}

extension MSMessage: Identifiable {
    public var id: String {
        dbID!
    }
}
