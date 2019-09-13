//
//  ViewController.swift
//  HotDogSeeker
//
//  Created by Treinamento on 9/13/19.
//  Copyright © 2019 julioCesarASantos. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var cameraWindow: UIImageView!
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
//Função para recolher a captura da câmera.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            cameraWindow.image = userPickedImage
        
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Can't define userPickedImage as a CIImage.")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
//Função para fazer o Model detectar se a imagem coincide com um cachorro quente.
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML model failed.")
        }
        //Sessão para tratar a imagem junto ao model.
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let observationResults = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            if let firstResults = observationResults.first {
                if firstResults.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                } else {
                    let name : String = firstResults.identifier
                    self.navigationItem.title = "Not hotdog!"
                }
            }
        }

        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
//Botão para acessar a câmera.
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }

}

