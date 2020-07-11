//
//  FeedViewController.swift
//  Parstagram
//
//  Created by nguyen thy on 7/10/20.
//  Copyright © 2020 Han Nguyen. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
//        self.tableView.rowHeight = UITableView.automaticDimension
//        self.tableView.estimatedRowHeight = 200
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let query = PFQuery(className: "Posts")
        query.limit = 20
        query.includeKey("author") //Actual objects not pointers
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        let user = post["author"] as! PFUser
        let caption = post["caption"] as? String ?? ""
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url
        let url = URL(string: urlString!)
        
        cell.imageView!.af.setImage(withURL: url!)
        
        cell.usernameLabel.text = user.username!
        cell.captionLabel.text = caption
        
  
        
        return cell
    }
    
    
}
