import Foundation
import UIKit
import Kingfisher
import RxSwift
import RxCocoa
import SwiftyJSON

class EcoPointsProfilePictureDefaultViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var items: [String] = []

    var activityIndicator: UIActivityIndicatorView!

    var menuActivityIndicator: UIActivityIndicatorView!
    var isOperationRunning: Bool = false

    var parentVC: EcoPointsSettingsViewController


    init(parent: EcoPointsSettingsViewController) {
        self.parentVC = parent

        super.init(nibName: "EcoPointsProfilePictureDefaultViewController", bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.register(UINib(nibName: "EcoPointsProfilePictureDefaultCell", bundle: nil),
                forCellWithReuseIdentifier: "EcoPointsProfilePictureDefaultCell")

        collectionView?.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 72, right: 0)
        collectionView?.frame = self.view.bounds

        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()

        collectionView?.backgroundView = activityIndicator

        menuActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        let activityButton = UIBarButtonItem(customView: menuActivityIndicator!)
        navigationItem.rightBarButtonItems = [activityButton]

        loadImages()
    }


    func loadImages() {
        _ = EcoPointsApi.getProfilePictures()
                .subscribeOn(MainScheduler.background)
                .map { response -> [String] in
                    let strings: [String] = response["pictures"].arrayValue.map { string in
                        response["directory"].stringValue + string.stringValue
                    }

                    return strings
                }
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { strings in
                    self.activityIndicator.stopAnimating()

                    self.items.removeAll()
                    self.items.append(contentsOf: strings)

                    self.collectionView?.reloadData()
                }, onError: { error in
                    Log.error("Could not load profile pictures: \(error)")
                    self.activityIndicator.stopAnimating()
                })
    }
}

extension EcoPointsProfilePictureDefaultViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EcoPointsProfilePictureDefaultCell",
                for: indexPath) as! EcoPointsProfilePictureDefaultCell

        let url = URL(string: items[indexPath.row])
        cell.image.kf.setImage(with: url)

        return cell
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isOperationRunning {
            return
        }

        isOperationRunning = true

        collectionView.isUserInteractionEnabled = false

        let item = items[indexPath.row]

        menuActivityIndicator.startAnimating()

        _ = EcoPointsApi.upload(url: item)
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { _ in
                    Log.error("Updated profile picture")

                    self.parentVC.updateProfilePicture(url: item)

                    self.navigationController?.popViewController(animated: true)
                }, onError: { error in
                    Log.error("Could not set profile picture")

                    self.showCloseDialog(title: "Could not change picture", message: "Please retry later again", handler: { _ in
                        self.navigationController?.popViewController(animated: true)
                    })
                })

    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.size.width / 3.2, height: 100)
    }
}
