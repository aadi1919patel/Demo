//
//  HomeVC.swift
//  InterviewTask
//
//  Created by d3vil_mind on 03/08/21.
//

import UIKit
import Alamofire
import SDWebImage
import RealmSwift

class HomeVC: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var segmentMain: UISegmentedControl!
    @IBOutlet weak var viewInStock: UIView!
    @IBOutlet weak var btnInStock: UIButton!
    @IBOutlet weak var viewSearchBar: UIView!
    @IBOutlet weak var txtSearchBar: UISearchBar!
    @IBOutlet weak var tblCategoriesOrItems: UITableView!
    
    //MARK:- Variables
    var isItemInStock = false
    var isItemShow = false
    var isForSearch = false
    
    var arrCategories = [Category]()
    var arrItems = [Item]()
    var arrStockItems = [Item]()
    var arrSearchData = [Item]()
    
    //MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInitialViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchDataFromRealm()
    }
    
    //MARK:- IBActions
    @IBAction func btnLogoutTapped(_ sender: Any) {
        Constant.userDefaults.setLoggedIn(value: false)
        
        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.popPushToVC(ofKind: LoginVC.self, pushController: loginVC)
    }
    
    @IBAction func btnAddItemTapped(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddItemVC") as! AddItemVC
        vc.arrCategories = self.arrCategories
        vc.isForEdit = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnInstock_Clicked(_ sender : UIButton) {
        
        if !self.isItemInStock {
            self.isItemInStock = true
            self.btnInStock.isSelected = true
        } else {
            self.isItemInStock = false
            self.btnInStock.isSelected = false
        }
        
        self.tblCategoriesOrItems.reloadData()
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentMain.selectedSegmentIndex {
        case 0:
            self.isItemShow = false
            self.viewSearchBar.isHidden = true
            self.viewInStock.isHidden = true
            self.tblCategoriesOrItems.reloadData()
        case 1:
            self.isItemShow = true
            self.viewSearchBar.isHidden = false
            self.viewInStock.isHidden = false
            self.tblCategoriesOrItems.reloadData()
        default:
            break;
        }
    }
    
    //MARK:- Functions
    func setupInitialViews() {
        
        self.txtSearchBar.delegate = self
        
        let params : Parameters = [:]
        
        self.getCategoriesService(params: params)
        self.tblCategoriesOrItems.reloadData()
    }
    
    func fetchDataFromRealm() {
        let realm = try! Realm()
        let realmItems = realm.objects(Item.self)
        
        self.arrItems.removeAll()
        
        for Item in realmItems {
            self.arrItems.append(Item)
        }
        
        self.arrStockItems.removeAll()
        self.arrStockItems = self.arrItems.filter({$0.inStock == 0})
        
        self.tblCategoriesOrItems.reloadData()
    }

}

//MARK:- Webservices
extension HomeVC {
    
