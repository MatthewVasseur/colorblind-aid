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
        if(GIDSignIn.sharedInstance().hasAuthInKeychain()) {
            //GIDSignIn.sharedInstance().signInSilently()
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
            
            // Clear Error label & Hide activity view
            self.setErrorLabel()
            self.hideActivityIndicator()
            
            self.performSegue(withIdentifier: "SignIn", sender: nil)
        }
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Get the new view controller using segue.destination
        // Pass the selected object to the new view controller
        switch(segue.identifier ?? "") {
            
        case Constants.segues.signIn:
            
            break
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    // MARK: - Private Methods
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
