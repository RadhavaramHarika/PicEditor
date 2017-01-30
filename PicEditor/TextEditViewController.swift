//
//  TextEditViewController.swift
//  PicEditor
//
//  Created by radhavaram harika on 1/30/17.
//  Copyright © 2017 Practise. All rights reserved.
//

import UIKit

class TextEditViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageToEdit: UIImageView!
    @IBOutlet weak var textViewToolBar: UIToolbar!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var textViewScrollView: UIScrollView!
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    var selectedImage: UIImage!
    
    var xCoord = 5
    var yCoord = 5
    let buttonWidth = 90
    let buttonHeight = 90
    let gapBetweenButtons = 5
    
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    
    let colors:[(CGFloat,CGFloat,CGFloat)] = [(0,0,0),(105.0/255.0,105.0/255.0,105.0/255.0),(1.0,0,0),(0,0,1.0),(51.0/255.0,204.0/255.0,1.0),(102.0/255.0,204.0/255.0,0),(102.0/255.0,1.0,0),(160.0/255.0,82.0/255.0,45.0/255.0),(1.0,102.0/255.0,0),(1.0,1.0,0),(1.0,1.0,1.0)]
    
    let fontNames:[String] = ["Arial","Helvetica","Didot","Papyrus","Menlo","Baskerville","Verdana","Times New Roman","Copperplate","Courier New"]
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageToEdit.image = selectedImage
        setNavigationBar()
        textViewScrollView.isScrollEnabled = true
        textViewScrollView.showsHorizontalScrollIndicator = true
        textViewScrollView.isUserInteractionEnabled = true
        setDefaultTextFieldProperties(textField: topTextField, defaultTextFieldText: "Top text")
        setDefaultTextFieldProperties(textField: bottomTextField, defaultTextFieldText: "Bottom text")
        createDefaultScrollView()
        subscribeToKeyboardNotification()
    }
    
    func setNavigationBar(){
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 250.0,green: 233.0,blue: 126.0,alpha: 1.0)
        self.navigationItem.hidesBackButton = false
        let share = UIBarButtonItem(title: "share", style: UIBarButtonItemStyle.plain, target: self, action: #selector(shareAction))
        
        let save = UIBarButtonItem(title: "save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveAction))
        navigationItem.rightBarButtonItems = [save,share]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unSubscribeToKeyboardNotification()
    }
    
    func setDefaultTextFieldProperties(textField: UITextField,defaultTextFieldText: String)
    {
        setTextFieldProperties(textField: textField, color: nil, font: nil)
        textField.text = defaultTextFieldText
        textField.autocapitalizationType = .allCharacters
        textField.delegate = self
        textField.keyboardType = UIKeyboardType.default
        textField.backgroundColor = UIColor.clear
        textField.textAlignment = NSTextAlignment.center
        view.bringSubview(toFront: textField)
    }
    
    func textColorAction(){
        
        textViewScrollView.contentSize = CGSize.zero
        xCoord = 5
        yCoord = 5
        var item = 0
        for i in 0..<colors.count{
            item = i
            let textColorBtn = UIButton(type: .custom)
            textColorBtn.frame = CGRect(x: xCoord,y: yCoord, width: buttonWidth, height: buttonHeight)
            textColorBtn.addTarget(self, action: #selector(textColorBtnTapped), for: .touchUpInside)
            textColorBtn.clipsToBounds = true
            textColorBtn.tag = item
            textColorBtn.layer.cornerRadius = 5
            textColorBtn.layer.borderWidth = 2
            textColorBtn.layer.borderColor = UIColor.white.cgColor
            (red, green,blue) = colors[item]
            textColorBtn.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            
            xCoord += buttonWidth + gapBetweenButtons
            textViewScrollView.addSubview(textColorBtn)
        }
        
        let x = Double(buttonWidth) * Double(item + 2)
        textViewScrollView.isScrollEnabled = true
        textViewScrollView.showsHorizontalScrollIndicator = true
        textViewScrollView.isUserInteractionEnabled = true
        textViewScrollView.contentSize = CGSize(width: CGFloat(x),height: CGFloat(yCoord))
    }
    
    func createDefaultScrollView(){
        
        textViewScrollView.contentSize = CGSize.zero
        xCoord = 5
        yCoord = 5
        var item = 0
        for i in 0..<fontNames.count{
            item = i
            let textFontBtn = UIButton(type: .custom)
            textFontBtn.frame = CGRect(x: xCoord,y: yCoord, width: buttonWidth, height: buttonHeight)
            textFontBtn.addTarget(self, action: #selector(textFontBtnTapped), for: .touchUpInside)
            textFontBtn.clipsToBounds = true
            textFontBtn.tag = item
            textFontBtn.layer.cornerRadius = 5
            textFontBtn.layer.borderWidth = 2
            textFontBtn.layer.borderColor = UIColor.white.cgColor
            let fontName = fontNames[item] as String
            textFontBtn.titleLabel?.font = UIFont(name: fontName, size: 20)
            print("\(textFontBtn.titleLabel?.font)")
            textFontBtn.setTitle("abc", for: .normal)
            textFontBtn.setTitleColor(UIColor(red: 212.0/255.0, green: 222.0/255.0,blue: 39.0/255.0,alpha:1.0), for: .normal)
            textFontBtn.backgroundColor = UIColor(red: 39.0/255.0, green: 53.0/255.0, blue: 121.0/255.0, alpha: 1.0)
            
            xCoord += buttonWidth + gapBetweenButtons
            textViewScrollView.addSubview(textFontBtn)
        }
        
        let x = Double(buttonWidth) * Double(item + 2)
        textViewScrollView.isScrollEnabled = true
        textViewScrollView.showsHorizontalScrollIndicator = true
        textViewScrollView.isUserInteractionEnabled = true
        textViewScrollView.contentSize = CGSize(width: CGFloat(x),height: CGFloat(yCoord))
    }
    
    func textFontBtnTapped(_ sender: UIButton){
        
        let fontName = fontNames[sender.tag]
        UserDefaults.standard.set(fontName, forKey: "textFontName")
        UserDefaults.standard.set(true, forKey: "FontName")
        setTextFieldProperties(textField: topTextField, color: nil, font: UIFont(name: fontName, size: 40))
        setTextFieldProperties(textField: bottomTextField, color: nil, font: UIFont(name: fontName, size: 40))
    }
    
    func textColorBtnTapped(_ sender: UIButton){
        let index = sender.tag
        UserDefaults.standard.set(index, forKey: "textColor")
        UserDefaults.standard.set(true, forKey: "Color")
        setTextFieldProperties(textField: topTextField, color: sender.backgroundColor, font: nil)
        setTextFieldProperties(textField: bottomTextField, color: sender.backgroundColor, font: nil)
    }
    
    func setTextFieldProperties(textField: UITextField,color: UIColor?, font: UIFont?){
        
        let colorName:UIColor!
        if color == nil{
            let didSetColorAlready = UserDefaults.standard.bool(forKey: "Color")
            if didSetColorAlready{
                let indx = UserDefaults.standard.value(forKey: "textColor") as! Int
                (red, green, blue) = colors[indx]
                colorName = UIColor(red: red,green: green,blue: blue,alpha: 1.0)
            }
            else{
                colorName = UIColor.white
            }
        }
        else{
            colorName = color
        }
        
        let fontName:String!
        if font == nil{
            let didSetFontAlready = UserDefaults.standard.bool(forKey: "FontName")
            if didSetFontAlready{
                if let ft = UserDefaults.standard.value(forKey: "textFontName") as! String!{
                    fontName = ft
                }
                else{
                    fontName = "HelveticaNeue-CondensedBlack"
                }
            }
            else{
                fontName = "HelveticaNeue-CondensedBlack"
            }
        }
        else{
            fontName = font?.familyName
        }
        
        let textFieldAttributes:[String:Any] = [
            NSForegroundColorAttributeName:colorName,
            NSStrokeColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: fontName, size: 40)!,
            NSStrokeWidthAttributeName: -2.0]
        textField.defaultTextAttributes = textFieldAttributes
    }
    
    func saveAction(){
        
        let imageToSave = generateEdittedImage()
        let dataFromImage:Data! = UIImagePNGRepresentation(imageToSave)
        
        let savedPicture = SavedPicture(imageData: dataFromImage as NSData, context: self.stack.context)
        stack.save()
    }
    
    func generateEdittedImage() -> UIImage{
        
        UIGraphicsBeginImageContext(imageToEdit.bounds.size)
        imageToEdit.image?.draw(in: CGRect(x: 0, y: 0,
                                           width: imageToEdit.frame.size.width, height: imageToEdit.frame.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func shareAction() {
        
        let editedPic = generateEdittedImage()
        
        let activityVC: UIActivityViewController = UIActivityViewController(activityItems:[editedPic], applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.mail]
        self.present(activityVC, animated: true, completion: nil)
        
        activityVC.completionWithItemsHandler = UIActivityViewControllerCompletionWithItemsHandler?{(activityType: UIActivityType?,completed: Bool,returnedItems: [Any]?,error: Error?) in
            
            if completed
            {
                self.saveAction()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func textFontAction(_ sender: Any) {
        createDefaultScrollView()
    }
    
    @IBAction func textColorAction(_ sender: Any) {
        textColorAction()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField.text == "Top text"||textField.text == "Bottom text"
        {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func keyBoardWillShow(_ notification:Notification)
    {
        if bottomTextField.isFirstResponder
        {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
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
