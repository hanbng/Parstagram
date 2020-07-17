//
//  FeedViewController.swift
//  Parstagram
//
//  Created by nguyen thy on 7/10/20.
//  Copyright © 2020 Han Nguyen. All rights reserved.
//

import UIKit
import Parse
import MessageInputBar

class FeedViewController: UIViewController, MessageInputBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    
    var posts = [PFObject]()
    var selectedPost : PFObject!
    var showsCommentBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create a comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()
        
        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Saved comment")
            } else {
                print("Error \(error)")
            }
        }
        
        tableView.reloadData()
        
        // Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let query = PFQuery(className: "Posts")
        query.limit = 20
        query.includeKeys(["author", "comments", "comments.author"]) //Actual objects not pointers
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!.reversed()
                self.tableView.reloadData()
            }
        }
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
        
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate = self.view.window!.windowScene!.delegate as! SceneDelegate
        delegate.window?.rootViewController = loginVC
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = post["comments"] as? [PFObject] ?? []
        return comments.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = post["comments"] as? [PFObject] ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            let user = post["author"] as! PFUser
            let caption = post["caption"] as? String ?? ""
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url
            let url = URL(string: urlString!)
            
            cell.imageView!.af.setImage(withURL: url!)
            
            cell.usernameLabel.text = user.username!
            cell.captionLabel.text = caption
            return cell
            
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            let comment = comments[indexPath.row - 1]
            
            let user = comment["author"] as! PFUser
        
            cell.nameLabel.text = user.username as! String
            cell.commentLabel.text = comment["text"] as! String
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell", for: indexPath)
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        selectedPost = post
        
        let comments = post["comments"] as? [PFObject] ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
        }
    }
    
}
