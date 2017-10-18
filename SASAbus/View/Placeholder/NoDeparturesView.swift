import Foundation
import UIKit

class NoDeparturesView: BasicPlaceholderView {
    
    let label = UILabel()
    
    override func setupView() {
        super.setupView()
        
        label.text = L10n.Departures.emptyState
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Theme.darkGrey
        label.numberOfLines = 0
        label.textAlignment = .center
        
        centerView.addSubview(label)
        
        let vertical = NSLayoutConstraint(
            item: label, attribute: .centerY, relatedBy: .equal,
            toItem: centerView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0
        )
        
        let margins = centerView.layoutMarginsGuide
        label.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
        
        NSLayoutConstraint.activate([vertical])
    }
}
