//
//  LoginVC.swift
//  InterviewTask
//
//  Created by d3vil_mind on 03/08/21.
//

import UIKit
import Alamofire

class LoginVC: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK:- IBActions
    @IBAction func btnSubmitTapped(_ sender: Any) {
        
        guard isValidatedAllFields() else { return }
        
        let Params : Parameters = [ "username" : "\(self.txtUsername.text!)" , "password" : "\(self.txtPassword.text!)"]
        
        print(Params)
        
        self.loginService(params: Params)
        
    }
    
    //MARK:- Functions
    func isValidatedAllFields() -> Bool {
        
        self.view.endEditing(true)
        
        if self.txtUsername.text!.count == 0 {
            self.showAlert(title: "Alert", message: "Please enter username.")
            return false
        }
        else if self.txtPassword.text!.count == 0 {
            self.showAlert(title: "Alert", message: "Please enter password.")
            return false
        }
        
        return true
    }
    

}

//MARk:- Webservices
extension LoginVC {
    
    func loginService(params : Parameters) {
        
        AF.request("https://www.iroidsolutions.com/interview/mobileapp/login.php", method: .post, parameters: params).responseJSON { response in
            
            if let data = response.data, let utf8 = String(data: data, encoding: .utf8) {
                print("UTF 8 : \(utf8)")
                
                do {
                    let dataArray = try JSONDecoder().decode(LoginStruct.self, from: data)
                    
                    //UTF 8 : { "result" : true, "message" : "Login successful.", "userId" : 1002 , "fullname" : "iRoid User" }
                    
                    if dataArray.result ?? false {
                        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                        self.navigationController?.pushViewController(homeVC, animated: true)
                        
                        Constant.userDefaults.setLoggedIn(value: true)
                    }
                    else {
                        self.showAlert(title: "Alert", message: dataArray.message ?? "")
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

