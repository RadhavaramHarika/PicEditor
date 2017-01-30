//
//  DrawEditViewController.swift
//  PicEditor
//
//  Created by radhavaram harika on 1/30/17.
//  Copyright © 2017 Practise. All rights reserved.
//

import UIKit

class DrawEditViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editorImage: UIImageView!
    @IBOutlet weak var tempDrawImage: UIImageView!
    @IBOutlet weak var drawPadToolBar: UIToolbar!
    @IBOutlet weak var drawColorsScrollView: UIScrollView!
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    var selectedImage: UIImage!
    var lastPoint = CGPoint.zero
    var red:CGFloat = 0.0
    var blue:CGFloat = 0.0
    var green:CGFloat = 0.0
    var brushWidth:CGFloat = 10.0
    var opacity:CGFloat = 1.0
    var swiped = false
    
    var xCoord = 5
    var yCoord = 5
    let buttonWidth = 90
    let buttonHeight = 90
    let gapBetweenButtons = 5
    
    let colors:[(CGFloat,CGFloat,CGFloat)] = [(0,0,0),(105.0/255.0,105.0/255.0,105.0/255.0),(1.0,0,0),(0,0,1.0),(51.0/255.0,204.0/255.0,1.0),(102.0/255.0,204.0/255.0,0),(102.0/255.0,1.0,0),(160.0/255.0,82.0/255.0,45.0/255.0),(1.0,102.0/255.0,0),(1.0,1.0,0),(1.0,1.0,1.0)]
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        //        settingsViewForDrawing.isHidden = true
        editorImage.image = selectedImage
        drawColorsScrollView.isScrollEnabled = true
        drawColorsScrollView.showsHorizontalScrollIndicator = true
        createButtonsInDrawScrollView()
    }
    
    func setNavigationBar(){
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = false
        let share = UIBarButtonItem(title: "share", style: UIBarButtonItemStyle.plain, target: self, action: #selector(shareAction))
        
        let save = UIBarButtonItem(title: "save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveAction))
        navigationItem.rightBarButtonItems = [save,share]
    }
    
    func createButtonsInDrawScrollView(){
        
        drawColorsScrollView.contentSize = CGSize.zero
        var item = 0
        for i in 0..<colors.count{
            item = i
            let colorBtn = UIButton(type: .custom)
            colorBtn.frame = CGRect(x: xCoord,y: yCoord, width: buttonWidth, height: buttonHeight)
            colorBtn.addTarget(self, action: #selector(drawColorBtnAction), for: .touchUpInside)
            colorBtn.clipsToBounds = true
            colorBtn.tag = item
            colorBtn.layer.cornerRadius = 5
            colorBtn.layer.borderWidth = 2
            colorBtn.layer.borderColor = UIColor(red: 39.0, green: 53.0, blue: 121.0, alpha: 1.0).cgColor
            let (redColor, greenColor,blueColor) = colors[i]
            colorBtn.backgroundColor = UIColor(red: redColor, green: greenColor, blue: blueColor, alpha: 1.0)
            
            xCoord += buttonWidth + gapBetweenButtons
            drawColorsScrollView.addSubview(colorBtn)
        }
        
        let x = Double(buttonWidth) * Double(item + 2)
        drawColorsScrollView.isScrollEnabled = true
        drawColorsScrollView.showsHorizontalScrollIndicator = true
        drawColorsScrollView.contentSize = CGSize(width: CGFloat(x),height: CGFloat(yCoord))
    }
    
    func drawColorBtnAction(_ sender:UIButton){
        
        var ind = sender.tag ?? 0
        if ind < 0 || ind >= colors.count{
            ind = 0
        }
        
        (red,green,blue) = colors[ind]
        
        if ind == colors.count - 1{
            opacity = 1.0
        }
                
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        swiped = false
        if let touch = touches.first! as? UITouch{
            lastPoint = touch.location(in: tempDrawImage)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        swiped = true
        if let touch = touches.first! as? UITouch{
            let currentPoint = touch.location(in: tempDrawImage)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !swiped{
            UIGraphicsBeginImageContext(tempDrawImage.frame.size)
            let context = UIGraphicsGetCurrentContext()
            
            tempDrawImage.image?.draw(in: CGRect(x: 0,y: 0, width: tempDrawImage.frame.size.width, height: tempDrawImage.frame.size.height))
            
            context?.setLineCap(.round)
            
            context?.setLineWidth(brushWidth)
            
            context?.setStrokeColor(red: red, green: green, blue: blue, alpha: opacity)
            
            context?.move(to: lastPoint)
            context?.addLine(to: lastPoint)
            
            context?.strokePath()
            context?.flush()
            self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
        }
        
        UIGraphicsBeginImageContext(editorImage.frame.size)
        editorImage.image?.draw(in: CGRect(x: 0,y: 0, width: tempDrawImage.frame.size.width, height: tempDrawImage.frame.size.height), blendMode: .normal, alpha: 1.0)
        tempDrawImage.image?.draw(in: CGRect(x: 0, y: 0, width: tempDrawImage.frame.size.width, height: tempDrawImage.frame.size.height), blendMode: .normal, alpha: opacity)
        editorImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempDrawImage.image = nil
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint){
        
        UIGraphicsBeginImageContext(tempDrawImage.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempDrawImage.image?.draw(in: CGRect(x: 0, y: 0, width: tempDrawImage.frame.size.width, height: tempDrawImage.frame.size.height))
        
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        
        context?.setLineCap(.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context?.setBlendMode(.normal)
        
        context?.strokePath()
        
        tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext()
        tempDrawImage.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    @IBAction func erasePressed(_ sender: Any) {
        
        editorImage.image = nil
        editorImage.image = selectedImage
    }
    
    func saveAction(){
        
        let imageToSave = generateEdittedImage()
        let dataFromImage:Data! = UIImagePNGRepresentation(imageToSave)
        
        let savedPicture = SavedPicture(imageData: dataFromImage as NSData, context: self.stack.context)
        stack.save()
        
        
    }
    
    func generateEdittedImage() -> UIImage{
        
        UIGraphicsBeginImageContext(editorImage.bounds.size)
        editorImage.image?.draw(in: CGRect(x: 0, y: 0,
                                           width: editorImage.frame.size.width, height: editorImage.frame.size.height))
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
    
}
