//
//  ViewController.swift
//  MemeMe-v1.0
//
//  Created by Adrian Gherle on 8/21/15.
//  Copyright (c) 2015 Adrian Gherle. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraBtn: UIBarButtonItem!
    @IBOutlet weak var topTF: UITextField!
    @IBOutlet weak var bottomTF: UITextField!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    
    // holds the textfields attributes
    let memeTextAtributes = [NSStrokeColorAttributeName: UIColor.blackColor(), NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!, NSStrokeWidthAttributeName: -3,]

    
    //MARK: Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.delegate = self
        
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == bottomTF {
            self.subscribeToKeyboardNotifications()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.clearsOnBeginEditing = false
        if textField == bottomTF {
            self.unsubscribeFromKeyboardNotifications()
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }

    
    //MARK: NSNotifications
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow (notification: NSNotification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func keyboardWillHide (notification: NSNotification) {
        self.view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
        
    }
    
    
    //MARK: IBAction
    
    
    @IBAction func share(sender: AnyObject) {
        var savedMeme = save()
        let activityViewController = UIActivityViewController(activityItems: [savedMeme.memedImage],
            applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
        
//        activityViewController.completionWithItemsHandler = {(activity, success, items, error) in {
//            self.save()
//            self.dismissViewControllerAnimated(true, completion: nil)
//            }()
//        }
    }
    
    
    @IBAction func cancelBtn(sender: AnyObject) {
        
    }
    
    
    @IBAction func cameraButton(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func photoAlbumButton(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    //MARK: UIImagePickerController
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imagePickerView.image = image

        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        // enable editing the textField after choosing a photo
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
        self.navigationBar.hidden = true
        self.toolbar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navigation bar
        self.navigationBar.hidden = false
        self.toolbar.hidden = false
        
        return memedImage
    }
    
    
    

}


struct Meme {
    var topText: String
    var bottomText: String
    var image: UIImage
    var memedImage: UIImage
}




