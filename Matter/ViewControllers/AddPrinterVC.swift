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
    @IBOutlet weak var printerImage: UIImageView!
    @IBOutlet weak var diameterSegmentedControl: UISegmentedControl!
    
    var imagePicker: UIImagePickerController!
    var delegate: passPrinters?
    var printers:[PrinterDisplay]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initializeImagePicker()
        
        // round image corners
        printerImage.layer.cornerRadius = 20
        printerImage.layer.masksToBounds = true
        
        // tap to dismiss keyboard
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func chooseDiameter(_ sender: Any) {
    }
    // user upload image, choose between taking a picture or from photo library
    @IBAction func uploadPicture(_ sender: Any) {
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
    
    @IBAction func submitToCoreData(_ sender: Any) {
        // check that inputs are valid
        if validInputs() {
            // add spool to core data
            print("adding printer to core data")
            addToCoreData()
            
            // visual confirmation to user that spool is added
            let alert = UIAlertController(title: "Added", message: nil, preferredStyle: .alert)
            self.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()){
              alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func validInputs() -> Bool {
        // check for empty inputs
        if nameTextBox.text!.isEmpty {
            // throw alert
            let alert = UIAlertController(title: "Invalid Input", message: "Name and Diameter have to be filled in", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            return false
        }
        
        return true
    }
}

// Core Data Methods
extension AddPrinterVC {
    func addToCoreData() {
        print("add to core data")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let name = nameTextBox.text
        var diameter = Double()
        let uid = UUID().uuidString
        
        switch diameterSegmentedControl.selectedSegmentIndex {
        case 0:
            diameter = 1.75
        case 1:
            diameter = 2.85
        default:
            break
        }
        
        let printer = NSEntityDescription.insertNewObject(forEntityName: "Printer", into: context)
        
        printer.setValue(name, forKey: "name")
        printer.setValue(diameter, forKey: "diameter")
        printer.setValue(uid, forKey: "uid")
        
        // handle images
        if let imageData = printerImage.image?.pngData() {
            printer.setValue(imageData, forKey: "image")
            printers?.append(PrinterDisplay(image: printerImage.image!, name: name!, diameter: diameter, uid: uid))
        } else {
            let image = #imageLiteral(resourceName: "nozzle_extruding").pngData()
            printerImage.image = #imageLiteral(resourceName: "3d_printer")
            printer.setValue(image, forKey: "image")
            printers?.append(PrinterDisplay(image: #imageLiteral(resourceName: "3d_printer"), name: name!, diameter: diameter, uid: uid))
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

