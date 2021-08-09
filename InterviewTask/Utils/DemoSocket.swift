//
//  DemoSocket.swift
//  InterviewTask
//
//  Created by Adi Patel on 09/08/21.
//


import UIKit
import GoogleMaps
import Alamofire
import CryptoSwift
import CryptoKit

class OnTripVC: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var lblNavigationTitle: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var lblDriver: UILabel!
    @IBOutlet weak var imgDriver: UIImageView!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblDriverContactNumber: UILabel!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var imgCar: UIImageView!
    @IBOutlet weak var lblCarName: UILabel!
    @IBOutlet weak var lblCarNumber: UILabel!
    @IBOutlet weak var btnQRCode: UIButton!
    @IBOutlet weak var btnReport: UIButtonX!
    
    //QR View
    @IBOutlet weak var qrCodeContainerView: UIView!
    @IBOutlet weak var codeContainerView: UIView!
    @IBOutlet weak var imgQrCode: UIImageView!
    @IBOutlet weak var btnClose: UIButtonX!
    
    //MARK:- Variables
    var initialInteractivePopGestureRecognizerDelegate: UIGestureRecognizerDelegate?
    
    var currentRideID = ""
    //var currentRideID = "abc132k"
    var myRideData = MyRideData()
    
    var dicLocation = [sLocation]()
    
    var arrPositions = [CLLocationCoordinate2D]()
    
    var locationManager = CLLocationManager()
    
    var arrPassengerData = [PassengerRideData]()
    var arrPassengerLocation = [PassengerRideLocation]()
    
    var oldCoodinate: CLLocationCoordinate2D?
    var newCoodinate: CLLocationCoordinate2D?
    
    var driverMarker : GMSMarker?
    
    var isForFirstTime = true
    
    //MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInitialViews()
        
        initialInteractivePopGestureRecognizerDelegate = self.navigationController?.interactivePopGestureRecognizer?.delegate
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        let dicParams = ["rideId" : "\(self.currentRideID)"]
        
        let locationData = Utils.JSONString(object: dicParams) ?? ""
        
        SocketHelper.shared.joinRideRoom(rideData: locationData) {
            print("Ride Room Joined")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = initialInteractivePopGestureRecognizerDelegate
        
        let dicParams = ["rideId" : "\(self.currentRideID)"]
        
        let locationData = Utils.JSONString(object: dicParams) ?? ""
        
        SocketHelper.shared.exitRideRoom(rideData: locationData) {
            print("Ride Room Exited")
        }
    }

    override func viewDidLayoutSubviews() {
        self.imgDriver.layer.cornerRadius = self.imgDriver.frame.size.height/2
        self.bottomContainerView.roundCornersToTop(cornerRadius: 20.0)
    }
    
    //MARK:- IBActions
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnMessageTapped(_ sender: Any) {
        if let phoneCallURL = URL(string: "tel://+\(myRideData.driver?.countryCode ?? 0)\(myRideData.driver?.phoneNumber ?? "")"), UIApplication.shared.canOpenURL(phoneCallURL) {
            UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func btnQRCodeTapped(_ sender: Any) {
        
        let dicParams : NSDictionary = [
                                        "booking_id" : "\(self.myRideData.bookingID ?? 0)",
                                        "ride_id" : "\(self.currentRideID)"
                                        ]
        
        /*
        let dicParams : NSDictionary = [
                                        "booking_id" : "test",
                                        "ride_id" : "213"
                                        ]
        */
        
        let strQrCodeParams = Utils.JSONString(object: dicParams) ?? ""
        
        let keyGTW = "gotoworkgotowork"
        
        let iv       = "abcdefghijklmnop"
        
        do {
            let aes = try AES(keyString: "gotoworkgotoworkgotoworkgotowork")

            let stringToEncrypt: String = strQrCodeParams
            print("String to encrypt:\t\t\t\(stringToEncrypt)")

            let encryptedData: Data = try aes.encrypt(stringToEncrypt)
            print("String encrypted (base64):\t\(encryptedData.base64EncodedString())")

            let decryptedData: String = try aes.decrypt(encryptedData)
            print("String decrypted:\t\t\t\(decryptedData)")

        } catch {
            print("Something went wrong: \(error)")
        }
        
        //let str = strQrCodeParams.cryptoSwiftAESEncrypt(key: keyGTW, iv: iv)
        //MD5Base64(strQrCodeParams)
        //print(MD5Base64(strQrCodeParams))
        
        //print(MD5Base64(strQrCodeParams).toBase644())
        
//        let aes128 = AES(key: keyGTW, iv: iv)
//        let encryptedPassword128 = aes128?.encrypt(string: strQrCodeParams ?? "")
//
//        let str = String(decoding: encryptedPassword128 ?? Data(), as: UTF8.self)
        
        self.imgQrCode.image = generateQRCode(from: strQrCodeParams)
        
        //print(str?.cryptoSwiftAESDecrypt(key: keyGTW, iv: iv) ?? "")
        
        //let strDesign = str?.fromBase64()
        
        //self.imgQrCode.image = generateQRCodeFromData(from: encryptedPassword128 ?? Data())
        
        self.qrCodeContainerView.isHidden = false
        /*
         let password = "UserPassword1!"
         let key128   = "1234567890123456"                   // 16 bytes for AES128
         let key256   = "12345678901234561234567890123456"   // 32 bytes for AES256
         let iv       = "abcdefghijklmnop"                   // 16 bytes for AES128
         
         let aes128 = AES(key: key128, iv: iv)
         let aes256 = AES(key: key256, iv: iv)

         let encryptedPassword128 = aes128?.encrypt(string: password)
         aes128?.decrypt(data: encryptedPassword128)
         */
    }
    
    @IBAction func btnReportTapped(_ sender: UIButtonX) {
        /*
        let vc = ReportVC()
        self.navigationController?.pushViewController(vc, animated: true)
        */
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButtonX) {
        self.qrCodeContainerView.isHidden = true
    }
    
    
    //MARK:- Functions
    func setupInitialViews() {
        var lblnavTitlefont : UIFont?
        
        lblnavTitlefont = MySingleton.sharedManager().themeFontTwentySizeBold
        
        self.lblNavigationTitle.font = lblnavTitlefont
        
        if let pImgURL = URL(string: (self.myRideData.driver?.profileImage) ?? ""), !pImgURL.absoluteString.isEmpty {
            self.imgDriver.sd_setImage(with: pImgURL, placeholderImage: #imageLiteral(resourceName: "profilePlaceholder"), options: .highPriority, completed: nil)
        } else {
            self.imgDriver.image = #imageLiteral(resourceName: "profilePlaceholder.png")
        }
        
        self.lblDriverName.text = "\(self.myRideData.driverFirstName ?? "") \(self.myRideData.driverLastName ?? "")"
        self.lblDriverContactNumber.text = "\(self.myRideData.driver?.countryCode ?? 0)\(self.myRideData.driver?.phoneNumber ?? "")"
        //self.imgCar
        self.lblCarName.text = "\(self.myRideData.vehicle?.vehicleModel ?? "")"
        self.lblCarNumber.text = "\(self.myRideData.vehicle?.vehicleNumber ?? "")"
        
        let dicParams : NSDictionary = [
                                        "ride_id" : "\(self.currentRideID)",
                                        ]
        
        self.getPassengerOnGoingRideDetailsService(dicParams: dicParams)
        
        //self.setupSocketMethods()
    }
    
    func setupSocketMethods() {
        
        /*
        SocketHelper.shared.getLocationOfDriver { (_: sLocation?) in
            print(sLocation.self)
            
            //dicLocation = [sLocation]
        }
        */
        
        SocketHelper.shared.getLocationOfDriver { [weak self] (location: sLocation?) in
            guard let self = self,
                  let locInfo = location else {
                return
            }
            
            print("New Driver Location : ",locInfo)
            
            //let coordinate:CLLocation = CLLocation(latitude: Double(dicParams["latitude"] as! String) ?? 0.0, longitude: Double(dicParams["longitude"] as! String) ?? 0.0)
            //self.driverLocation = coordinate.coordinate
            
            
            let coordinate:CLLocation = CLLocation(latitude: Double(locInfo.latitude ?? "0.0") ?? 0.0 , longitude: Double(locInfo.longitude ?? "0.0") ?? 0.0 )
            let coordinate2d: CLLocationCoordinate2D = coordinate.coordinate
            
            if self.isForFirstTime {
                
                self.isForFirstTime = false
                
                self.driverMarker = GMSMarker()
                self.driverMarker?.position = coordinate2d
                let image = #imageLiteral(resourceName: "ic_cartop") //UIImage(named:"ic_cartop")
                self.driverMarker?.icon = image
                self.driverMarker?.map = self.mapView
                self.driverMarker?.appearAnimation = GMSMarkerAnimation.pop
                
                
                /*
                self.oldCoodinate = coordinate2d
                self.newCoodinate = coordinate2d
                self.driverMarker?.position = coordinate2d
                self.driverMarker?.icon = UIImage(named: "ic_cartop")
                self.driverMarker?.title = "Driver"
                self.driverMarker?.snippet = "Driver"
                self.driverMarker?.map = self.mapView
                */
                
                //self.mapView.animate(toLocation: coordinate2d)
                
                //self.driverMarker?.position = coordinate2d
                //self.driverMarker?.map = self.mapView
            }
            else {
                self.driverMarker?.icon = UIImage(named: "ic_cartop")
                //self.moveDriver(oldLoc : self.newCoodinate ?? CLLocationCoordinate2D() , newLoc : coordinate2d)
                
                let camera = GMSCameraPosition.camera(withLatitude: coordinate2d.latitude, longitude: coordinate2d.longitude, zoom: 18)
                self.mapView?.camera = camera
                self.mapView?.animate(to: camera)
                 
                CATransaction.begin()
                CATransaction.setAnimationDuration(2.0)
                self.driverMarker?.icon = UIImage(named: "ic_cartop")
                self.driverMarker?.position = coordinate2d
                self.driverMarker?.rotation = coordinate.course
                self.driverMarker?.rotation = camera.bearing // CLLocationCoordinate2D coordinate
                 CATransaction.commit()
            }
            
            /*
            let camera = GMSCameraPosition.camera(withLatitude: lattitude, longitude: longitude, zoom: 16)
            mapView?.camera = camera
            mapView?.animate(to: camera)
             
             CATransaction.begin()
             CATransaction.setAnimationDuration(2.0)
             marker.position = coordindates // CLLocationCoordinate2D coordinate
             CATransaction.commit()
            */
            
            //self.arrMessage.value.append(locInfo)
        }
    }
    
    //Generate qr code from string in swift (hacking with swift)
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    func generateQRCodeFromData(from data: Data) -> UIImage? {
        let data = data

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    func MD5Base64(_ string: String) -> String {
        if #available(iOS 13.0, *) {
            let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
            let digestString = digest.map { String(format: "%02hhx", $0) }.joined()
            return digestString.toBase644()
        } else {
            // Fallback on earlier versions
        }
        return ""
    }
    
}

extension String {
    func toBase644() -> String {
            return Data(self.utf8).base64EncodedString()
        }
}

//MARK:- Webservices
extension OnTripVC {
    
    func getPassengerOnGoingRideDetailsService(dicParams: NSDictionary) {
        
        let headers : NSDictionary = [ "Authorization" : Constant.userDefault.getAuthToken() ]
          
        /*
        let dicParams : NSDictionary = [
                                        "booking_id" : "",
                                        "ride_id" : "\(self.currentRideID)",
                                        ]
        */
        
        WebServices().CallGlobalAPI(url: WebApis.GetPassengerTripDetail, headers: headers, parameters: dicParams, httpMethod: "POST", progressView: true, uiView: self.view, networkAlert: true) { (responseJSON, errorMessage) in
            
            print(responseJSON)
                        
            print(errorMessage)
            
            guard errorMessage == "" else {
                Utils.Toast(message: errorMessage , controller: self)
                return
            }
            
            do {
                SVProgressHUD.dismiss()
                
                let dataArray = try JSONDecoder().decode(PassengerRideStruct.self,from: responseJSON as! Data)
                
                if dataArray.status == 100
                {
                    self.arrPassengerData.removeAll()
                    self.arrPassengerLocation.removeAll()
                    
                    self.arrPositions.removeAll()
                    self.mapView.clear()

                    self.arrPassengerData = dataArray.data ?? [PassengerRideData]()
                    
                    for objRideDetails in self.arrPassengerData {
                        
                        for objLocation in objRideDetails.location! {
                            if let strLat = Double(objLocation.latitude ?? ""), let strLong = Double(objLocation.longitude ?? "") {
                                
                                let coordinate:CLLocation = CLLocation(latitude: strLat , longitude: strLong )
                                let coordinate2d: CLLocationCoordinate2D = coordinate.coordinate
                                
                                self.arrPositions.append(coordinate2d)
                                
                                if objRideDetails.userID == Constant.userDefault.getUserID() {
                                    self.addMarkerOnGmap(position: coordinate2d)
                                }
                                
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.drawRoute()
                    }
                }
                else
                {
                    Utils.Toast(message: dataArray.message ?? "", controller: self)
                }
                
            } catch {
                
                SVProgressHUD.dismiss()

                do {
                    let dataArray = try JSONDecoder().decode(MessageStruct.self,from: responseJSON as! Data)
                    Utils.Toast(message: dataArray.message ?? "", controller: self)
                } catch {
                    Utils.Toast(message: error.localizedDescription, controller: self)
                }
            }
        }
    }
    
}

//MARK:- Draw Path on Google Maps Helper Functions
extension OnTripVC {
    
    func addMarkerOnGmap(position : CLLocationCoordinate2D) {
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = position
        marker.icon = UIImage(named: "ic_pick")
        //marker.title = "Sydney"
        //marker.snippet = "Australia"
        marker.map = self.mapView
    }
    
    func drawRoute() {
        OnTripVC.getDotsToDrawRoute(positions: self.arrPositions, completion: { path in
            
            self.locationManager.startUpdatingLocation()
            
            //self.route.countRouteDistance(p: path)
            let polyline = GMSPolyline()
            polyline.path = path
            polyline.strokeColor = .blue
            polyline.strokeWidth = 4.0
            polyline.map = self.mapView
            
            print(self.arrPositions)
            
            /*
            self.mapView.camera = GMSCameraPosition(latitude: self.arrPositions.first!.latitude, longitude: self.arrPositions.first!.longitude, zoom: 14, bearing: 0, viewingAngle: 0)
            */
            
            DispatchQueue.main.async {
             if self.mapView != nil {
                let bounds = GMSCoordinateBounds(path: path)
                self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
                
                self.setupSocketMethods()
             }
            }
            
        })
    }
    
    static func getDotsToDrawRoute(positions : [CLLocationCoordinate2D], completion: @escaping(_ path : GMSPath) -> Void) {
        
        if positions.count > 1 {
            let origin = positions.first
            let destination = positions.last
            var wayPoints = ""
            
            /*
            var tempArray = [CLLocationCoordinate2D]()
            
            for objLoc in positions {
                let obj = objLoc
                
                tempArray.append(obj)
            }
            
            tempArray.remove(at: 0)
            tempArray.remove(at: tempArray.count-1)
            
            for point in tempArray {
                wayPoints = wayPoints.count == 0 ? "\(point.latitude),\(point.longitude)" : "\(wayPoints)|\(point.latitude),\(point.longitude)"
            }
            */
            
            for point in positions {
                wayPoints = wayPoints.count == 0 ? "\(point.latitude),\(point.longitude)" : "\(wayPoints)|\(point.latitude),\(point.longitude)"
            }
            
            let request = "https://maps.googleapis.com/maps/api/directions/json"
            let parameters : [String : String] = ["origin" : "\(origin!.latitude),\(origin!.longitude)", "destination" : "\(destination?.latitude ?? 0.0),\(destination?.longitude ?? 0.0)", "waypoints" : "optimize:true|\(wayPoints)", "mode" : "driving", "key" : Constant.googleMapsApiKey]
            
            //let parameters : [String : String] = [:]
            
            print(parameters)
            
            AF.request(request, method:.get, parameters : parameters).responseJSON(completionHandler: { response in
                guard let dictionary = response.value as? [String : AnyObject] //results.value
                    else {
                        return
                }
                if let routes = dictionary["routes"] as? [[String : AnyObject]] {
                    
                    if (routes.count > 0) {
                        let overview_polyline = routes[0] as? NSDictionary
                        let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary
                        let fullPath : GMSMutablePath = GMSMutablePath()
                        let points = dictPolyline?.object(forKey: "points") as? String
                        //DispatchQueue.main.async {
                            //self.drawPath(polyStr: points!,mapView:mapView)
                            
                            fullPath.appendPath(path: GMSMutablePath(fromEncodedPath: points ?? ""))
                            completion(fullPath)
                        //}
                        completion(fullPath)
                    }
                    else {
                        DispatchQueue.main.async {
                            // SVProgressHUD.dismiss()
                        }
                    }
                    
                }
            })
        }
    }
    
    func displayDriverPosition(on mapView: GMSMapView, with coordinate: CLLocationCoordinate2D) {
        if let marker = driverMarker {
            let heading = GMSGeometryHeading(marker.position, coordinate)
            marker.rotation = heading
            marker.position = coordinate
        } else {
            let marker = GMSMarker()
            marker.position = coordinate
            marker.iconView = UIImageView(image: #imageLiteral(resourceName: "CarMarker"))
            marker.map = mapView
            driverMarker = marker
        }
    }
    
}

extension GMSMutablePath {

func appendPath(path : GMSPath?) {
    if let path = path {
        for i in 0..<path.count() {
            self.add(path.coordinate(at: i))
        }
    }
}

}

//MARK:- For Car Movement
extension OnTripVC {
    
    /*
     var oldCoodinate: CLLocationCoordinate2D? = CLLocationCoordinate2DMake(CDouble((data.value(forKey: "lat") as? CLLocationCoordinate2D)), CDouble((data.value(forKey: "lng") as? CLLocationCoordinate2D)))
             var newCoodinate: CLLocationCoordinate2D? = CLLocationCoordinate2DMake(CDouble((data.value(forKey: "lat") as? CLLocationCoordinate2D)), CDouble((data.value(forKey: "lng") as? CLLocationCoordinate2D)))
             driverMarker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
             driverMarker.rotation = getHeadingForDirection(fromCoordinate: oldCoodinate, toCoordinate: newCoodinate)
             //found bearing value by calculation when marker add
             driverMarker.position = oldCoodinate
             //this can be old position to make car movement to new position
             driverMarker.map = mapView_
             //marker movement animation
             CATransaction.begin()
             CATransaction.setValue(Int(2.0), forKey: kCATransactionAnimationDuration)
             CATransaction.setCompletionBlock({() -> Void in
                 driverMarker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
                 driverMarker.rotation = CDouble(data.value(forKey: "bearing"))
                 //New bearing value from backend after car movement is done
             })
             driverMarker.position = newCoodinate
             //this can be new position after car moved from old position to new position with animation
             driverMarker.map = mapView_
             driverMarker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
             driverMarker.rotation = getHeadingForDirection(fromCoordinate: oldCoodinate, toCoordinate: newCoodinate)
             //found bearing value by calculation
             CATransaction.commit()
    */
    
    func moveDriver(oldLoc : CLLocationCoordinate2D, newLoc : CLLocationCoordinate2D) {
        var oldCoodinate: CLLocationCoordinate2D? = oldLoc
        var newCoodinate: CLLocationCoordinate2D? = newLoc
        self.driverMarker?.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
        self.driverMarker?.rotation = CLLocationDegrees(getHeadingForDirection(fromCoordinate: oldCoodinate ?? CLLocationCoordinate2D(), toCoordinate: newCoodinate ?? CLLocationCoordinate2D()))
        //found bearing value by calculation when marker add
        self.driverMarker?.position = oldCoodinate ?? CLLocationCoordinate2D()
        //this can be old position to make car movement to new position
        self.driverMarker?.map = self.mapView
        //marker movement animation
        CATransaction.begin()
        CATransaction.setValue(Int(2.0), forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock({() -> Void in
            self.driverMarker?.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
            //driverMarker.rotation = CDouble(data.value(forKey: "bearing"))
            //New bearing value from backend after car movement is done
        })
        self.driverMarker?.position = newCoodinate!
        //this can be new position after car moved from old position to new position with animation
        self.driverMarker?.map = self.mapView
        self.driverMarker?.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
        self.driverMarker?.rotation = CLLocationDegrees(getHeadingForDirection(fromCoordinate: oldCoodinate!, toCoordinate: newCoodinate!))
        //found bearing value by calculation
        CATransaction.commit()
    }
    
    
    func getHeadingForDirection(fromCoordinate fromLoc: CLLocationCoordinate2D, toCoordinate toLoc: CLLocationCoordinate2D) -> Float {

            let fLat: Float = Float((fromLoc.latitude).degreesToRadians)
            let fLng: Float = Float((fromLoc.longitude).degreesToRadians)
            let tLat: Float = Float((toLoc.latitude).degreesToRadians)
            let tLng: Float = Float((toLoc.longitude).degreesToRadians)
            let degree: Float = (atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))).radiansToDegrees
            if degree >= 0 {
                return degree
            }
            else {
                return 360 + degree
            }
        }
    
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}


//MARK:- AES related code
extension OnTripVC {
  

    
}

extension String {
    /*
     func cryptoSwiftAESEncrypt(key: String, iv: String ) -> String? {
             guard let dec = try? AES(key: key, iv: iv, padding: .noPadding).encrypt(Array(self.utf8)) else {   return nil }
             let decData = Data(bytes: dec, count: Int(dec.count)).base64EncodedString(options: .lineLength64Characters)
             return decData
     }
     
     func cryptoSwiftAESDecrypt(key: String, iv: String) -> String? {
           guard let dec = try? AES(key: key, iv: iv, padding: .noPadding).decrypt(Array(self.utf8)) else {    return nil    }
           let decData = Data(bytes: dec, count: Int(dec.count)).base64EncodedString(options: .lineLength64Characters)
           return decData
     }
     */
    
}