    func getCategoriesService(params : Parameters) {
        
        AF.request("https://reqres.in/api/products", method: .get, parameters: params).responseJSON { response in
            
            if let data = response.data, let utf8 = String(data: data, encoding: .utf8) {
                print("UTF 8 : \(utf8)")
                
                do {
                    let dataArray = try JSONDecoder().decode(CateGorySos.self, from: data)
                    
                    //UTF 8 : { "result" : true, "message" : "Login successful.", "userId" : 1002 , "fullname" : "iRoid User" }
                    
                    if dataArray.data.count > 0 {
                        
//                        self.arrCategories.removeAll()
//                        self.arrCategories = dataArray.categories ?? [Category]()
//
//                        self.tblCategoriesOrItems.reloadData()
                    }
                    else {
                        //self.showAlert(title: "Alert", message: dataArray.message ?? "")
                    }
                }
                catch {
                    do{
                        let dataArray = try JSONDecoder().decode(MessageStruct.self,from: data)
                        print(dataArray.message)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
    }
}

//MARK:- UISearchbar delegate
extension HomeVC : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText != "" {
            self.arrSearchData.removeAll()
            
            if self.isItemInStock {
                
                let searchedData = self.arrStockItems.filter { $0.category.lowercased().contains(searchText.lowercased()) || $0.price.lowercased().contains(searchText.lowercased()) || $0.title.lowercased().contains(searchText.lowercased()) }
                
                self.arrSearchData.append(contentsOf: searchedData)
            }
            else {
                
                let searchedData = self.arrItems.filter { $0.category.lowercased().contains(searchText) || $0.price.lowercased().contains(searchText.lowercased()) || $0.title.lowercased().contains(searchText.lowercased()) }
                
                self.arrSearchData.append(contentsOf: searchedData)
            }
            
            self.isForSearch = true
            self.tblCategoriesOrItems.reloadData()
        }
        else {
            self.isForSearch = false
            searchBar.resignFirstResponder()
            self.view.endEditing(true)
            self.tblCategoriesOrItems.reloadData()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isForSearch = false
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
        self.tblCategoriesOrItems.reloadData()
    }
    
}

//MARK:- Tableview Methods
extension HomeVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.isItemShow {
            return self.arrCategories.count > 0 ? self.arrCategories.count : 0
        } else {
            if self.isItemInStock {
                
                if self.isForSearch {
                    return self.arrSearchData.count > 0 ? self.arrSearchData.count : 0
                } else {
                    return self.arrStockItems.count > 0 ? self.arrStockItems.count : 0
                }
            }
            else {
                if self.isForSearch {
                    return self.arrSearchData.count > 0 ? self.arrSearchData.count : 0
                } else {
                    return self.arrItems.count > 0 ? self.arrItems.count : 0
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isItemShow == false {
            
            let objCategory = self.arrCategories[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryListTBL_Cell", for: indexPath) as! CategoryListTBL_Cell
            
            cell.lblCatName.text = objCategory.title
            
            if let strUrl = objCategory.image, strUrl != "" {
                cell.imgCategory.sd_setImage(with: URL(string: strUrl), placeholderImage: UIImage(named: "placeholder.png"))
            } else {
                cell.imgCategory.image = nil
            }
            
            return cell
        } else {
            //let objItem = self.isItemInStock ? self.arrStockItems[indexPath.row] : self.arrItems[indexPath.row]
            
            var objItem = Item()
            
            if self.isItemInStock {
                
                if self.isForSearch {
                    objItem = self.arrSearchData[indexPath.row]
                } else {
                    objItem = self.arrStockItems[indexPath.row]
                }
            }
            else {
                if self.isForSearch {
                    objItem = self.arrSearchData[indexPath.row]
                } else {
                    objItem = self.arrItems[indexPath.row]
                }
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddedItemListTBL_Cell", for: indexPath) as! AddedItemListTBL_Cell
            
            cell.imgItemImage.image = UIImage(data: objItem.itemImage)
            cell.lblItemName.text = objItem.title
            cell.lblItemCategory.text = objItem.category
            cell.lblItemPrice.text = "$ \(objItem.price)"
            cell.lblItemInStock.text = objItem.inStock == 1 ? "In Stock" : "Out Of Stock"
            
            cell.btnEditClick = {(_ aCell: AddedItemListTBL_Cell) -> Void in
                let vc = self.storyboard?.instantiateViewController(identifier: "AddItemVC") as! AddItemVC
                vc.isForEdit = true
                vc.arrCategories = self.arrCategories
                vc.item = objItem
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            cell.btnDeleteClick = {(_ aCell: AddedItemListTBL_Cell) -> Void in
                
                let AC1 = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                    
                    if UIAlertAction.style == .default {
                        let realm = try! Realm()
                        try! realm.write {
                            realm.delete(objItem)
                        }
                        
                        self.arrItems.remove(at: indexPath.row)
                        
                        self.tblCategoriesOrItems.reloadData()
                    }
                })
                
                let AC2 = UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
                    
                    if UIAlertAction.style == .cancel {
                        
                    }
                })
                
                self.showAlertWithTwoAction(title: "Alert", message: "Are you sure you want to delete this item?", action1: AC1, action2: AC2)
            }
            
            return cell
        }
    }
    
    
}

