import UIKit
import SwiftyJSON

class ChangelogViewController: UITableViewController, UIToolbarDelegate {
    
    struct Item {
        
        var title: String
        var changes: String
    }
    
    var items = [Item]()

    init() {
        super.init(nibName: "ChangelogViewController", bundle: nil)

        title = "Changelog"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parseData()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "changelog") ??  UITableViewCell(style: .default, reuseIdentifier: "changelog")
        
        let item = items[indexPath.section]
        
        cell.textLabel?.text = item.changes
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func parseData() {
        var language = Locales.get()
        
        if language != "de" || language != "it" || language != "en" {
            language = "en"
        }
        
        let fileName = "changelog_\(language)"
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            Log.error("Could not open json file '\(fileName)'")
            return
            
        }
        
        let string = try! String(contentsOf: url, encoding: .utf8)
        
        let json = JSON(parseJSON: string)
        
        for entry in json.arrayValue {
            let changes = entry["changes"].arrayValue.map {
                $0.stringValue
            }.joined(separator: "\n")
            
            let item = Item(
                title: entry["title"].stringValue,
                changes: changes
            )
            
            items.append(item)
        }
        
        tableView.reloadData()
    }
}
