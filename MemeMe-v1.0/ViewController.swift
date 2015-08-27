//
//  ViewController.swift
//  MemeMe-v1.0
//
//  Created by Adrian Gherle on 8/21/15.
//  Copyright (c) 2015 Adrian Gherle. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                      UITextFieldDelegate {

    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraBtn: UIBarButtonItem!
    @IBOutlet weak var topTF: UITextField!
    @IBOutlet weak var bottomTF: UITextField!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    
    // Holds the textfields attributes
    let memeTextAtributes = [NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3,]

    
    //MARK: Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        
        // set the properties of the text fields
        topTF.delegate = self
        topTF.defaultTextAttributes = memeTextAtributes
        topTF.textAlignment = NSTextAlignment.Center
        topTF.text = "TOP"
        
        bottomTF.delegate = self
        bottomTF.defaultTextAttributes = memeTextAtributes
        bottomTF.textAlignment = NSTextAlignment.Center
        bottomTF.text = "BOTTOM"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraBtn.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true   // hide the status bar
    }
    
    
    //MARK: UITextFieldDelegate
    
    // Hide keyboard when return key is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == bottomTF {
            subscribeToKeyboardNotifications()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.clearsOnBeginEditing = false
        if textField == bottomTF {
            unsubscribeFromKeyboardNotifications()
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
    }

    
    //MARK: NSNotifications
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Move view up when keyboard is shown
    func keyboardWillShow (notification: NSNotification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    // Move view back down after keyboard is hidden
    func keyboardWillHide (notification: NSNotification) {
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
        
    }
    
    
    //MARK: IBAction
    
    @IBAction func share(sender: AnyObject) {
        let activityViewController = UIActivityViewController(activityItems: [generateMemedImage()],
            applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
        
        // save the meme only if shared
        activityViewController.completionWithItemsHandler = {(activity, success, items, error) in {
            if success {
                self.save()
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            }()
        }
    }
    
    // Reset to application to initial (launch) state
    @IBAction func cancelBtn(sender: AnyObject) {
        topTF.enabled = false
        bottomTF.enabled = false
        topTF.text = "TOP"
        bottomTF.text = "BOTTOM"
        topTF.clearsOnBeginEditing = true
        bottomTF.clearsOnBeginEditing = true
        shareBtn.enabled = false
        imagePickerView.image = nil
    }
    
    // Access the camera
    @IBAction func cameraButton(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    // Access the photo album
    @IBAction func photoAlbumButton(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    
    //MARK: UIImagePickerController
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imagePickerView.image = image
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        // enable editing the textFields and the share button after choosing a photo
        topTF.enabled = true
        bottomTF.enabled = true
        shareBtn.enabled = true
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: Save the meme
    
    func save () -> Meme {
        var meme = Meme(topText: topTF.text, bottomText: bottomTF.text, image: imagePickerView.image!,
            memedImage: generateMemedImage())
        return meme
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navigation bar
        navigationBar.hidden = true
        toolbar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navigation bar
        navigationBar.hidden = false
        toolbar.hidden = false
        
        return memedImage
    }
}


// A Meme struct to help save the Meme object
struct Meme {
    var topText: String
    var bottomText: String
    var image: UIImage
    var memedImage: UIImage
}
