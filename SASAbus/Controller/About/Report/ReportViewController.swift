//
// InfoViewController.swift
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
import RxSwift
import RxCocoa

class ReportViewController: MasterViewController, UIToolbarDelegate, UITextViewDelegate,
        UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var placeHolderText = "Placeholder Text..."

    var typeOptions = ["Report a bug", "Suggest a feature"]

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var chooseTypeView: UIView!
    @IBOutlet weak var chooseTypeInput: UITextField!

    @IBOutlet weak var messageText: UITextView!

    @IBOutlet weak var image1: UIView!
    @IBOutlet weak var image2: UIView!
    @IBOutlet weak var image3: UIView!
    @IBOutlet weak var image4: UIView!
    @IBOutlet weak var image5: UIView!

    @IBOutlet weak var image1Button: UIButton!
    @IBOutlet weak var image2Button: UIButton!
    @IBOutlet weak var image3Button: UIButton!
    @IBOutlet weak var image4Button: UIButton!
    @IBOutlet weak var image5Button: UIButton!

    @IBOutlet weak var image1Image: UIImageView!
    @IBOutlet weak var image2Image: UIImageView!
    @IBOutlet weak var image3Image: UIImageView!
    @IBOutlet weak var image4Image: UIImageView!
    @IBOutlet weak var image5Image: UIImageView!

    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailText: UITextField!

    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameText: UITextField!

    var imagePicker = UIImagePickerController()
    var datePicker: UIPickerView!

    var selectedCategory: Int = 0

    var selectedImage: UIImageView?
    var selectedButton: UIButton?

    var selectedImagePaths: [URL] = []

    var submitMenuButton: UIBarButtonItem!


    init(title: String?) {
        super.init(nibName: "ReportViewController", title: title)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        self.deleteAllPictures()

        NotificationCenter.default.removeObserver(self)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        messageText.delegate = self
        imagePicker.delegate = self

        chooseTypeView.layer.cornerRadius = 4
        messageText.layer.cornerRadius = 4

        emailView.layer.cornerRadius = 4

        chooseTypeView.layer.borderColor = Color.borderColor.cgColor
        chooseTypeView.layer.borderWidth = 1

        messageText.layer.borderColor = Color.borderColor.cgColor
        messageText.layer.borderWidth = 1

        makeButton(view: image1, button: image1Button, image: image1Image)
        makeButton(view: image2, button: image2Button, image: image2Image)
        makeButton(view: image3, button: image3Button, image: image3Image)
        makeButton(view: image4, button: image4Button, image: image4Image)
        makeButton(view: image5, button: image5Button, image: image5Image)

        makePicker()

        nameView.layer.borderColor = Color.borderColor.cgColor
        nameView.layer.borderWidth = 1

        emailView.layer.borderColor = Color.borderColor.cgColor
        emailView.layer.borderWidth = 1

        submitMenuButton = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(submitClick))
        navigationItem.setRightBarButton(submitMenuButton, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        messageText.text = placeHolderText
        messageText.textColor = UIColor.lightGray

        registerKeyboardNotifications()
    }


    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        messageText.textColor = UIColor.black

        if messageText.text == placeHolderText {
            messageText.text = ""
        }

        return true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            messageText.text = placeHolderText
            messageText.textColor = UIColor.lightGray
        }
    }


    func makeButton(view: UIView, button: UIButton, image: UIImageView) {
        let border = CAShapeLayer()
        border.strokeColor = Color.borderColor.cgColor
        border.fillColor = nil
        border.lineDashPattern = [4, 4]
        border.path = UIBezierPath(roundedRect: view.bounds, cornerRadius: 4).cgPath
        border.frame = view.bounds

        view.layer.addSublayer(border)

        let buttonImage = UIImage(named: "ic_add_white")!.withRenderingMode(.alwaysTemplate)

        button.setImage(buttonImage, for: .normal)
        button.tintColor = UIColor.lightGray

        view.layer.cornerRadius = 4

        image.layer.cornerRadius = 4
        image.layer.masksToBounds = false

        image.clipsToBounds = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(pickImageFromImage(sender:)))
        image.addGestureRecognizer(tap)
        image.isUserInteractionEnabled = true
    }

    func makePicker() {
        datePicker = UIPickerView(frame: CGRect.zero)
        datePicker.dataSource = self
        datePicker.delegate = self

        datePicker.showsSelectionIndicator = true

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()

        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(pickerDoneClick))

        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        chooseTypeInput.inputView = datePicker
        chooseTypeInput.inputAccessoryView = toolBar
    }

    func pickerDoneClick() {
        selectedCategory = datePicker.selectedRow(inComponent: 0)
        let option = typeOptions[selectedCategory]
        chooseTypeInput.text = option

        chooseTypeInput.endEditing(false)
    }

    func pickImageFromImage(sender: UITapGestureRecognizer) {
        if let image = sender.view as? UIImageView {
            selectedImage = image
        } else {
            return
        }

        if selectedImage!.image == nil {
            return
        }

        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true)
    }

    func deleteAllPictures() {
        selectedImagePaths.removeAll()

        // Delete old image in case it exists
        let fileManager = FileManager.default

        for i in 1..<6 {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let imagePath = documents.appendingPathComponent("image_\(i).jpg")

            if fileManager.fileExists(atPath: imagePath.path) {
                Log.info("Deleting old image '\(imagePath)'")

                do {
                    try fileManager.removeItem(at: imagePath)
                } catch let error {
                    print("Could not delete old image '\(imagePath)': \(error)")
                }
            }
        }
    }


    @IBAction func pickImage(_ sender: UIButton) {
        selectedButton = sender

        switch sender {
        case image1Button:
            selectedImage = image1Image
        case image2Button:
            selectedImage = image2Image
        case image3Button:
            selectedImage = image3Image
        case image4Button:
            selectedImage = image4Image
        case image5Button:
            selectedImage = image5Image
        default:
            fatalError()
        }

        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true)
    }

    @IBAction func submitClick(_ sender: Any?) {
        submitMenuButton.isEnabled = false

        let body = Body(
                name: nameText.text!,
                email: emailText.text!,
                message: messageText.text,
                category: selectedCategory
        )

        _ = ReportApi.upload(body, images: selectedImagePaths)
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { _ in
                    Log.error("Upload success")

                    self.submitMenuButton.isEnabled = true

                    self.deleteAllPictures()

                    let alert = UIAlertController(
                            title: "Thanks!",
                            message: "We will get back to you as soon as possible.",
                            preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { action in
                        // TODO dismiss this view controller and go back to about
                    }))

                    self.present(alert, animated: true, completion: nil)
                }, onError: { error in
                    Log.error("Upload failed: \(error)")

                    self.submitMenuButton.isEnabled = true

                    let alert = UIAlertController(
                            title: "Upload failed",
                            message: "Please retry in a few minutes",
                            preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))

                    self.present(alert, animated: true, completion: nil)
                })
    }


    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)),
                name: NSNotification.Name.UIKeyboardDidShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size

        // Get the existing contentInset for the scrollView and set the bottom property to be the height of the keyboard
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardSize.height

        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = contentInset
    }

    func keyboardWillHide(notification: NSNotification) {
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = 0

        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }


    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typeOptions[row]
    }


    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            Log.error("No image picked")
            return
        }

        selectedImage?.contentMode = .scaleToFill
        selectedImage?.image = pickedImage

        selectedButton?.isHidden = true

        var fileName: String

        switch selectedImage! {
        case image1Image:
            fileName = "image_1.jpg"
        case image2Image:
            fileName = "image_2.jpg"
        case image3Image:
            fileName = "image_3.jpg"
        case image4Image:
            fileName = "image_4.jpg"
        case image5Image:
            fileName = "image_5.jpg"
        default:
            fatalError()
        }

        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagePath = documents.appendingPathComponent(fileName)


        // Delete old image in case it exists
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: imagePath.path) {
            Log.info("Deleting old image '\(imagePath)'")

            do {
                try fileManager.removeItem(at: imagePath)
            } catch let error {
                print("Could not delete old image '\(imagePath)': \(error)")
            }
        }

        // Write new image
        if let data = UIImageJPEGRepresentation(pickedImage, 80) {
            do {
                try data.write(to: imagePath, options: .atomic)

                selectedImagePaths.append(imagePath)

                Log.info("Saved image to temporary path '\(imagePath)'")
            } catch let error {
                Log.error("Unable to write image: \(error)")
            }
        }

        imagePicker.dismiss(animated: true)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true)
    }
}
