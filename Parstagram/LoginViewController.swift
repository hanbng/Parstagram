//
//  LoginViewController.swift
//  Parstagram
//
//  Created by nguyen thy on 7/10/20.
//  Copyright © 2020 Han Nguyen. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        if let username = usernameTextfield.text, let password = passwordTextfield.text {
            PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
                if user != nil {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                } else {
                    print("Error: \(error)")
                }
            }
        }
        
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        
        let user = PFUser()
        if let username = usernameTextfield.text, let password = passwordTextfield.text {
            user.username = username
            user.password = password

            user.signUpInBackground { (success, error) in
                if success {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                } else {
                    print("ehhh")
                    print("Error: \(error)")
                }
            }
        }

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
