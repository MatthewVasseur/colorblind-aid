//
//  SignInViewController.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 10/24/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class SignInViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    @IBOutlet weak var loadingActivityView: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingContainerView: UIView!
    
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background to subtle dots
        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "subtleDots"))
        
        // Style buttons' disabled state
        signUpButton.setTitleColor(UIColor.lightGray, for: .disabled)
        resetPasswordButton.setTitleColor(UIColor.lightGray, for: .disabled)
        
        // Set text field delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Clear the error label
        setErrorLabel()
        
        // Initialize the activity indicator
        initActivityIndicator()
        
        // GID Instance
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateButtonStates(false)
        
        if let user = Auth.auth().currentUser {
            updateTextFieldStates(false)
            showActivityIndicator()
            
            signIn(user)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Establish observers to watch keyboard show and hide
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Remove observers watching keyboard
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Disable sign in button while email/password are empty
        updateButtonStates(emailTextField.hasText && passwordTextField.hasText)
        
        if (textField === emailTextField) {
            passwordTextField.becomeFirstResponder()
        }
    }
    
    // MARK: - Actions
    @IBAction func endEditing(_ sender: UITapGestureRecognizer) {
        // Exit text editing when tapping outside field/view
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        // ...
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                // Set the error label
                // print(error.localizedDescription)
                self.setErrorLabel(AuthErrorCode(rawValue: error._code))
                
                // Enable fields before returning
                self.updateButtonStates(true)
                self.resetPasswordButton.isEnabled = true
                self.updateTextFieldStates(true)
                
                // Stop the activity indicator
                self.hideActivityIndicator()
                
                return
            }
            // User is signed in
            // ...
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    @IBAction func didTapSignIn(_ sender: AnyObject) {
        // Sign In with credentials (do nothing if email or password are blank)
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        // Disable fields while signing in and loading
        updateButtonStates(false)
        resetPasswordButton.isEnabled = false
        updateTextFieldStates(false)
        
        // Start the activity indicator
        showActivityIndicator()
        
        // Authenticate through Firebase
        Auth.auth().signIn(withEmail: email, password: password) {
            (user, error) in
            if let error = error {
                // Set the error label
                // print(error.localizedDescription)
                self.setErrorLabel(FIRAuthErrorCode(rawValue: error._code))
                
                // Enable fields before returning
                self.updateButtonStates(true)
                self.resetPasswordButton.isEnabled = true
                self.updateTextFieldStates(true)
                
                // Stop the activity indicator
                self.hideActivityIndicator()
                
                return
            }
            
            self.signIn(user!)
        }
        
        // Clear Password field
        passwordTextField.text = ""
    }
    
    @IBAction func didTapSignUp(_ sender: AnyObject) {
        // Create account with given credentials (do nothing if email or password are blank)
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        // Disable fields while signing up
        updateTextFieldStates(false)
        updateButtonStates(false)
        
        // Start the activity indicator
        showActivityIndicator()
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password) {
            (user, error) in
            if let error = error {
                // Set the error label
                // print(error.localizedDescription)
                self.setErrorLabel(FIRAuthErrorCode(rawValue: error._code))
                
                // Enable fields before returning
                self.updateButtonStates(true)
                self.resetPasswordButton.isEnabled = true
                self.updateTextFieldStates(true)
                
                // Stop the activity indicator
                self.hideActivityIndicator()
                
                return
            }
            
            // Create user in database & set display name
            self.setDisplayName(user!)
            Constants.firebase.usersRef.child(user!.uid).child("books").setValue(true)
        }
        
        // Clear Password field
        passwordTextField.text = ""
    }
    
    @IBAction func didRequestPasswordReset(_ sender: AnyObject) {
        // Send a password reset email through alert prompt (do nothing if email is blank)
        let prompt = UIAlertController(title: "Reset Password", message: nil, preferredStyle: .alert)
        
        // Send a password reset email action
        let resetAction = UIAlertAction(title: "Reset", style: .default, handler: {
            (action) in
            guard let userInput = prompt.textFields![0].text, !userInput.isEmpty else {
                return
            }
            FIRAuth.auth()?.sendPasswordReset(withEmail: userInput) {
                (error) in
                if let error = error {
                    // Set the error label
                    // print(error.localizedDescription)
                    self.setErrorLabel(FIRAuthErrorCode(rawValue: error._code))
                    return
                }
                
                // Set error label to success confirmation
                self.errorLabel.text = "Password Reset Sent"
                self.errorLabel.textColor = Constants.colors.success
            }
        })
        
        // Cancel (i.e. do nothing) action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add and style text field for the email
        prompt.addTextField(configurationHandler: {
            (textField) in
            textField.keyboardType = .emailAddress
            textField.clearButtonMode = .always
            textField.font = UIFont.systemFont(ofSize: 14.0)
            textField.placeholder = "Enter Email"
        })
        prompt.addAction(resetAction)
        prompt.addAction(cancelAction)
        
        present(prompt, animated: true, completion: nil)
    }
    
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
            AppState.sharedInstance.currentUser?.books = loadedBooks
            break
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    // MARK: - Private Methods
    private func signIn(_ user: FIRUser?) {
        // Cannot sign in without a user
        guard let user = user else {
            os_log("Need a user to sign in!", log: .default, type: .debug)
            return
        }
        
        // Find user in database and load information and books
        loadedBooks.removeAll() // Reset loaded books
        loadBooksDG.enter()
        Constants.firebase.usersRef.child(user.uid).observeSingleEvent(of: .value, with: loadUser)
        
        // Perform sign in segue once user's books have loaded
        loadBooksDG.notify(queue: .main, execute: {
            AppState.sharedInstance.isSignedIn = true
            
            // Clear Password field & Error label
            self.passwordTextField.text = ""
            self.setErrorLabel()
            
            // Enable fields before segue
            self.updateButtonStates(true)
            self.resetPasswordButton.isEnabled = true
            self.updateTextFieldStates(true)
            
            self.hideActivityIndicator() // Hide the activity view after loading
            self.performSegue(withIdentifier: "SignIn", sender: nil)
        })
    }
    
    private func setDisplayName(_ user: FIRUser) {
        // Set the users display name to be their email without domain
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
        changeRequest.commitChanges() {
            (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    // Helper method to look a user's information and books from database
    private func loadUser(snapshot: FIRDataSnapshot) -> Void {
        // Safely unwrap snapshot's value
        guard let value = snapshot.value as? [String: AnyObject] else {
            fatalError("User does not exist.")
            //            return
        }
        
        // Get user's info and save in shared instance
        AppState.sharedInstance.currentUser = User(snapshot: snapshot)
        
        // Read user's books using dispatch group
        if let booksIDs = value["books"] as? [String] {
            for bookID in booksIDs {
                loadBooksDG.enter()
                Constants.firebase.booksRef.child(bookID).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let book = Book(snapshot: snapshot) else {
                        os_log("Unable to read the book for a User object.", log: .default, type: .debug)
                        return
                    }
                    self.loadedBooks.append(book)
                    self.loadBooksDG.leave() // Firebase has finished getting the book
                })
            }
        }
        loadBooksDG.leave()
    }
    
    // MARK: Button state and error label handlers
    private func updateButtonStates(_ state: Bool) {
        signInButton.isEnabled = state
        signUpButton.isEnabled = state
        
        signInButton.alpha = state ? 1.0 : 0.5
    }
    private func updateTextFieldStates(_ state: Bool) {
        emailTextField.isEnabled = state
        passwordTextField.isEnabled = state
    }
    
    private func setErrorLabel(_ error: FIRAuthErrorCode? = nil) {
        var errorText: String = ""
        
        guard let error = error else {
            errorLabel.text = ""
            return
        }
        
        switch (error) {
        case .errorCodeUserNotFound, .errorCodeWrongPassword:
            errorText = "Incorrect Email/Password"
            break
            
        case .errorCodeUserDisabled:
            errorText = "Account Disabled"
            break
            
        case .errorCodeInvalidEmail, .errorCodeEmailAlreadyInUse:
            errorText = "Ineligible Email"
            break
            
        case .errorCodeWeakPassword:
            errorText = "Password Too Short"
            break
            
        case .errorCodeOperationNotAllowed:
            errorText = "Contact Administrator"
            break
            
        case .errorCodeNetworkError:
            errorText = Constants.texts.networkConnectionError
            break
            
        default:
            fatalError("Unrecognized error \(error).")
            break
        }
        
        errorLabel.text = errorText
        errorLabel.textColor = Constants.colors.error
    }
    
    // MARK: Keyboard show and hide handlers
    @IBAction private func keyboardWillShow(sender: NSNotification) {
        // Only move if the email or password text fields are selected
        if (!emailTextField.isFirstResponder && !passwordTextField.isFirstResponder) {
            return
        }
        
        // Get keyboard size from user info
        if let userInfo = sender.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                //  Adjust constraints to smoothly move text field above keyboard
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.keyboardConstraint.constant = -(keyboardSize.height + 8.0)
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    @IBAction private func keyboardWillHide(sender: NSNotification) {
        // Only return if the email or password text fields were selected
        if (!emailTextField.isFirstResponder && !passwordTextField.isFirstResponder) {
            return
        }
        
        // Get keyboard size from user info
        if let userInfo = sender.userInfo {
            if ((userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                // Adjust constraints to smoothly return text fields default location
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.keyboardConstraint.constant = Constants.constraints.defaultKeyboard
                    self.view.layoutIfNeeded()
                })
            }
        }
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
