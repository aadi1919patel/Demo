//
//  AddItemVC.swift
//  InterviewTask
//
//  Created by d3vil_mind on 03/08/21.
//

import UIKit
import RealmSwift

class AddItemVC: UIViewController {

    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var btnSelectImage: UIButton!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var btnInStock: UIButton!
    @IBOutlet weak var lblInStockStatus: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    
    //MARK:- Variables
    var isImageSelected = false
    
    var imagePicker = UIImagePickerController()
    var categoryPicker: UIPickerView!
    var arrCategories = [Category]() //["5. Klasse", "6. Klasse", "7. Klasse"]
    
    var item: Item!
    
    var isForEdit = false
    
    //MARK:- View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInitialViews()
    }
    
    //MARK:- IBActions
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLogoutTapped(_ sender: Any) {
        Constant.userDefaults.setLoggedIn(value: false)
        
        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.popPushToVC(ofKind: LoginVC.self, pushController: loginVC)
    }
    
    @IBAction func btnSelectImageTapped(_ sender: Any) {
        self.openActionSheetToPickAnImage()
    }
    
    @IBAction func btnInStockTapped(_ sender: Any) {
        self.btnInStock.isSelected = !self.btnInStock.isSelected
    }
        
    @IBAction func btnSaveTapped(_ sender: Any) {
        
        guard isValidatedAllFields() else { return }
        
        if self.isForEdit {
            
            self.updateItemInRealm()
            
            let AC = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                
                if UIAlertAction.style == .default {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            
            self.showAlertWithAction(title: "Alert", message: "Item updated successfully", action: AC)
        }
        else {
            self.addNewItemInRealm()
            
            let AC = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                
                if UIAlertAction.style == .default {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            
            self.showAlertWithAction(title: "Alert", message: "Item added successfully", action: AC)
        }
        
    }
        
    //MARK:- Functions
    func isValidatedAllFields() -> Bool {
        
        self.view.endEditing(true)
        
        if !self.isImageSelected {
            self.showAlert(title: "Alert", message: "Please select an image.")
            return false
        }
        else if self.txtTitle.text!.count == 0 {
            self.showAlert(title: "Alert", message: "Please enter title.")
            return false
        }
        else if self.txtCategory.text!.count == 0 {
            self.showAlert(title: "Alert", message: "Please select category.")
            return false
        }
        else if self.txtPrice.text!.count == 0 {
            self.showAlert(title: "Alert", message: "Please enter price.")
            return false
        }
        
        return true
    }
        
    func setupInitialViews() {
        
        if self.isForEdit {
            self.imgProduct.image = UIImage(data: (self.item.itemImage))
            self.txtTitle.text = self.item.title
            self.txtCategory.text = self.item.category
            self.txtPrice.text = self.item.price
            self.btnInStock.isSelected = self.item.inStock == 1 ? true : false
            self.isImageSelected = true
        }
        
        self.setCategoryPicker()
    }
        
    func addNewItemInRealm() {
        let realm = try! Realm() // 1
        
        try! realm.write { // 2
            let newItem = Item() // 3
            newItem.id = (try! Realm().objects(Item.self).max(ofProperty: "id") as Int? ?? 0) + 1
            newItem.itemImage = self.imgProduct.image!.jpegData(compressionQuality: 1.0)!
            newItem.title = self.txtTitle.text ?? ""
            newItem.category = self.txtCategory.text ?? ""
            newItem.price = self.txtPrice.text ?? ""
            newItem.inStock = self.btnInStock.isSelected ? 1 : 0
            
            realm.add(newItem) // 5
            item = newItem // 6
        }
    }

    func updateItemInRealm() {
        let realm = try! Realm()
        
        if let itemOld = realm.objects(Item.self).filter("id == %@",item.id).first {
            try! realm.write {
                itemOld.itemImage = self.imgProduct.image!.jpegData(compressionQuality : 1.0)!
                itemOld.title     = self.txtTitle.text ?? ""
                itemOld.category  = self.txtCategory.text ?? ""
                itemOld.price     = self.txtPrice.text ?? ""
                itemOld.inStock   = self.btnInStock.isSelected ? 1 : 0
            }
            print(realm.objects(Item.self).first!)
        }
    }
}

//MARK:- Categories PickerView Methods
extension AddItemVC : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func setCategoryPicker() {
        
        self.categoryPicker = UIPickerView()
        
        self.categoryPicker.dataSource = self
        self.categoryPicker.delegate = self
        
        self.txtCategory.inputView = self.categoryPicker
        //self.txtCategory.text = self.arrCategories[0].title
        
        if self.isForEdit {
            let index = self.arrCategories.firstIndex{$0.title == self.item.category}
            
            self.txtCategory.text = self.arrCategories[index ?? 0].title
        } else {
            self.txtCategory.text = self.arrCategories[0].title
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return self.arrCategories.count > 0 ? self.arrCategories.count : 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.arrCategories[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        txtCategory.text = self.arrCategories[row].title
        self.view.endEditing(true)
    }
}

//MARK:- Image Picker Methods
extension AddItemVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openActionSheetToPickAnImage() {
        let alert:UIAlertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.openCamera()
        }
        
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.openGallary()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        imagePicker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            self.showAlert(title: "Warning", message: "You don't have camera")
        }
    }
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true

        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        /*
         if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
             self.imgProduct.image = image
             self.isImageSelected = true
         }
         */
        
        if let editedImage = info[.editedImage] as? UIImage {
            self.imgProduct.image = editedImage
            self.isImageSelected = true
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("picker cancel.")
    }
    
}
