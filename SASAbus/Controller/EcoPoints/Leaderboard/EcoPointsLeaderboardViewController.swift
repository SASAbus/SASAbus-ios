import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import StatefulViewController

class EcoPointsLeaderboardViewController: UIViewController, UITableViewDataSource,
        UITableViewDelegate, StatefulViewController {

    @IBOutlet weak var tableView: UITableView!

    var parentVC: EcoPointsViewController!

    var leaderboard = [LeaderboardPlayer]()


    init() {
        super.init(nibName: "EcoPointsLeaderboardViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "EcoPointsLeaderboardUserCell", bundle: nil), forCellReuseIdentifier: "eco_points_leaderboard_user")
        tableView.register(UINib(nibName: "EcoPointsLeaderboardFooterCell", bundle: nil), forCellReuseIdentifier: "eco_points_leaderboard_footer")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 56.0

        loadingView = LoadingView(frame: view.frame)
        emptyView = EmptyView(frame: view.frame)
        errorView = ErrorView(frame: view.frame, target: self, action: #selector(parseLeaderboard))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupInitialViewState()

        initRefreshControl()
        parseLeaderboard()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboard.isEmpty ? 0 : leaderboard.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == leaderboard.count {
            return tableView.dequeueReusableCell(withIdentifier: "eco_points_leaderboard_footer")!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "eco_points_leaderboard_user") as! EcoPointsLeaderboardUserCell

            let item = leaderboard[indexPath.row]

            cell.nameText.text = item.username
            cell.pointsText.text = "\(item.points) points"
            cell.rankText.text = "\(indexPath.row + 1)"

            let url = URL(string: Endpoint.API + Endpoint.ECO_POINTS_PROFILE_PICTURE_USER + String(item.profile))!
            cell.profileImage.kf.setImage(with: url)

            return cell
        }
    }


    func hasContent() -> Bool {
        return !leaderboard.isEmpty
    }


    func parseLeaderboard() {
        startLoading(animated: false)

        if !NetUtils.isOnline() {
            endLoading(animated: false, error: NetUtils.networkError())
            Log.error("Device offline")
            return
        }

        _ = EcoPointsApi.getLeaderboard(page: 1)
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { leaderboard in
                    self.leaderboard.append(contentsOf: leaderboard)

                    self.tableView.reloadData()
                    self.tableView.refreshControl!.endRefreshing()

                    self.endLoading(animated: false)
                }, onError: { error in
                    self.endLoading(animated: false, error: error)
                    Log.error("Couldn't load leaderboard: \(error)")
                })
    }

    func initRefreshControl() {
        let refreshControl = UIRefreshControl()

        refreshControl.tintColor = Theme.lightOrange
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull to refresh", comment: ""),
                attributes: [NSForegroundColorAttributeName: Theme.darkGrey])
        refreshControl.addTarget(self, action: #selector(EcoPointsLeaderboardViewController.parseLeaderboard), for: UIControlEvents.valueChanged)

        self.tableView.refreshControl = refreshControl
    }
}
