//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Weiran Xiong on 3/3/19.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var tweetArray = [NSDictionary]()
    var numberOfTweet: Int!
    var profileDataArray = [Data?]()
    
    let myRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 122
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTweets()
    }
    
    @objc func loadTweets() {
        
        numberOfTweet = 20
        
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count": numberOfTweet!]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: params, success: { (tweets) in
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
                let user = tweet["user"] as! NSDictionary
                let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
                let data = try? Data(contentsOf: imageUrl!)
                self.profileDataArray.append(data)
                
            }
            
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
            
        }, failure: { (err) in
            print(err)
            print("Could not retreive tweets")
        })
        
    }
    
    
    func loadMoreTweets() {
        
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweet = numberOfTweet + 20
        let params = ["count": numberOfTweet!]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: params, success: { (tweets) in
//            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
                let user = tweet["user"] as! NSDictionary
                let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
                let data = try? Data(contentsOf: imageUrl!)
                self.profileDataArray.append(data)

            }

            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
            
        }, failure: { (err) in
            print("Could not retreive tweets")
        })
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 10 == tweetArray.count {
            DispatchQueue.global(qos: .userInteractive).sync {
                self.loadMoreTweets()
            }
//            loadMoreTweets()
        }
    }
    
    

    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.usernameLabel.text = user["name"] as? String
        cell.tweetContentLabel.text = tweetArray[indexPath.row]["text"] as? String
        
//        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
//        let data = try? Data(contentsOf: imageUrl!)
//
//        if let imageData = data {
//            cell.profileImageView.image = UIImage(data: imageData)
//        }

        if let imageData = profileDataArray[indexPath.row] {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        cell.setRetweeted(tweetArray[indexPath.row]["retweeted"] as! Bool)
        
        return cell
    }
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }
    


}
