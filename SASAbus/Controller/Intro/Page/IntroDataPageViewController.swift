import UIKit
import RxSwift
import RxCocoa

class IntroDataPageViewController: IntroPageViewController {

    @IBOutlet weak var doneImage: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var closeButton: UIButton!

    var parentVC: IntroViewController!

    var downloadComplete: Bool = false
    var showCloseButton: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()

        doneImage.tint(with: color)

        doneImage.alpha = 0

        closeButton.isHidden = true
        closeButton.alpha = 0

        let click = UITapGestureRecognizer(target: self, action: #selector(finishIntro))
        click.numberOfTapsRequired = 1

        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(click)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !downloadComplete {
            parentVC.setSwipeable(swipeable: false)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.downloadData()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        closeButton.layer.cornerRadius = closeButton.frame.size.height / 2
        closeButton.layer.masksToBounds = true
    }


    // MARK: - Data downloading

    func downloadData() {
        if !NetUtils.isOnline() {
            self.deviceOffline()
            return
        }

        _ = PlannedData.downloadPlanData()
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(
                        onNext: { progress in
                            self.progressView.progress = progress
                        },
                        onError: { error in
                            Utils.logError(error)
                            
                            self.downloadComplete = false
                            self.onError()
                        },
                        onCompleted: {
                            self.downloadComplete = true

                            UIView.animate(withDuration: 0.4) {
                                self.progressView.alpha = 0
                            }

                            self.doneImage.alpha = 0
                            self.doneImage.transform = CGAffineTransform(scaleX: 0, y: 0)

                            UIView.animate(withDuration: 0.3, delay: 0.45, animations: {
                                self.doneImage.alpha = 1
                                self.doneImage.transform = CGAffineTransform(scaleX: 1, y: 1)
                            })

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                self.parentVC.setSwipeable(swipeable: true)
                            }

                            Log.debug("Completed data download")

                            if self.showCloseButton {
                                self.closeButton.isHidden = false

                                UIView.animate(withDuration: 0.3, delay: 0.45, animations: {
                                    self.closeButton.alpha = 1
                                })
                            }
                        })
    }

    func deviceOffline() {
        let alert = UIAlertController(title: "No internet connection", message: "Data download requires an internet connection.",
                preferredStyle: UIAlertControllerStyle.alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (_) in
            exit(1)
        }
        let defaultAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default) { (_) in
            self.downloadData()
        }

        alert.addAction(cancelAction)
        alert.addAction(defaultAction)

        present(alert, animated: true)
    }

    func onError() {
        let alert = UIAlertController(title: nil, message: "Could not download data", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (_) in
            exit(1)
        }
        let defaultAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default) { (_) in
            self.downloadData()
        }

        alert.addAction(cancelAction)
        alert.addAction(defaultAction)

        present(alert, animated: true)
    }
}
