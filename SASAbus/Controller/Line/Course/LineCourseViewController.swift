import UIKit
import RxSwift
import RxCocoa

class LineCourseViewController: UIViewController {

    @IBOutlet weak var containerList: UIView!
    @IBOutlet weak var containerMap: UIView!

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var segmentedBackground: UIView!

    var hairLineImage: UIImageView!

    var vehicle: Int = 0
    var lineId: Int = 0

    var tempBusStop: Int = 0

    var listController: LineCourseListViewController!
    var mapController: LineCourseMapViewController!


    init(lineId: Int, vehicle: Int) {
        self.lineId = lineId
        self.vehicle = vehicle

        super.init(nibName: "LineCourseViewController", bundle: nil)

        title = "Line course"
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedBackground.backgroundColor = Color.materialTeal500

        for parent in navigationController!.navigationBar.subviews {
            for childView in parent.subviews {
                if childView is UIImageView && childView.bounds.height <= 1 {
                    hairLineImage = childView as! UIImageView
                    break
                }
            }
        }

        prepareListViewController()
        prepareMapViewController()

        parseData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let navController = self.navigationController {
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.barTintColor = Color.materialTeal500
            navController.navigationBar.isTranslucent = false
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        }

        hairLineImage.alpha = 0
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let navController = self.navigationController {
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.barTintColor = Color.materialOrange500
            navController.navigationBar.isTranslucent = false
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        }

        hairLineImage.alpha = 1
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        listController.view.frame = CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: containerList.frame.width, height: containerList.frame.height)
        )

        mapController.view.frame = CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: containerMap.frame.width, height: containerMap.frame.height)
        )
    }


    func prepareListViewController() {
        listController = LineCourseListViewController(lineId: lineId, vehicle: vehicle)
        let view = listController.view!

        view.translatesAutoresizingMaskIntoConstraints = true

        containerList.addSubview(view)
        self.addChildViewController(listController)

        self.view.setNeedsLayout()
        view.setNeedsLayout()
    }

    func prepareMapViewController() {
        mapController = LineCourseMapViewController(lineId: lineId)
        let view = mapController.view!

        view.translatesAutoresizingMaskIntoConstraints = true

        containerMap.addSubview(view)
        self.addChildViewController(mapController)

        self.view.setNeedsLayout()
        view.setNeedsLayout()
    }


    // MARK: - Data loading

    func parseData() {
        parseDataFromVehicle(vehicle: vehicle)
    }

    func parseDataFromVehicle(vehicle: Int) {
        tempBusStop = 0

        if !NetUtils.isOnline() {
            print("Device offline")
            return
        }

        _ = getPath(vehicle: vehicle)
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.background)
                .flatMap({ busStops -> Observable<[LineCourse]> in
                    if !busStops.isEmpty {
                        for i in 0..<busStops.count {
                            if busStops[i].id == self.tempBusStop {
                                let stop = busStops[i]

                                return self.parseFromPlanData(busStopIds: [stop.id], time: stop.time, line: self.lineId,
                                        busStops: busStops, allBlack: false)
                            }
                        }
                    }

                    return Observable.empty()
                })
                .map(passingLinesMap)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { items in
                    self.listController.onSuccess(items: items)
                    self.mapController.onSuccess(items: items)
                }, onError: { error in
                    self.listController.onError(error: error as NSError)
                    self.mapController.onError(error: error as NSError)
                })
    }


    // MARK: - Click handlers

    @IBAction func showComponent(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.containerList.alpha = 1
            self.containerMap.alpha = 0
        } else {
            self.containerList.alpha = 0
            self.containerMap.alpha = 1
        }
    }


    // MARK: - RxSwift

    func passingLinesMap(lineCourses: [LineCourse]) -> [LineCourse] {
        for lineCourse in lineCourses {
            let family = BusStopRealmHelper.getBusStopGroup(id: lineCourse.id)

            let passingLines: [Int] = Api2.getPassingLines(group: family)

            var lines = ""

            for line in passingLines {
                let lineName = Lines.lidToName(id: line)
                let coloredLineName = getColoredString(text: lineName, color: "#" + Lines.getColorForId(id: line))
                lines += "\(coloredLineName), "
            }

            if lines.characters.count > 2 {
                lines = String(lines.characters.dropLast())
                lines = String(lines.characters.dropLast())
            }

            lines = Lines.lines(name: lines)

            let data = lines.data(using: String.Encoding.utf8)!
            let attributes = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]

            do {
                let attributedString = try NSAttributedString(data: data, options: attributes, documentAttributes: nil)

                let fullRange = NSRange(location: 0, length: attributedString.length)
                let mutableAttributeText = NSMutableAttributedString(attributedString: attributedString)

                attributedString.enumerateAttribute(
                        NSFontAttributeName,
                        in: fullRange,
                        options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired) {

                    (attribute: Any?, range: NSRange, _: UnsafeMutablePointer<ObjCBool>) -> Void in

                    if attribute is UIFont {
                        let scaledFont = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
                        mutableAttributeText.addAttribute(NSFontAttributeName, value: scaledFont, range: range)
                    }
                }

                lineCourse.lineText = mutableAttributeText
            } catch {
                Log.error("Could not format string")
            }
        }

        return lineCourses
    }

    func getPath(vehicle: Int) -> Observable<[VdvBusStop]> {
        return RealtimeApi.vehicle(vehicle: vehicle)
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.background)
                .map { bus -> [VdvBusStop] in
                    guard let bus = bus else {
                        Log.error("Bus \(vehicle) is not driving")
                        return []
                    }

                    guard Api2.todayExists() else {
                        PlannedData.setUpdateAvailable(true)
                        print("Today does not exist")
                        return []
                    }

                    self.tempBusStop = bus.busStop

                    return Api2.getTrip(tripId: bus.trip).calcTimedPath()
                }
    }

    func parseFromPlanData(busStopIds: [Int], time: String, line: Int, busStops: [VdvBusStop]?, allBlack: Bool) -> Observable<[LineCourse]> {
        return Observable<[LineCourse]>.create { (observer) -> Disposable in
            guard Api2.todayExists() else {
                PlannedData.setUpdateAvailable(true)
                observer.onError(NSError(domain: "com.davale.sasabus", code: 0, userInfo: [:]))
                return Disposables.create()
            }

            var items = [LineCourse]()

            let userCalendar = NSCalendar.current
            let dateComponents = NSDateComponents()

            dateComponents.hour = 1
            dateComponents.minute = 0
            dateComponents.second = 0
            dateComponents.timeZone = TimeZone(identifier: "Europe/Rome")

            let calendar = userCalendar.date(from: dateComponents as DateComponents)!
            let path = busStops!

            var isActive: Bool = allBlack

            for stop in path {
                var dot = false

                for id in busStopIds where stop.id == id {
                    dot = true
                    isActive = true
                    break
                }

                let busStop = BusStop(value: BusStopRealmHelper.getBusStop(id: stop.id))

                items.append(LineCourse(
                        id: stop.id,
                        busStop: busStop,
                        time: stop.time,
                        active: isActive,
                        dot: dot
                ))
            }

            observer.onNext(items)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func getColoredString(text: String, color: String) -> String {
        return "<font color=\"\(color)\">\(text)</font>"
    }
}
