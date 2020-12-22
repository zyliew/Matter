//
//  AddPrinterVC.swift
//  Matter
//
//  Created by Ziyi Liew on 23/12/20.
//

import UIKit
import CoreData

// pass printers between AddPrinterVC and PrintersVC
protocol passPrinters {
    func updatePrinterArray(printer: [PrinterDisplay])
}

class AddPrinterVC: UIViewController {
    @IBOutlet weak var nameTextBox: UITextField!
    @IBOutlet weak var diameterTextBox: UITextField!
    @IBOutlet weak var printerImage: UIImageView!
    
    var imagePicker: UIImagePickerController!
    var delegate: passPrinters?
    var printers:[PrinterDisplay]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initializeImagePicker()
    }
    

    @IBAction func uploadPicture(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func submitToCoreData(_ sender: Any) {
        // check that inputs are valid
        if validInputs() {
            // add spool to core data
            print("adding printer to core data")
            addToCoreData()
        }
    }
    
    func validInputs() -> Bool {
        // check for empty inputs
        if nameTextBox.text!.isEmpty || diameterTextBox.text!.isEmpty {
            // throw alert
            let alert = UIAlertController(title: "Invalid Input", message: "Name and Diameter have to be filled in", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            return false
        }
        
        // check if inputs are the appropriate type
        if !diameterTextBox.text!.isDouble {
            let alert = UIAlertController(title: "Invalid Input", message: "Diameter has to be a number", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return false
        }
        
        return true
    }
    
    
    // This closes the keyboard when touch is detected outside of the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

// Core Data Methods
extension AddPrinterVC {
    func addToCoreData() {
        print("add to core data")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let name = nameTextBox.text
        let diameter = Double(diameterTextBox.text!)
        
        let printer = NSEntityDescription.insertNewObject(forEntityName: "Printer", into: context)
        
        printer.setValue(name, forKey: "name")
        printer.setValue(diameter, forKey: "diameter")
        
        // handle images
        if let imageData = printerImage.image?.pngData() {
            printer.setValue(imageData, forKey: "image")
            printers?.append(PrinterDisplay(image: printerImage.image!, name: name!, diameter: diameter!))
        } else {
            let image = #imageLiteral(resourceName: "nozzle_extruding").pngData()
            printerImage.image = #imageLiteral(resourceName: "3d_printer")
            printer.setValue(image, forKey: "image")
            printers?.append(PrinterDisplay(image: #imageLiteral(resourceName: "3d_printer"), name: name!, diameter: diameter!))
        }
        
        // Commit the changes
        delegate?.updatePrinterArray(printer: printers!)
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
extension AddPrinterVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        printerImage.image = image
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

extension String {
    var isInteger: Bool { return Int(self) != nil }
    var isFloat: Bool { return Float(self) != nil }
    var isDouble: Bool { return Double(self) != nil }
}
