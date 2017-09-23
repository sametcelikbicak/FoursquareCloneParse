//
//  imageVC.swift
//  FoursquareCloneParse
//
//  Created by Samet ÇELİKBIÇAK on 23.09.2017.
//  Copyright © 2017 Samet ÇELİKBIÇAK. All rights reserved.
//

import UIKit

var globalName = ""
var globalType = ""
var globalAtmosphere = ""
var globalImage = UIImage()

class imageVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var placeNameText: UITextField!
    @IBOutlet weak var placeTypeText: UITextField!
    @IBOutlet weak var placeAtmosphereText: UITextField!
    @IBOutlet weak var placeImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeImage.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageVC.selectImage))
        placeImage.addGestureRecognizer(gestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        globalName = ""
        globalType = ""
        globalAtmosphere = ""
        globalImage = UIImage()
    }
    
    
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        placeImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        if placeNameText.text != "" && placeTypeText.text  != "" && placeAtmosphereText.text != "" {
            if let chosenImage = placeImage.image {
                globalName = placeNameText.text!
                globalType = placeTypeText.text!
                globalAtmosphere = placeAtmosphereText.text!
                globalImage = chosenImage
            }
        }
        self.performSegue(withIdentifier: "fromimageVCtomapVC", sender: nil)
        placeNameText.text = ""
        placeTypeText.text = ""
        placeAtmosphereText.text = ""
        placeImage.image = UIImage(named: "select.png")
    }
    
}
