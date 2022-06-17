//
//  ViewController.swift
//  Firebase Authentication
//
//  Created by MAC-OBS-26 on 01/06/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signupdidTapped(_ sender: Any) {
        HapticManager.shared.Vibrate(for: .success)
    }
    @IBAction func logindidTapped(_ sender: Any) {
        HapticManager.shared.selectionVibrate()
    }
    
}

