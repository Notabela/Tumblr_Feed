//
//  ViewController.swift
//  Instagram_lab
//
//  Created by daniel on 12/26/16.
//  Copyright © 2016 Notabela. All rights reserved.
//

import UIKit
import Foundation

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    var data: NSDictionary?
    
    override func viewDidLoad()
    {
        
        data = requestData()
    }
    
    //MARK: Implement tableView Protocol Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.notabela.photoCell", for: indexPath) as! PhotoCell
        
        
        return cell
    }
    
    //MARK: Fireup a network request to the Instagram API
    private func requestData() -> NSDictionary?
    {
        var outputData: NSDictionary?
        
        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url = URL(string: "https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        
        let task: URLSessionDataTask = session.dataTask(with: request)
        {
            (dataorNil, response, error) in
            
            if let data = dataorNil {
                
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: [])
                    as? NSDictionary {
                    
                    outputData = responseDictionary
                    NSLog("response \(responseDictionary)")
                }
            }
        }
        task.resume()
        
        return outputData
    }
    
    //MARK: Initialize tableView
    private func initTableView()
    {
        tableView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellReuseIdentifier: "com.notabela.photoCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

