//
//  PhotoDetailsViewController.swift
//  Instagram_lab
//
//  Created by daniel on 12/29/16.
//  Copyright © 2016 Notabela. All rights reserved.
//

import UIKit
import AFNetworking

class PhotoDetailsViewController: UIViewController
{

    @IBOutlet weak var photoView: UIImageView!
    
    var imageUrl: URL!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        photoView.setImageWith(imageUrl)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapPhoto))
        photoView.addGestureRecognizer(tapRecognizer)
        
    }
    
    func onTapPhoto()
    {
        performSegue(withIdentifier: "fullScreenSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "fullScreenSegue"
        {
            let vc = segue.destination as! FullScreenPhotoViewController
            vc.imageUrl = self.imageUrl
        }
    }



}
