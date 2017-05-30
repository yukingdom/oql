//
//  FourthViweCon.swift
//  oqlApp
//
//  Created by yukingdom on 2017/01/17.
//  Copyright © 2017年 yukingdom. All rights reserved.
//
import UIKit
import AVFoundation

import Firebase
import FirebaseStorage

class ForthViewController : UIViewController{
    
    
    @IBOutlet weak var UploadButton: UIButton!
    
    let folderName : [String] = ["Head","Beak","Body","Wings"]
    
    let fileManager = FileManager.default
    let documentPath : String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    
    //var fileName : [ [String] ] = [ [] ]
    
    
    var fileName : [String] = []
    
    func saveFolPath(_ FolderNum: Int) -> String{
        return "\(self.documentPath)/\(self.folderName[(FolderNum)])"
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    @IBAction func PushedUploadBtn(_ sender: AnyObject) {
        pushUpload()
    }
    
    func pushUpload () {
        
        let storageRef = FIRStorage.storage().reference(forURL: "")
        
        let uploadMetadata = FIRStorageMetadata()
        uploadMetadata.contentType = "audio/m4a"
        
        for i in 0 ..< folderName.count {
            fileName.removeAll()
            
            fileName = fileManager.subpaths(atPath: saveFolPath(i))!
            
            if fileName.isEmpty{
                
            } else {
                
                for j in 0 ..< fileName.count {
                    print (fileName[j])
                    
                    let filePath = "file://\(saveFolPath(i))/\(fileName[j])"
                    
                    let pathEncoded = filePath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    let nsURLfilepath = NSURL(string: pathEncoded)! as URL
                    
                    let saveFirebaseRef = storageRef.child("\(folderName[i])/\(fileName[j])")

                    let saveTask = saveFirebaseRef.putFile(nsURLfilepath as URL, metadata:uploadMetadata ) { (metadata, error) in
                        if (error != nil) {
                            print ("Got an error: \(error)")
                        } else {
                            // Metadata contains file metadata such as size, content-type, and download URL.
                            print ("Upload complete! Here's some metadata: \(metadata)")
                            print ("Your download URL is \(metadata?.downloadURL())")
                        }
                    }
                }
            }
        }
    }
}

/*do {
    let attributes = try fileManager.attributesOfItem(atPath: filePath) as NSDictionary
    print(attributes.fileSize())
} catch let _ as NSError{
}*/
