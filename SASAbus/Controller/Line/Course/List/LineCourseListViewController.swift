import UIKit
import RxSwift
import RxCocoa

class LineCourseListViewController: UITableViewController {

    var parentVC: LineCourseViewController!

    var vehicle: Int = 0
    var lineId: Int = 0

    var items = [LineCourse]()

    var dotImage = UIImage(named: "line_course_dot")
    var dotsImage = UIImage(named: "line_course_dots_5")

    var timeFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    weak var activityIndicatorView: UIActivityIndicatorView!


    init(parent: LineCourseViewController, lineId: Int, vehicle: Int) {
        self.parentVC = parent
        self.lineId = lineId
        self.vehicle = vehicle

        super.init(nibName: "LineCourseListViewController", bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        if vehicle == 0 && lineId == 0 {
            fatalError("vehicle == 0 && lineId == 0")
        }

        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        tableView.backgroundView = activityIndicatorView
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none

        self.activityIndicatorView = activityIndicatorView
        self.activityIndicatorView.hidesWhenStopped = true

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 56.0
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.register(UINib(nibName: "LineCourseViewCell", bundle: nil), forCellReuseIdentifier: "LineCourseViewCell")

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(parseData), for: UIControlEvents.valueChanged)

        activityIndicatorView.startAnimating()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let row = tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: row, animated: true)
        }
    }


    // MARK: - Data loading

    func parseData() {
        parentVC.parseData()
    }

    func onSuccess(items: [LineCourse]) {
        self.items.removeAll()
        self.items.append(contentsOf: items)
        self.tableView.reloadData()

        self.activityIndicatorView.stopAnimating()
        self.refreshControl?.endRefreshing()
    }

    func onError(error: NSError) {
        print("onError: \(error)")

        self.items.removeAll()
        self.tableView.reloadData()

        self.activityIndicatorView.stopAnimating()
        self.refreshControl?.endRefreshing()
    }
}

extension LineCourseListViewController {

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LineCourseViewCell", for: indexPath) as! LineCourseViewCell

        let index = indexPath.row
        let item = items[index]

        if index == 0 || index == items.count - 1 {
            cell.indicator.image = dotImage
        } else {
            cell.indicator.image = dotsImage
        }

        if index >= 1 && !items[index - 1].active && item.active || item.dot {
            cell.indicator.image = dotImage
        }

        if item.active {
            cell.title.textColor = Color.textPrimary
            cell.indicator.tint(with: Color.textPrimary)
        } else {
            cell.title.textColor = Color.textSecondary
            cell.indicator.tint(with: Color.textSecondary)
        }

        let busStop = item.busStop
        let name: String = (Utils.locale() == "de" ? busStop.nameDe : busStop.nameIt)!
        let munic: String = (Utils.locale() == "de" ? busStop.municDe : busStop.municIt)!

        cell.title.text = "\(item.time) - \(name) (\(munic))"
        cell.subtitle.attributedText = item.lineText
        cell.subtitle.lineBreakMode = .byTruncatingTail


        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO segue to bus stop departures
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
