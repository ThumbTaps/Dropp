//
//  AccountViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 5/20/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit
import Social
import Accounts

class AccountViewController: DroppViewController {
	
	@IBOutlet weak var logo: DroppBackdrop!
	@IBOutlet weak var logoCenteredConstraint: NSLayoutConstraint!
	@IBOutlet weak var logoSettledBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var logoSettledWidthConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var signInLabel: UILabel!
	@IBOutlet weak var createAccountLabel: UILabel!
	@IBOutlet weak var emailAddressTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var confirmPasswordTextField: UITextField!
	@IBOutlet weak var noHaveAccountButton: DroppButton!
	@IBOutlet weak var noWantAccountButton: DroppButton!
	@IBOutlet weak var scrollView: UIScrollView!
	
	var creatingAccount: Bool {
		return self.scrollView.contentOffset.x == self.view.frame.width
	}
	var firstResponder: UITextField?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.scrollView.contentSize = CGSize(width: self.view.frame.width * 2, height: self.view.frame.height)
		
		PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.adjustToTheme))
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.emailAddressTextField.becomeFirstResponder()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	
	func centerLogo(completion: ((_ logoAnimator: UIViewPropertyAnimator) -> Void)?=nil) {
		
		self.view.addConstraint(self.logoCenteredConstraint)
		self.firstResponder?.resignFirstResponder()
		
		let animation = UIViewPropertyAnimator(duration: 0.75, dampingRatio: 0.8) { 
			self.view.layoutIfNeeded()
			
			self.signInLabel.alpha = 0
			self.createAccountLabel.alpha = 0
			self.emailAddressTextField.alpha = 0
			self.passwordTextField.alpha = 0
			self.confirmPasswordTextField.alpha = 0
			self.noHaveAccountButton.alpha = 0
			self.noWantAccountButton.alpha = 0
		}
		let logoFloat = UIViewPropertyAnimator(duration: 12 * ANIMATION_SPEED_MODIFIER, curve: .easeInOut) {
			self.logo.transform = CGAffineTransform(translationX: 0, y: 400)
		}
		logoFloat.startAnimation()
		Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { (timer) in
//			logoFloat.pauseAnimation()
			logoFloat.isReversed = !logoFloat.isReversed
//			logoFloat.startAnimation()
		}
		
		animation.addCompletion { (position) in
			if position == .end {
				
				self.signInLabel.isHidden = true
				self.createAccountLabel.isHidden = true
				self.emailAddressTextField.isHidden = true
				self.passwordTextField.isHidden = true
				self.confirmPasswordTextField.isHidden = true
				self.noHaveAccountButton.isHidden = true
				self.noWantAccountButton.isHidden = true
				
				completion?(logoFloat)
			}
		}
		animation.startAnimation()
	}
	func signIn() {
		
		self.centerLogo { (logoAnimator) in
			
			// make sign in request
			logoAnimator.stopAnimation(false)
			
			self.view.addConstraints([self.logoSettledBottomConstraint, self.logoSettledWidthConstraint])
			let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8, animations: {
				self.view.layoutIfNeeded()
			})
			
			animator.addCompletion({ (position) in
				if position == .end {
					self.performSegue(withIdentifier: "SignInSegue", sender: nil)
				}
			})
				
			animator.startAnimation()
		}
	}
	func createAccount() {
		
	}
	@IBAction func gotoCreateAccount() {
		
		self.scrollView.setContentOffset(CGPoint(x: self.view.frame.width, y: 0), animated: true)
	}
	
	override func adjustToTheme() {
		super.adjustToTheme()
		
		UIApplication.shared.statusBarStyle = ThemeKit.statusBarStyle
		
		self.view.backgroundColor = ThemeKit.backgroundColor
		
		self.signInLabel.textColor = ThemeKit.primaryTextColor
		self.createAccountLabel.textColor = ThemeKit.primaryTextColor
		
		self.emailAddressTextField.textColor = ThemeKit.primaryTextColor
		self.emailAddressTextField.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSForegroundColorAttributeName: ThemeKit.tertiaryTextColor])
		self.emailAddressTextField.keyboardAppearance = ThemeKit.keyboardAppearance
		
		self.passwordTextField.textColor = ThemeKit.primaryTextColor
		self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: ThemeKit.tertiaryTextColor])
		self.passwordTextField.keyboardAppearance = ThemeKit.keyboardAppearance
		
		self.confirmPasswordTextField.textColor = ThemeKit.primaryTextColor
		self.confirmPasswordTextField.keyboardAppearance = ThemeKit.keyboardAppearance
		self.confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName: ThemeKit.tertiaryTextColor])
		
		self.firstResponder?.resignFirstResponder()
		self.firstResponder?.becomeFirstResponder()
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AccountViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		if textField == self.emailAddressTextField {
			self.passwordTextField.becomeFirstResponder()
		}
		
		if textField == self.passwordTextField {
			if self.creatingAccount {
				
				self.confirmPasswordTextField.becomeFirstResponder()
			} else {
				self.signIn()
			}
		}
		
		if textField == self.confirmPasswordTextField {
			
			self.createAccount()
		}
		
		return true
	}
	func textFieldDidBeginEditing(_ textField: UITextField) {
		self.firstResponder = textField
	}
	func textFieldDidEndEditing(_ textField: UITextField) {
		self.firstResponder = nil
	}
}
