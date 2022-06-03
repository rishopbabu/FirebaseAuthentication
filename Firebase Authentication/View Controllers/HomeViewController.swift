//
//  HomeViewController.swift
//  Firebase Authentication
//
//  Created by MAC-OBS-26 on 01/06/22.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class HomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var signoutButton: UIButton!
    
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserDetails()
        
    }
    
    func fetchUserDetails() {
        let uid = Auth.auth().currentUser?.uid
        
        
        userNameLabel.text = uid
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
    }
}
