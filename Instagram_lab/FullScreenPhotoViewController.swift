//
//  FullScreenPhotoViewController.swift
//  Instagram_lab
//
//  Created by daniel on 12/30/16.
//  Copyright © 2016 Notabela. All rights reserved.
//

import UIKit
import AFNetworking

class FullScreenPhotoViewController: UIViewController, UIScrollViewDelegate
{

    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var photoView: UIImageView!
    var imageUrl: URL!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        photoScrollView.delegate = self
        photoView.setImageWith(imageUrl)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return photoView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView)
    {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        self.photoScrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
    }

    @IBAction func onDismiss(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }


}
