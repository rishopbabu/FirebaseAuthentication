//
//  LoginViewController.swift
//  Firebase Authentication
//
//  Created by MAC-OBS-26 on 01/06/22.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        
        //create cleaned version of text fields
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        //siginig the user
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            if let error = error as? NSError {
                switch AuthErrorCode.Code(rawValue: error.code) {
                  
                case .wrongPassword:
                    self.errorLabel.text = "wrong password"
                    self.errorLabel.alpha = 1
                    
                case .invalidEmail:
                    self.errorLabel.text = "invalid email"
                    self.errorLabel.alpha = 1
                
                case .userNotFound:
                    self.errorLabel.text = "user not found. please sign up"
                    self.errorLabel.alpha = 1
                    
                case .invalidCredential:
                    self.errorLabel.text = "invalid credential"
                    self.errorLabel.alpha = 1
                    
                    default:
                        print("Error: \(error.localizedDescription)")
                }
            }
            
//            if error != nil {
//                self.errorLabel.text = error?.localizedDescription
//                self.errorLabel.alpha = 1
//            }
            
            else {
                let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
                self.view.window?.rootViewController = homeViewController
                self.view.window?.makeKeyAndVisible()
            }
        }
        
        
    }
    
}
