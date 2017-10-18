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

        self.surveyTitleView.backgroundColor = Theme.darkGrey
        self.surveyTitle.textColor = Theme.white
        self.surveyContactDescription.textColor = Theme.darkGrey
        self.noButton.tintColor = Theme.darkGrey
        self.noButton.layer.borderColor = Theme.orange.cgColor
        self.noButton.layer.borderWidth = 1
        self.noButton.tag = 0
        self.yesButton.tintColor = Theme.darkGrey
        self.yesButton.layer.borderColor = Theme.orange.cgColor
        self.yesButton.layer.borderWidth = 1
        self.yesButton.tag = 1
        self.emailContact.delegate = self
        self.phoneContact.delegate = self
        self.phoneContact.returnKeyType = UIReturnKeyType.done
        self.resetForm()

        self.surveyData["email"] = "" as AnyObject?
        self.surveyData["phone"] = "" as AnyObject?

        let emailPlaceholder = NSAttributedString(string: NSLocalizedString("E-Mail Address", comment: ""),
                attributes: [NSForegroundColorAttributeName: Theme.lightGrey])

        self.emailContact.attributedPlaceholder = emailPlaceholder
        let phonePlaceholder = NSAttributedString(string: NSLocalizedString("Phone Number", comment: ""),
                attributes: [NSForegroundColorAttributeName: Theme.lightGrey])

        self.phoneContact.attributedPlaceholder = phonePlaceholder

        self.surveyContactDescription.text = String(describing: self.surveyData["secondQuestion"])
        self.surveyTitle.text = NSLocalizedString("Shortsurvey", comment: "")
        self.noButton.setTitle(NSLocalizedString("cancel", comment: ""), for: UIControlState())
        self.yesButton.setTitle(NSLocalizedString("send", comment: ""), for: UIControlState())
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.emailContact.resignFirstResponder()
        self.phoneContact.resignFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.track("SurveyContact")
    }


    @IBAction func finishSurvey(_ sender: UIButton) {
        if sender.tag == 1 {
            self.preValidate()
            self.validator.validate(self)
        } else {
            self.insertSurvey()
        }
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func validationSuccessful() {
        self.surveyData["email"] = self.emailContact.text as AnyObject?
        self.surveyData["phone"] = self.phoneContact.text as AnyObject?
        self.insertSurvey()
    }

    func insertSurvey() {
        self.surveyData.removeValue(forKey: "secondQuestion")

        Alamofire.request(SurveyApiRouter.insertSurvey(self.surveyData)).responseJSON { response in
        }

        let vc = LineViewController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        appDelegate.navigateTo(vc)
    }

    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (_, error) in validator.errors {
            // TODO

            /*field.layer.borderColor = UIColor.redColor().CGColor
            field.layer.borderWidth = 1.0
            field.layer.cornerRadius = 5.0*/

            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.isHidden = false
            error.errorLabel?.textColor = Theme.darkGrey
        }
    }


    fileprivate func resetForm() {
        self.emailContact.textColor = Theme.darkGrey
        self.phoneContact.textColor = Theme.darkGrey

        self.emailContact.layer.borderColor = Theme.darkGrey.cgColor
        self.phoneContact.layer.borderColor = Theme.darkGrey.cgColor

        self.errorLabelEmail.isHidden = true
        self.errorLabelPhone.isHidden = true

        self.validator.registerField(self.emailContact, errorLabel: errorLabelEmail,
                rules: [RequiredRule(), EmailRule(message: NSLocalizedString("Invalid email", comment: ""))])
        self.validator.registerField(self.phoneContact, errorLabel: errorLabelPhone,
                rules: [RequiredRule(), PhoneNumberRule(message: NSLocalizedString("Not a valid phone number", comment: ""))])
    }

    fileprivate func preValidate() {
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
}
