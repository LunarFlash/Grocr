/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import QuartzCore

class LoginViewController: UIViewController {
    
    let ref = Firebase(url: BASE_URL)
    
    
    // MARK: Constants
    let LoginToList = "LoginToList"
    
    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    // MARK: Properties
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Create an authentication observer using observeAuthEventWithBlock(_:).
        ref.observeAuthEventWithBlock { (authData) -> Void in
            // The block is passed the authData parameter. Upon successful user authentication, this is populated with the user’s information. If authentication fails, the variable is nil.
            if authData != nil {
                // On successfull authentication, perform the segue. Pass nil as the sender. This may seem strange, but you’ll set this up in GroceryListTableViewController.swift.
                self.performSegueWithIdentifier(self.LoginToList, sender: nil)
            }
        }
    }

    
    
    
    // MARK: Actions
    @IBAction func loginDidTouch(sender: AnyObject) {
        //performSegueWithIdentifier(LoginToList, sender: nil)
        
        ref.authUser(textFieldLoginEmail.text, password: textFieldLoginPassword.text,
            withCompletionBlock: { (error, auth) in
                
        })
    }
    
    @IBAction func signUpDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Register",
            message: "Register",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction) -> Void in
                
                let emailField = alert.textFields![0]
                let passwordField = alert.textFields![1]
                
                // Call createUser(_:password:) on the Firebase reference passing the supplied email and password.
                self.ref.createUser(emailField.text, password: passwordField.text, withCompletionBlock: { (error) -> Void in
                
                    // In the closure, check if there was an error.
                    if error == nil {
                        
                        // Creating a user doesn’t imply authentication. To authenticate, call authUser(_:password:withCompletionBlock:), again passing in the given email and password.
                        
                        self.ref.authUser(emailField.text, password: passwordField.text, withCompletionBlock: { (error, authData) -> Void in
                            // For now, you simply do nothing in the closure.
                            
                        })
                
                    }
                    
                })
                
                
                
                
                
                
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textEmail) -> Void in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textPassword) -> Void in
            textPassword.secureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }
    
}

