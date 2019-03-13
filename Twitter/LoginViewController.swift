//
//  LoginViewController.swift
//  Twitter
//
//  Created by Weiran Xiong on 3/3/19.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "userLoggedIn") == true {
            self.performSegue(withIdentifier: "loginToHome", sender: self)
        }
        
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        let url = "https://api.twitter.com/oauth/request_token"
        
        TwitterAPICaller.client?.login(url: url, success: {
            UserDefaults.standard.set(true, forKey: "userLoggedIn")
            self.performSegue(withIdentifier: "loginToHome", sender: self)
        }, failure: { (err) in
            print(err)
        })
    }


}
