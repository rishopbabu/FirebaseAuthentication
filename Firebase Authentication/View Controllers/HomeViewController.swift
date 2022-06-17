//
//  HomeViewController.swift
//  Firebase Authentication
//
//  Created by MAC-OBS-26 on 01/06/22.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseStorageUI
import MobileCoreServices
import AVFoundation

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var uploadVideoButton: UIButton!
    
    @IBOutlet weak var viewVideo: UIImageView!
    
    @IBOutlet weak var signoutButton: UIButton!
    
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    @IBOutlet weak var showUserNameLabel: UILabel!
    
    @IBOutlet weak var showLastNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserDetails()
        fetchUserProfileImage()
        fetchNames()
        
        viewVideo.image = UIImage(systemName: "video.circle")
        viewVideo.contentMode = .scaleAspectFit
        viewVideo.isUserInteractionEnabled = true
        viewVideo.layer.masksToBounds = true
        viewVideo.layer.borderWidth = 2
        viewVideo.layer.borderColor = UIColor.lightGray.cgColor
        
        let gestureVideo = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfileVideo))
        viewVideo.addGestureRecognizer(gestureVideo)
    }
    
    @objc private func didTapChangeProfileVideo() {
        presentVideoActionSheet()
        print("profile video tapped")
    }
    
    func fetchUserDetails() {
        let user = Auth.auth().currentUser
        if let user = user {
            let name = user.email
            self.userNameLabel.text = name
            
        }
    }
    
    func fetchNames() {
        let user = Auth.auth().currentUser
        let db = Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: user?.uid ?? "").getDocuments(completion: { (querysnapshot, error) in
            if let error = error {
                print("error getting document: \(error)")
            } else {
                let document = querysnapshot!.documents.first
                let dataDescription = document?.data()
                guard let firstname = dataDescription?["firstname"] else { return }
                guard let lastname = dataDescription?["lastname"] else { return }
                print(firstname)
                self.showUserNameLabel.text = firstname as? String
                self.showLastNameLabel.text = lastname as? String
                print(lastname)
            }
        })
    }
    
    func fetchUserProfileImage() {
        let filename = (Auth.auth().currentUser?.email)! + "_profile_picture.png"
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let reference = storageRef.child("images/\(filename)")
        
        let imageView: UIImageView = self.profilePicture
        imageView.sd_setImage(with: reference)
        print("image showing")
    }
    
    func presentVideoActionSheet() {
        let actionsheet = UIAlertController(title: "Profile Video", message: "Camera/Gallery", preferredStyle: .actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionsheet.addAction(UIAlertAction(title: "Take Video", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionsheet.addAction(UIAlertAction(title: "Choose Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoPicker()
        }))
        
        present(actionsheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .camera
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentVideoPicker() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .photoLibrary
        vc.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func documentDirectory() -> URL {
      let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      return documentsDirectory
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let email = userNameLabel.text else {
            return
        }
        let filename = "\(email)_profile_video.mov"
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
           print(videoUrl)
            
            let urlvid = self.documentDirectory().appendingPathComponent(filename)
            let share = UIActivityViewController(activityItems: [urlvid], applicationActivities: nil)
            share.popoverPresentationController?.sourceView = self.view
            self.present(share, animated: true, completion: nil)
            
            if email == Auth.auth().currentUser?.email {
                Storage.storage().reference().child("videos/\(filename)").putFile(from: videoUrl as URL, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print("Failed to upload video: \(String(describing: error))")
                        return
                    }
                    Storage.storage().reference().child("videos/\(filename)").downloadURL(completion: {(url, error) in
                        guard let url = url, error == nil else {
                            print("Error downloading video file url: \(String(describing: error))")
                            return
                        }
                        print("Url downloaded: \(url)")

                    })
                })
            }
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func uploadVideoTapped(_ sender: Any) {
        print("Button Tapped!!!")
    }
    
    @IBAction func signoutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error sigining out:", signOutError)
        }
        let navigationController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.navigationController) as? ViewController
        self.view.window?.rootViewController = navigationController
        self.view.window?.makeKeyAndVisible()
        print("signed out succesfully")
    }
    
    @IBAction func deleteAccountTapped(_ sender: Any) {
        
        deleteUserDetails()
        
        let user = Auth.auth().currentUser

        user?.delete { error in
          if let error = error {
              print("Error: \(error.localizedDescription)")
          } else {
            print("Account deleted sucessfully")
              let navigationController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.navigationController) as? ViewController
              self.view.window?.rootViewController = navigationController
              self.view.window?.makeKeyAndVisible()
          }
        }
        
        //delete images
        let filename = (user?.email)! + "_profile_picture.png"
        let videoname = (user?.email)! + "_profile_video.mov"
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let deleteImage = storageRef.child("images/\(filename)")
        let deleteVideo = storageRef.child("videos/\(videoname)")
        deleteImage.delete { error in
            if let error = error {
                print("Cant Delete profile image it has an error: \(error)")
            } else {
                print("Profile image deleted successfully")
            }
        }
        
        deleteVideo.delete {error in
            if let error = error {
                print("Cant Delete profile video it has an error: \(error)")
            } else {
                print("Profile video deleted successfully")
            }
        }
    }
    
    func deleteUserDetails() {
        //delete names
        let user = Auth.auth().currentUser
        let db = Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: user?.uid ?? "").getDocuments(completion: { (snapshot, error) in
            if let error = error {
                print("error getting document: \(error)")
            } else {
                let document = snapshot!.documents.first
                let dataDescription = document?.data()
                guard let uid = dataDescription?["uid"] else { return }
                if uid as! String == user?.uid ?? "" {
                    db.collection("users").document("\(document?.documentID ?? "")").delete()
                    print("user details deleted")
                }
            }
        })
    }
}
