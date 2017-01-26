//
//  ViewController.swift
//  Instagram_lab
//
//  Created by daniel on 12/26/16.
//  Copyright © 2016 Notabela. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    var data: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var loadingMoreView:InfiniteScrollActivityView? //infinite scroll indicator
    
    var isMoreDataLoading = false
    var blogName = "theatlasofbeauty"
    var offset = 20
    var themeColor = UIColor(red: 52/255, green: 69/255, blue: 94/255, alpha: 1)
    
    override func viewDidLoad()
    {
        initTableView()
        requestData()
    
        //Create a refreshControl Element and customize if you want
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.white
        refreshControl.tintColor = themeColor
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        //setup Infinite Scrolling loader
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (!isMoreDataLoading)
        {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging)
            {
                isMoreDataLoading = true
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                loadMoreData()
            }
            
        }
    }
    
    //MARK: Implement tableView Protocol Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 70))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 25
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1
        
        
        //set the avatar
        profileView.setImageWith(URL(string:"https://api.tumblr.com/v2/blog/\(blogName).tumblr.com/avatar")!)
        headerView.addSubview(profileView)
        
        //Add UILabel for the date here
        var timeStamp: String?
        if let time = data?[section].value(forKey: "date") as? String
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss 'GMT'"
            let date = dateFormatter.date(from: time)!
            timeStamp = dateFormatter.timeSince(from: date, numericDates: true)
        }
        
        let label = UILabel(frame: CGRect(x: 200, y: 23, width: 165, height: 30))
        label.textColor = themeColor
        label.textAlignment = .right
        label.text = timeStamp ?? ""
        headerView.addSubview(label)
        
        return headerView
    }
    
    func refreshAction()
    {
        self.data = []
        
        let clientId = "Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
        let url = URL(string: "https://api.tumblr.com/v2/blog/\(blogName).tumblr.com/posts/photo?api_key=\(clientId)")
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        
        let task: URLSessionDataTask = session.dataTask(with: request)
        {
            (dataorNil, response, error) in
            
            if let data = dataorNil {
                
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: [])
                    as? NSDictionary {
                    
                    let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                    self.data = responseFieldDictionary["posts"] as? [NSDictionary]
                    self.offset = 20
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "photoDetailsSegue", sender: tableView.cellForRow(at: indexPath))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.notabela.photoCell", for: indexPath) as! PhotoCell
        
        let post = data?[indexPath.section]
        
        //we need to navigate through several dicts to get photos
        if let photos = post?.value(forKeyPath: "photos") as? [NSDictionary]
        {
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            
            if let imageUrl = URL(string: imageUrlString!)
            {
                let imageRequest = URLRequest(url: imageUrl)
                cell.photoView.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                        
                        // imageResponse will be nil if the image is cached
                        if imageResponse != nil
                        {
                            cell.photoView.alpha = 0.0
                            cell.photoView.image = image
                            UIView.animate(withDuration: 0.3)
                            {
                                cell.photoView.alpha = 1.0
                            }
                        }
                        else
                        {
                            cell.photoView.image = image
                        }
                },
                    failure: { (imageRequest, imageResponse, error) -> Void in
                        // do something for the failure condition
                })
            }
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "photoDetailsSegue"
        {
            let vc = segue.destination as! PhotoDetailsViewController
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)

            let post = data?[(indexPath?.section)!]
            
            //we need to navigate through several dicts to get photos
            if let photos = post?.value(forKeyPath: "photos") as? [NSDictionary]
            {
                let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
                
                if let imageUrl = URL(string: imageUrlString!)
                {
                    vc.imageUrl = imageUrl
                }
            }
        }
    }
    
    //MARK: Fireup a network request to the Instagram API
    private func requestData()
    {
        
        let clientId = "Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
        let url = URL(string: "https://api.tumblr.com/v2/blog/theatlasofbeauty.tumblr.com/posts/photo?api_key=\(clientId)")
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        
        let progressBar = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressBar.tintColor = themeColor
        
        let task: URLSessionDataTask = session.dataTask(with: request)
        {
            (dataorNil, response, error) in
            
            if let data = dataorNil {
                
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: [])
                    as? NSDictionary {
                    
                    let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                    self.data = responseFieldDictionary["posts"] as? [NSDictionary]
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    self.tableView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    private func loadMoreData()
    {
        let clientId = "Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
        let url = URL(string: "https://api.tumblr.com/v2/blog/\(blogName).tumblr.com/posts/photo?api_key=\(clientId)&limit=50&offset=\(offset)")
            offset += 50
            print(offset)
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        
        let task: URLSessionDataTask = session.dataTask(with: request)
        {
            (dataorNil, response, error) in
            
            if let data = dataorNil {
                
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: [])
                    as? NSDictionary {
                    
                    let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                    let newData = responseFieldDictionary["posts"] as? [NSDictionary]
                    self.data?.append(contentsOf: newData!)
                    
                    self.loadingMoreView!.stopAnimating()
                    self.isMoreDataLoading = false
                    self.tableView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    //MARK: Initialize tableView
    private func initTableView()
    {
        tableView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellReuseIdentifier: "com.notabela.photoCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 375
        tableView.separatorStyle = .none
    }
    
}

