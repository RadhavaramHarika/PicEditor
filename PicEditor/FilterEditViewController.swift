//
//  FilterEditViewController.swift
//  PicEditor
//
//  Created by radhavaram harika on 1/30/17.
//  Copyright © 2017 Practise. All rights reserved.
//

import UIKit
import Social

class FilterEditViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageToEdit: UIImageView!
    @IBOutlet weak var filtersScrollView: UIScrollView!
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    var selectedImage: UIImage!
    var imageData: Data!
    var CIFilterNames = ["CIPhotoEffectChrome","CIPhotoEffectFade","CIPhotoEffectInstant","CIPhotoEffectNoir","CIPhotoEffectProcess","CIPhotoEffectTonal","CIPhotoEffectTransfer","CISepiaTone"]
    
    var xCoord = 5
    var yCoord = 5
    let buttonWidth = 90
    let buttonHeight = 90
    let gapBetweenButtons = 5
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        self.view.bringSubview(toFront: titleLabel)
        imageToEdit.image = selectedImage
        filtersScrollView.isScrollEnabled = true
        filtersScrollView.showsHorizontalScrollIndicator = true
        filtersScrollView.alwaysBounceHorizontal = true
        createButtonsInFilterScrollView()
    }
    
    func setNavigationBar(){
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = false
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction))
        let save = UIBarButtonItem(title: "save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveAction))
        navigationItem.rightBarButtonItems = [save,share]
    }
    
    func createButtonsInFilterScrollView(){
        filtersScrollView.contentSize = CGSize.zero
        var item = 0
        for i in 0..<CIFilterNames.count{
            item = i
            let filterButton = UIButton(type: .custom)
            filterButton.frame = CGRect(x: xCoord,y: yCoord, width: buttonWidth,height: buttonHeight)
            filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
            filterButton.clipsToBounds = true
            filterButton.layer.cornerRadius = 5
            
            let ciContext = CIContext(options: nil)
            let coreImage = CIImage(image: imageToEdit.image!)
            let filter = CIFilter(name: "\(CIFilterNames[i])")
            filter?.setDefaults()
            filter?.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter?.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageReference = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            let imageForButton = UIImage(cgImage: filteredImageReference!)
            filterButton.setBackgroundImage(imageForButton, for: .normal)
            
            xCoord += buttonWidth + gapBetweenButtons
            filtersScrollView.addSubview(filterButton)
        }
        
        let x = Double(buttonWidth) * Double(item + 2)
        filtersScrollView.isScrollEnabled = true
        filtersScrollView.showsHorizontalScrollIndicator = true
        filtersScrollView.alwaysBounceHorizontal = true
        filtersScrollView.isUserInteractionEnabled = true
        filtersScrollView.contentSize = CGSize(width: CGFloat(x),height: CGFloat(yCoord))
    }
    
    func filterButtonTapped(_ sender: UIButton){
        
        let filterBtn = sender as UIButton
        imageToEdit.image = filterBtn.backgroundImage(for: .normal)
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
    
    
    func shareAction(){
        
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
