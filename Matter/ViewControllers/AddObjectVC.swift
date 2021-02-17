//
//  AddObjectVC.swift
//  Matter
//
//  Created by Ziyi Liew on 19/12/20.
//

import UIKit
import CoreData

// pass object array between AddObjectVC and ObjectVC
// (multiple items)
protocol passObjects {
    func updateArray(object: [ObjectDisplay])
}

class AddObjectVC: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var objectImage: UIImageView!
    
    var delegate: passObjects?
    var imagePicker: UIImagePickerController!
    var objects:[ObjectDisplay]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initializeImagePicker()
        
        // round image corners
        objectImage.layer.cornerRadius = 20
        objectImage.layer.masksToBounds = true
        
        // tap to dismiss keyboard
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // user upload image, choose between taking a picture or from photo library
    @IBAction func uploadImage(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Picture", style: .default, handler: {action in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Library", style: .default, handler: {action in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func submit(_ sender: Any) {
        if vaildInputs() {
            addToCoreData()
            // visual confirmation to user that spool is added
            let alert = UIAlertController(title: "Added", message: nil, preferredStyle: .alert)
            self.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()){
              alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

// Core Data Methods
extension AddObjectVC {
    func addToCoreData() {
        print("add to core data")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let name = nameTextField.text
        let weight = Double(weightTextField.text!)
        let uid = UUID().uuidString
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context)
        
        object.setValue(name, forKey: "name")
        object.setValue(weight, forKey: "weight")
        object.setValue(uid, forKey: "uid")
        
        // handle images
        if let imageData = objectImage.image?.pngData() {
            object.setValue(imageData, forKey: "image")
            objects?.append(ObjectDisplay(name: name!, weight: weight!, image: objectImage.image!, uid: uid))
        } else {
            let image = #imageLiteral(resourceName: "nozzle_extruding").pngData()
            objectImage.image = #imageLiteral(resourceName: "nozzle_extruding")
            object.setValue(image, forKey: "image")
            objects?.append(ObjectDisplay(name: name!, weight: weight!, image: #imageLiteral(resourceName: "nozzle_extruding"), uid: uid))
        }
        
        // Commit the changes
        delegate?.updateArray(object: objects!)
        do {
            try context.save()
            print("added to CoreData")
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
}

// ImagePicker Methods
extension AddObjectVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // dismiss imagePicker when cancel is pressed
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // get the image from photolibrary
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        // set the spool image to the new image
        objectImage.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func initializeImagePicker() {
        // initialize imagePicker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
}

// Helper Methods
extension AddObjectVC {
    func vaildInputs() -> Bool {
        // check that name and weight are not empty
        if nameTextField.text!.isEmpty || weightTextField.text!.isEmpty {
            // throw alert
            let alert = UIAlertController(title: "Invalid Input", message: "Name and Weight have to be filled in", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return false
        }
        
        // check that weight is a double
        let numberCharacters = NSCharacterSet.decimalDigits.inverted
        if !weightTextField.text!.isDouble {
            // throw alert
            let alert = UIAlertController(title: "Invalid Input", message: "Weight has to be a number", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return false
        }
        return true
    }
}

//extension UIImage{
//    var roundedImage: UIImage {
//        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
//        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
//        UIBezierPath(
//            roundedRect: rect,
//            cornerRadius: 50
//            ).addClip()
//        self.draw(in: rect)
//        return UIGraphicsGetImageFromCurrentImageContext()!
//    }
//}
