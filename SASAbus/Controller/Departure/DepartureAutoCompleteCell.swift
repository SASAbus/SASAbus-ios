import UIKit

class DepartureAutoCompleteCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.label.textColor = UIColor.white
            self.backgroundColor = Theme.orange
        } else {
            self.label.textColor = Theme.darkGrey
            self.backgroundColor = UIColor.white
        }
    }
}
