//
//  CategoryListTBL_Cell.swift
//  InterviewTask
//
//  Created by d3vil_mind on 03/08/21.
//

import UIKit

class CategoryListTBL_Cell: UITableViewCell {

    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var lblCatName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
