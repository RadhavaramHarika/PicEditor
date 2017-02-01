//
//  PickImageViewController.swift
//  PicEditor
//
//  Created by radhavaram harika on 1/30/17.
//  Copyright © 2017 Practise. All rights reserved.
//

import UIKit

class PickImageViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var photoNameTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    let alert = AlertController()
    var pickedImage: UIImage!
    var buttonTitle: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        loading.isHidden = true
        photoNameTextField.delegate = self
        setButtonProperties(cameraButton)
        setButtonProperties(albumButton)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToKeyboardNotification()
    }
    
    func setNavigationBar(){
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
    
    func pickAnImage(source: UIImagePickerControllerSourceType)
    {
        let pickerVC = UIImagePickerController()
        pickerVC.delegate = self
        pickerVC.sourceType = source
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    func setButtonProperties(_ sender: UIButton){
        sender.layer.borderWidth = 5
        sender.layer.borderColor = UIColor(red: 212.0/255.0, green: 222.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
        sender.layer.cornerRadius = 10
        sender.clipsToBounds = true
    }
    
    
    @IBAction func cameraPressed(_ sender: Any) {
        
        pickAnImage(source: .camera)
    }
    
    @IBAction func albumAction(_ sender: Any) {
       
        pickAnImage(source: .photoLibrary)
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        if (photoNameTextField.text?.isEmpty)!{
            alert.displayAlertView(viewController: self, alertTitle: "Pic Editor", alertMessage: "Please enter any text")
        }
        else{
        loading.isHidden = false
        loading.startAnimating()
        self.view.bringSubview(toFront: loading)
        if Reachability.isConnectedToNetwork(){
            Flickr.shareInstance().getPhotosWithPages(text: photoNameTextField.text!){(success, error) in
                
                if error == nil{
                    // open SelectCollectionView
                    DispatchQueue.main.async {
                        self.loading.stopAnimating()
                        self.loading.isHidden = true
                        self.openSelectionViewController()
                    }
                }
                else{
                    DispatchQueue.main.async {
                        //show alert
                        self.loading.stopAnimating()
                        self.loading.isHidden = true
                        self.alert.displayAlertView(viewController: self, alertTitle: "Pic Editor", alertMessage: (error?.localizedDescription)!)
                    }
                }
            }
        }else{
            DispatchQueue.main.async {
                //ShowAlert
                self.loading.stopAnimating()
                self.loading.isHidden = true
                self.alert.displayAlertView(viewController: self, alertTitle:"No Network", alertMessage: "Make sur your device is connected to network")
            }
        }
        }
    }
    
    func openSelectionViewController(){
        let selectViewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectCollectionVC") as! SelectPictureCollectionViewController
        selectViewController.buttonTitle = buttonTitle
        selectViewController.photoTitle = photoNameTextField.text
        self.navigationController?.pushViewController(selectViewController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            pickedImage = image
            //open picEditor VC
            self.openPicEditorViewController(selectedImage: pickedImage!, withButtonTitle: self.buttonTitle)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func openPicEditorViewController(selectedImage: UIImage, withButtonTitle: String) {
        
        if withButtonTitle == "Filters"{
            
            let editorVC = self.storyboard?.instantiateViewController(withIdentifier: "FiltersEditVC") as! FilterEditViewController
            editorVC.selectedImage = selectedImage
            
            self.navigationController?.pushViewController(editorVC, animated: true)
        }
        else if withButtonTitle == "Draw"{
            
            let editorVC = self.storyboard?.instantiateViewController(withIdentifier: "DrawEditVC") as! DrawEditViewController
            editorVC.selectedImage = selectedImage
            self.navigationController?.pushViewController(editorVC, animated: true)
        }
        else{
            
            let editorVC = self.storyboard?.instantiateViewController(withIdentifier: "TextEditVC") as! TextEditViewController
            editorVC.selectedImage = selectedImage
            self.navigationController?.pushViewController(editorVC, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func keyBoardWillShow(_ notification:Notification)
    {
        view.frame.origin.y = 0 - getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat
    {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotification()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    func unSubscribeToKeyboardNotification()
    {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        
    }


}
