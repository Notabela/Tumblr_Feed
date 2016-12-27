//
//  PhotoCell.swift
//  Instagram_lab
//
//  Created by daniel on 12/27/16.
//  Copyright © 2016 Notabela. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell
{

    @IBOutlet weak var photoView: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
