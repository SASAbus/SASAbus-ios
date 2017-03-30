import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class EcoPointsProfileViewController: UITableViewController {

    var parentVC: EcoPointsViewController!

    @IBOutlet weak var profilePicture: UIImageView!

    @IBOutlet weak var pointsImage: UIImageView!
    @IBOutlet weak var rankImage: UIImageView!
    @IBOutlet weak var badgesImage: UIImageView!

    @IBOutlet weak var pointsText: UILabel!
    @IBOutlet weak var rankText: UILabel!
    @IBOutlet weak var badgesText: UILabel!

    var profile: Profile?


    init() {
        super.init(nibName: "EcoPointsProfileViewController", bundle: nil)
    }

    override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "EcoPointsProfileCell", bundle: nil), forCellReuseIdentifier: "eco_points_profile_header")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 56.0

        initRefreshControl()
        parseProfile()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eco_points_profile_header") as! EcoPointsProfileCell

        if let profile = self.profile {
            cell.nameText.text = profile.username
            cell.levelText.text = profile.cls

            cell.pointsText.text = "\(profile.points)"
            cell.badgesText.text = "\(profile.badges)"
            cell.rankText.text = "\(profile.rank)"

            let profileId: Int = (self.profile?.profile)!
            let url = URL(string: Endpoint.API + Endpoint.ECO_POINTS_PROFILE_PICTURE_USER + String(profileId))!
            cell.profilePicture.kf.setImage(with: url)

            cell.loadingView.alpha = 0
        } else {
            cell.loadingView.alpha = 1
        }

        return cell
    }


    func parseProfile() {
        if !NetUtils.isOnline() {
            Log.error("Device offline")
            return
        }

        _ = EcoPointsApi.getProfile()
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { profile in
                    if let profile = profile {
                        self.profile = profile
                    } else {
                        Log.warning("No profile loaded")
                    }

                    self.tableView.reloadData()
                    self.refreshControl!.endRefreshing()
                }, onError: { error in
                    Log.error("Couldn't load profile: \(error)")
                })
    }

    func initRefreshControl() {
        let refreshControl = UIRefreshControl()

        refreshControl.tintColor = Theme.lightOrange
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull to refresh", comment: ""),
                attributes: [NSForegroundColorAttributeName: Theme.darkGrey])
        refreshControl.addTarget(self, action: "parseProfile", for: UIControlEvents.valueChanged)

        self.refreshControl = refreshControl
    }
}
