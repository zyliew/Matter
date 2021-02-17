//
//  AddSpoolVC.swift
//  Matter
//
//  Created by Ziyi Liew on 16/12/20.
//

import UIKit
import CoreData

class AddSpoolVC: UIViewController {
    @IBOutlet weak var quantityTextBox: UITextField!
    @IBOutlet weak var materialTextBox: UITextField!
    @IBOutlet weak var colorTextBox: UITextField!
    @IBOutlet weak var weightTextBox: UITextField!
    @IBOutlet weak var diameterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var purchaseLinkTextBox: UITextField!
    @IBOutlet weak var brandTextBox: UITextField!
    @IBOutlet weak var spoolImage: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initializeImagePicker()
        
        // round image corners
        spoolImage.layer.cornerRadius = 20
        spoolImage.layer.masksToBounds = true
        
        // tap to dismiss keyboard
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
//        getData()
//        clearCoreData()
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
    
    @IBAction func storeSpoolData(_ sender: Any) {
        // check that inputs are valid
        if checkInputs() {
            // add spool to core data
            addToCoreData()
            getData()
            // visual confirmation to user that spool is added
            let alert = UIAlertController(title: "Added", message: nil, preferredStyle: .alert)
            self.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()){
              alert.dismiss(animated: true, completion: nil)
            }
        } else {
            print("Bad input data")
        }
    }
    
    func checkInputs() -> Bool {
        // check for empty inputs
        if quantityTextBox.text!.isEmpty || materialTextBox.text!.isEmpty || colorTextBox.text!.isEmpty || weightTextBox.text!.isEmpty {
            // alert
            let alert = UIAlertController(title: "Invalid Input", message: "Quantity, Material, Color and Weight have to be filled in", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return false
        }
        
        // check if inputs are the appropriate type
        let numberCharacters = NSCharacterSet.decimalDigits.inverted
        if quantityTextBox.text!.rangeOfCharacter(from: numberCharacters) != nil || !weightTextBox.text!.isDouble {
            // alert
            let alert = UIAlertController(title: "Invalid Input", message: "Quantity and Weight has to be a number", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return false
        }
        
        // check if URL link is valid if user inputs a url
        if !(purchaseLinkTextBox.text?.isEmpty ?? true) {
            if let url = URL(string: purchaseLinkTextBox.text!) {
                let valid = UIApplication.shared.canOpenURL(url)
                if !valid {
                    let alert = UIAlertController(title: "Invalid URL", message: "Please input a valid url starting with http or https", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return false
                }
            }
            
        }
        
        return true
    }
    
    func addToCoreData() {
        print("add to core data")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        var brand = brandTextBox.text ?? ""
        let link = purchaseLinkTextBox.text ?? ""
        if brand == "" {
            brand = "Generic"
        }
        
        let toAddQuantity = Int(quantityTextBox.text!) ?? 0
        
        // create new spool/s
        for _ in 1...toAddQuantity {
            let spool = NSEntityDescription.insertNewObject(
                forEntityName: "Spool", into:context)

            spool.setValue(materialTextBox.text, forKey: "material")
            spool.setValue(colorTextBox.text, forKey: "color")
            spool.setValue(Int(weightTextBox.text!), forKey: "weight")
            spool.setValue(UUID().uuidString, forKey: "uid")
            spool.setValue(link, forKey: "link")
            spool.setValue(brand, forKey: "brand")
//            print("brand is \(brand)")
            switch diameterSegmentedControl.selectedSegmentIndex {
            case 0:
                spool.setValue(1.75, forKey: "diameter")
            case 1:
                spool.setValue(2.85, forKey: "diameter")
            default:
                break
            }
            
            // TODO: image
            if let imageData = spoolImage.image?.pngData() {
//                saveImage(data: imageData)
                spool.setValue(imageData, forKey: "image")
            } else {
                let image = #imageLiteral(resourceName: "filament_spool").pngData()
                spool.setValue(image, forKey: "image")
            }
            
            // Commit the changes
            do {
                try context.save()
            } catch {
                // if an error occurs
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Spool")
        
        var fetchedResults: [NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        for spool in fetchedResults! {
            if let color = spool.value(forKey: "color"),
               let diameter = spool.value(forKey: "diameter"),
               let link = spool.value(forKey: "link"),
               let material = spool.value(forKey: "material"),
               let brand = spool.value(forKey: "brand"),
               let uid = spool.value(forKey: "uid"),
               let weight = spool.value(forKey: "weight") {
                print("Color: \(color), Diameter: \(diameter), Link: \(link), Material: \(material), Brand: \(brand), UID: \(uid), Weight: \(weight)")
                
            }
            
        
            if let image = spool.value(forKey: "image") {
                spoolImage.image = UIImage(data: image as! Data)
            }
//            print(image)
//            spoolImage.image = UIImage(data: image as! Data)
        }
        

    }
    
    func clearCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Spool")
        
        var fetchedResults: [NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
//                    print("\(result.value(forKey:"uid")!) has been deleted")
                }
            }
            try context.save()
            
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        print("core data cleared")
    }
    

}

extension AddSpoolVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        spoolImage.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func initializeImagePicker() {
        // initialize imagePicker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    
    // This closes the keyboard when touch is detected outside of the keyboard
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        view.endEditing(true)
//        super.touchesBegan(touches, with: event)
//    }
}
    
