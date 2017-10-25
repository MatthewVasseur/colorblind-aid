//
//  SignInViewController.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 10/24/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit
import os.log
import FirebaseAuth
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var loadingActivityView: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingContainerView: UIView!
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background to subtle dots
        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "subtleDots"))
        
        // Clear the error label
        setErrorLabel()
        
        // Initialize the activity indicator
        initActivityIndicator()
        
        // GID Instance
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let user = Auth.auth().currentUser {
            
            showActivityIndicator()
            
            signIn(user)
        }
    }
    
    // MARK: GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            print("Couldn't sign in, Error: \(error.localizedDescription)")
            return
        }
        
        print("Attempting to Sign In User: \(user.profile.email!)")
        
        // Start the activity indicator
        showActivityIndicator()
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        // Firebase then authenticates user
        Auth.auth().signIn(with: credential) {
            (user, error) in
            
            if let error = error {
                print("Firebase Auth Error: \(error)")
                self.setErrorLabel(AuthErrorCode(rawValue: error._code))
                self.signOutGoogleAndFirebase()
                
                return
            }
            
            // SEGUE etc.
            print(" signed in!")
        }
        // ...
    }
    
    // Signs out of both google and firebase authentication, also hides potential launchView
    func signOutGoogleAndFirebase() {
        hideActivityIndicator()
        
        GIDSignIn.sharedInstance().signOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: - Actions
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
//        // ...
//        if let error = error {
//            // ...
//            print("hi")
//            return
//        }
//        
//        guard let authentication = user.authentication else { return }
//        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
//        // ...
//        
//        // Start the activity indicator
//        showActivityIndicator()
//        
//        Auth.auth().signIn(with: credential) {
//            (user, error) in
//            
//            if let error = error {
//                // Set the error label
//                // print(error.localizedDescription)
//                self.setErrorLabel(AuthErrorCode(rawValue: error._code))
//   
//                // Stop the activity indicator
//                self.hideActivityIndicator()
//                
//                return
//            }
//            
//            // User is signed in
//            // ...
//            self.signIn(user!)
//        }
//    }
//    

//
//    @IBAction func didTapSignUp(_ sender: AnyObject) {
//        // Create account with given credentials (do nothing if email or password are blank)
//        guard let email = emailTextField.text, let password = passwordTextField.text else {
//            return
//        }
//        
//        // Disable fields while signing up
//        updateTextFieldStates(false)
//        updateButtonStates(false)
//        
//        // Start the activity indicator
//        showActivityIndicator()
//
//        FIRAuth.auth()?.createUser(withEmail: email, password: password) {
//            (user, error) in
//            if let error = error {
//                // Set the error label
//                // print(error.localizedDescription)
//                self.setErrorLabel(FIRAuthErrorCode(rawValue: error._code))
//
//                // Enable fields before returning
//                self.updateButtonStates(true)
//                self.resetPasswordButton.isEnabled = true
//                self.updateTextFieldStates(true)
//
//                // Stop the activity indicator
//                self.hideActivityIndicator()
//
//                return
//            }
//
//            // Create user in database & set display name
//            self.setDisplayName(user!)
//            Constants.firebase.usersRef.child(user!.uid).child("books").setValue(true)
//        }
//
//        // Clear Password field
//        passwordTextField.text = ""
//    }
    
//    @IBAction func didRequestPasswordReset(_ sender: AnyObject) {
//        // Send a password reset email through alert prompt (do nothing if email is blank)
//        let prompt = UIAlertController(title: "Reset Password", message: nil, preferredStyle: .alert)
//        
//        // Send a password reset email action
//        let resetAction = UIAlertAction(title: "Reset", style: .default, handler: {
//            (action) in
//            guard let userInput = prompt.textFields![0].text, !userInput.isEmpty else {
//                return
//            }
//            FIRAuth.auth()?.sendPasswordReset(withEmail: userInput) {
//                (error) in
//                if let error = error {
//                    // Set the error label
//                    // print(error.localizedDescription)
//                    self.setErrorLabel(FIRAuthErrorCode(rawValue: error._code))
//                    return
//                }
//                
//                // Set error label to success confirmation
//                self.errorLabel.text = "Password Reset Sent"
//                self.errorLabel.textColor = Constants.colors.success
//            }
//        })
//        
//        // Cancel (i.e. do nothing) action
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        // Add and style text field for the email
//        prompt.addTextField(configurationHandler: {
//            (textField) in
//            textField.keyboardType = .emailAddress
//            textField.clearButtonMode = .always
//            textField.font = UIFont.systemFont(ofSize: 14.0)
//            textField.placeholder = "Enter Email"
//        })
//        prompt.addAction(resetAction)
//        prompt.addAction(cancelAction)
//        
//        present(prompt, animated: true, completion: nil)
//    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Get the new view controller using segue.destination
        // Pass the selected object to the new view controller
        switch(segue.identifier ?? "") {
        case Constants.segues.signIn:
            os_log("Signing In.", log: .default, type: .debug)
            
            //            guard let mainTabController = segue.destination as? UITabBarController,
            //                let bookTableNavController = mainTabController.viewControllers?.first as? UINavigationController,
            //                let bookTableViewController = bookTableNavController.viewControllers.first as? BookTableViewController else {
            //                    fatalError("Unexpected destination!")
            //            }
            
            //            bookTableViewController.books = loadedBooks
            
            break
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    // MARK: - Private Methods
    private func signIn(_ user: User?) {
        // Cannot sign in without a user
        guard let user = user else {
            os_log("Need a user to sign in!", log: .default, type: .debug)
            return
        }
        
        // Clear Error label
        self.setErrorLabel()
        
        self.hideActivityIndicator() // Hide the activity view after loading
        //self.performSegue(withIdentifier: "SignIn", sender: nil)
    }
    
//    private func setDisplayName(_ user: FIRUser) {
//        // Set the users display name to be their email without domain
//        let changeRequest = user.profileChangeRequest()
//        changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
//        changeRequest.commitChanges() {
//            (error) in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//            self.signIn(FIRAuth.auth()?.currentUser)
//        }
//    }
    
//    // Helper method to look a user's information and books from database
//    private func loadUser(snapshot: FIRDataSnapshot) -> Void {
//        // Safely unwrap snapshot's value
//        guard let value = snapshot.value as? [String: AnyObject] else {
//            fatalError("User does not exist.")
//            //            return
//        }
//
//        // Get user's info and save in shared instance
//        AppState.sharedInstance.currentUser = User(snapshot: snapshot)
//
//        // Read user's books using dispatch group
//        if let booksIDs = value["books"] as? [String] {
//            for bookID in booksIDs {
//                loadBooksDG.enter()
//                Constants.firebase.booksRef.child(bookID).observeSingleEvent(of: .value, with: { (snapshot) in
//                    guard let book = Book(snapshot: snapshot) else {
//                        os_log("Unable to read the book for a User object.", log: .default, type: .debug)
//                        return
//                    }
//                    self.loadedBooks.append(book)
//                    self.loadBooksDG.leave() // Firebase has finished getting the book
//                })
//            }
//        }
//        loadBooksDG.leave()
//    }
    
    private func setErrorLabel(_ error: AuthErrorCode? = nil) {
        var errorText: String = ""
        
        guard let error = error else {
            errorLabel.text = ""
            return
        }
        
        switch (error) {
        case .userNotFound, .wrongPassword:
            errorText = "Incorrect Email/Password"
            break
            
        case .userDisabled:
            errorText = "Account Disabled"
            break
            
        case .invalidEmail, .emailAlreadyInUse:
            errorText = "Ineligible Email"
            break
            
        case .weakPassword:
            errorText = "Password Too Short"
            break
            
        case .operationNotAllowed:
            errorText = "Contact Administrator"
            break
            
        case .networkError:
            errorText = Constants.texts.networkConnectionError
            break
            
        default:
            fatalError("Unrecognized error \(error).")
            break
        }
        
        errorLabel.text = errorText
        errorLabel.textColor = Constants.colors.error
    }
    
    // MARK: Loading Activity Indicator Handlers
    private func initActivityIndicator() {
        loadingView.layer.cornerRadius = 10
        loadingContainerView.isHidden = true
    }
    private func hideActivityIndicator() {
        loadingActivityView.stopAnimating()
        loadingContainerView.isHidden = true
    }
    private func showActivityIndicator() {
        loadingActivityView.startAnimating()
        loadingContainerView.isHidden = false
    }
}
