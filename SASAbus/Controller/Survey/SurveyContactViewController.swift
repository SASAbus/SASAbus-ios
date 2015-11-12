//
// SurveyContactViewController.swift
// SASAbus
//
// Copyright (C) 2011-2015 Raiffeisen Online GmbH (Norman Marmsoler, Jürgen Sprenger, Aaron Falk) <info@raiffeisen.it>
//
// This file is part of SASAbus.
//
// SASAbus is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SASAbus is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SASAbus.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import SwiftValidator
import Alamofire

class SurveyContactViewController: MasterViewController, ValidationDelegate, UITextFieldDelegate {

    @IBOutlet weak var surveyTitleView: UIView!
    @IBOutlet weak var surveyTitle: UILabel!
    @IBOutlet weak var surveyContactDescription: UILabel!
    @IBOutlet weak var emailContact: UITextField!
    @IBOutlet weak var phoneContact: UITextField!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var errorLabelEmail: UILabel!
    @IBOutlet weak var errorLabelPhone: UILabel!
    var surveyData = [String: AnyObject]()
    
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.surveyTitleView.backgroundColor = Theme.colorDarkGrey
        self.surveyTitle.textColor = Theme.colorWhite
        self.surveyContactDescription.textColor = Theme.colorDarkGrey
        self.noButton.tintColor = Theme.colorDarkGrey
        self.noButton.layer.borderColor = Theme.colorOrange.CGColor
        self.noButton.layer.borderWidth = 1
        self.noButton.tag = 0
        self.yesButton.tintColor = Theme.colorDarkGrey
        self.yesButton.layer.borderColor = Theme.colorOrange.CGColor
        self.yesButton.layer.borderWidth = 1
        self.yesButton.tag = 1
        self.emailContact.delegate = self
        self.phoneContact.delegate = self
        self.phoneContact.returnKeyType = UIReturnKeyType.Done
        self.resetForm()
        
        self.surveyData["email"] = ""
        self.surveyData["phone"] = ""
        
        let emailPlaceholder = NSAttributedString(string: NSLocalizedString("E-Mail Address", comment: ""), attributes: [NSForegroundColorAttributeName : Theme.colorLightGrey])
        self.emailContact.attributedPlaceholder = emailPlaceholder;
        let phonePlaceholder = NSAttributedString(string: NSLocalizedString("Phone Number", comment: ""), attributes: [NSForegroundColorAttributeName : Theme.colorLightGrey])
        self.phoneContact.attributedPlaceholder = phonePlaceholder;
        
        self.surveyContactDescription.text = String(self.surveyData["secondQuestion"])
        self.surveyTitle.text = NSLocalizedString("Shortsurvey", comment: "")
        self.noButton.setTitle(NSLocalizedString("cancel", comment: ""), forState: .Normal)
        self.yesButton.setTitle(NSLocalizedString("send", comment: ""), forState: .Normal)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.emailContact.resignFirstResponder()
        self.phoneContact.resignFirstResponder()
    }
    
    private func resetForm() {
        self.emailContact.textColor = Theme.colorDarkGrey
        self.phoneContact.textColor = Theme.colorDarkGrey
        self.emailContact.layer.borderColor = Theme.colorDarkGrey.CGColor
        self.phoneContact.layer.borderColor = Theme.colorDarkGrey.CGColor
        self.errorLabelEmail.hidden = true
        self.errorLabelPhone.hidden = true
        self.validator.registerField(self.emailContact, errorLabel: errorLabelEmail, rules: [RequiredRule(), EmailRule(message: NSLocalizedString("Invalid email", comment: ""))])
        self.validator.registerField(self.phoneContact, errorLabel: errorLabelPhone, rules: [RequiredRule(), PhoneNumberRule(message: NSLocalizedString("Not a valid phone number", comment: ""))])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func finishSurvey(sender: UIButton) {
        if sender.tag == 1 {
            self.preValidate()
            self.validator.validate(self)
        } else {
            self.insertSurvey()
        }
    }
    
    func validationSuccessful() {
        self.surveyData["email"] = self.emailContact.text
        self.surveyData["phone"] = self.phoneContact.text
        self.insertSurvey()
    }
    
    func insertSurvey() {
        self.surveyData.removeValueForKey("secondQuestion")
        Alamofire.request(SurveyApiRouter.InsertSurvey(self.surveyData)).responseJSON { response in }
        let vc = LineViewController(nibName: "LineViewController", title: nil)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.navigateTo(vc)
    }
    
    func validationFailed(errors:[UITextField:ValidationError]) {
        for (field, error) in validator.errors {
            field.layer.borderColor = UIColor.redColor().CGColor
            field.layer.borderWidth = 1.0
            field.layer.cornerRadius = 5.0
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.hidden = false
            error.errorLabel?.textColor = Theme.colorDarkGrey
        }
    }

    private func preValidate() {
        let email = self.emailContact.text
        let phone = self.phoneContact.text
        self.resetForm()
        if email != "" || phone != "" {
            if email == "" {
                validator.unregisterField(self.emailContact)
            }
            
            if phone == "" {
                validator.unregisterField(self.phoneContact)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.track("SurveyContact")
    }
}
