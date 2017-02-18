//
//  ViewController.swift
//  boyz
//
//  Created by Arthur De Araujo on 2/17/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit
import RadarSDK
import CoreLocation
import FacebookLogin
import FacebookCore
import FacebookShare
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit
import UserNotifications

class ViewController: UIViewController, RadarDelegate {
    
    let myLoginButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let accessToken = AccessToken.current {
            print("Facebook Access Token: ", accessToken.userId!);
            getFacebookUserData()
        }else if myLoginButton.superview == nil {
            configureFBLoginButton()
        }
    }
    
    func configureFBLoginButton(){
        myLoginButton.backgroundColor = UIColor.darkGray
        
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 180, height: 40))
        myLoginButton.frame = rect;
        myLoginButton.center = view.center;
        myLoginButton.setTitle("My Login Button", for: .normal)
        
        // Handle clicks on the button
        myLoginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
        
        // Add the button to the view
        view.addSubview(myLoginButton)
    }

    // Once the button is clicked, show the login dialog
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .userFriends, .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                self.getFacebookUserData()
            }
        }
    }
    
    func getFacebookUserData(){
        print("Getting facebook data")
        let connection = GraphRequestConnection()
        let params = ["fields" : "email, name"]
        
        connection.add(GraphRequest(graphPath: "/me", parameters: params)) { httpResponse, result in
            switch result {
            case .success(let response):
                if let responseDictionary = response.dictionaryValue {
                    print("Graph Request Succeeded: \(responseDictionary)")
                    
                    self.configureRadar(userId: responseDictionary["id"] as! String, email: responseDictionary["email"] as! String, fullName: responseDictionary["name"] as! String)
                }
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
        connection.start()
    }
    
    func configureRadar(userId:String, email:String, fullName:String){
        // User is logged in, use 'accessToken' here.
        let status = Radar.authorizationStatus()
        
        print("Radar Authorized Status: ", status);
        print("Radar Started Tracking");
        
        Radar.requestAlwaysAuthorization()
        
        Radar.setUserId(userId)
        
        Radar.setDescription(fullName);
        //Radar.setDescription(fullName + " : " + email);
        Radar.startTracking()
        Radar.setDelegate(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveEvents(_ events: [RadarEvent], user: RadarUser) {
        print("Received Event!")
        print(events)
        // do something with events, user
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound];
        
        let content = UNMutableNotificationContent()
        content.title = "Boyz"
        content.body = "Spagettttt"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1.0,
            repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "1.second.message",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(
            request, withCompletionHandler: nil)
    }
    
    func didFail(status: RadarStatus) {
        print("Failed Event!")
        
        // do something with status
    }
    
    //MARK: UBActions
    
    @IBAction func pressedLogout(_ sender: Any) {
        //Logout of facebook
    }
    
    
    
}

