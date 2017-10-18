import UIKit
import Kingfisher
import RxSwift
import RxCocoa

class EcoPointsBadgesViewController: UITableViewController {

    var nextBadges = [Badge]()
    var earnedBadges = [Badge]()


    init() {
        super.init(nibName: "EcoPointsBadgesViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "EcoPointsBadgeCell", bundle: nil), forCellReuseIdentifier: "eco_points_badge")
        tableView.register(UINib(nibName: "EcoPointsBadgeFooterCell", bundle: nil), forCellReuseIdentifier: "eco_points_badge_footer")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 56.0

        initRefreshControl()
        parseData()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 0

        if !nextBadges.isEmpty {
            sections += 1
        }

        if !earnedBadges.isEmpty {
            sections += 1
        }

        return sections
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? L10n.Ecopoints.Badges.Section.next : L10n.Ecopoints.Badges.Section.earned
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return nextBadges.count + 1
        }

        return earnedBadges.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == nextBadges.count {
                return tableView.dequeueReusableCell(withIdentifier: "eco_points_badge_footer", for: indexPath)
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "eco_points_badge", for: indexPath) as! EcoPointsBadgeCell

                let item = nextBadges[indexPath.row]

                cell.title.text = item.title
                cell.subtitle.text = item.description

                let url = URL(string: item.iconUrl)!
                cell.badgeImage.kf.setImage(with: url)

                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "eco_points_badge", for: indexPath) as! EcoPointsBadgeCell

            let item = earnedBadges[indexPath.row]

            cell.title.text = item.title
            cell.subtitle.text = item.description

            let url = URL(string: item.iconUrl)!
            cell.badgeImage.kf.setImage(with: url)

            return cell
        }
    }


    // MARK: - Data loading

    func parseData() {
        parseNextBadges()
        parseEarnedBadges()
    }

    func parseNextBadges() {
        if !NetUtils.isOnline() {
            Log.error("Device offline")
            return
        }

        _ = EcoPointsApi.getNextBadges()
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { badges in
                    self.nextBadges.removeAll()
                    self.nextBadges.append(contentsOf: badges)

                    self.tableView.reloadData()
                    self.refreshControl!.endRefreshing()
                }, onError: { error in
                    Utils.logError(error, message: "Couldn't load next badges")
                    AuthHelper.checkIfUnauthorized(error)
                })
    }

    func parseEarnedBadges() {
        if !NetUtils.isOnline() {
            Log.error("Device offline")
            return
        }

        _ = EcoPointsApi.getEarnedBadges()
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { badges in
                    self.earnedBadges.removeAll()
                    self.earnedBadges.append(contentsOf: badges)

                    self.tableView.reloadData()
                    self.refreshControl!.endRefreshing()
                }, onError: { error in
                    Utils.logError(error, message: "Couldn't load earned badges")
                    AuthHelper.checkIfUnauthorized(error)
                })
    }


    func initRefreshControl() {
        let refreshControl = UIRefreshControl()

        refreshControl.tintColor = Theme.lightOrange
        refreshControl.attributedTitle = NSAttributedString(string: L10n.General.pullToRefresh,
                attributes: [NSForegroundColorAttributeName: Theme.darkGrey])
        refreshControl.addTarget(self, action: #selector(EcoPointsBadgesViewController.parseData), for: UIControlEvents.valueChanged)

        self.refreshControl = refreshControl
    }
}
