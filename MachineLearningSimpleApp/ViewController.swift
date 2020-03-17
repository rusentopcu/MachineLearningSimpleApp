//
//  ViewController.swift
//  MachineLearningSimpleApp
//
//  Created by Rusen Topcu on 17.03.2020.
//  Copyright © 2020 Rusen Topcu. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    var chosenImage = CIImage()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func changeClicked(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
       
        
        if let ciImage = CIImage(image: imageView.image!) {
            chosenImage = ciImage
        }
        
        recognizeImage(image: chosenImage)
        
    }
    
     //MARK: -ML steps:1_Request, 2_Handler
     func recognizeImage(image:CIImage) {
        
        //MARK: - İnternetten indirilen modelimizi alıp bir değişkene atadık.
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
            
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    
                    if results.count > 0 {
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            let rounded = Int(confidenceLevel * 100) / 100
                            self.resultLabel.text = "\(rounded)% it's \(topResult?.identifier)"
                            
                        }
                        
                    }
                    
                }
                
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                }
                catch {
                    print(error)
                }
            }
        }
        
    }
    
}

