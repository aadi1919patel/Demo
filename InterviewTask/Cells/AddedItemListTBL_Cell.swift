//
//  AddedItemListTBL_Cell.swift
//  InterviewTask
//
//  Created by d3vil_mind on 03/08/21.
//

import UIKit

class AddedItemListTBL_Cell: UITableViewCell {

    var btnEditClick : ((_ aCell : AddedItemListTBL_Cell) -> Void)?
    var btnDeleteClick : ((_ aCell : AddedItemListTBL_Cell) -> Void)?
    
    @IBOutlet weak var imgItemImage: UIImageView!
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblItemCategory: UILabel!
    @IBOutlet weak var lblItemPrice: UILabel!
    @IBOutlet weak var lblItemInStock: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func btnEditAction(_ sender: UIButton) {
        if ((self.btnEditClick) != nil) {
            self.btnEditClick!(self)
        }
    }
    
    @IBAction func btnDeleteAction(_ sender: UIButton) {
        if ((self.btnDeleteClick) != nil) {
            self.btnDeleteClick!(self)
        }
    }
    
}
