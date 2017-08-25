import UIKit
import RxSwift
import RxCocoa

class LineDetailsBusesViewController: UITableViewController {

    var lineId: Int = 0
    var vehicle: Int = 0

    var items = [LineDetail]()

    weak var activityIndicatorView: UIActivityIndicatorView!

    var timeFormatter: () -> (DateFormatter) = {
        var formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }


    init(lineId: Int, vehicle: Int) {
        self.lineId = lineId
        self.vehicle = vehicle

        super.init(nibName: "LineDetailsBusesViewController", bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        if lineId == 0 {
            fatalError("lineId == 0")
        }

        tableView.register(UINib(nibName: "LineDetailsHeader", bundle: nil), forCellReuseIdentifier: "line_details_header")
        tableView.register(UINib(nibName: "LineDetailsBuses", bundle: nil), forCellReuseIdentifier: "line_details_buses")

        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        tableView.backgroundView = activityIndicatorView
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none

        self.activityIndicatorView = activityIndicatorView
        self.activityIndicatorView.hidesWhenStopped = true

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 56.0
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(parseDataSelector), for: UIControlEvents.valueChanged)

        activityIndicatorView.startAnimating()
        parseData(line: lineId, vehicle: vehicle)
    }


    func parseDataSelector() {
        parseData(line: lineId, vehicle: vehicle)
    }

    func parseData(line: Int, vehicle: Int) {
        _ = Observable.zip(getLine(line: line), getTravelling(line: line, vehicle: vehicle)) { (a, b) -> [LineDetail] in
                    var list = [LineDetail]()
                    list.append(a)
                    list.append(contentsOf: b)

                    return list
                }
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { items in
                    self.items.removeAll()
                    self.items.append(contentsOf: items)
                    self.tableView.reloadData()

                    self.activityIndicatorView.stopAnimating()
                    self.refreshControl?.endRefreshing()
                }, onError: { error in
                    print("onError: \(error)")
                })
    }

    func getDateString(date: Int) -> String {
        switch date {
        case 1:
            return "Sunday"/*getString(R.string.sunday_long);*/
        case 5:
            return "Monday - Friday" /*getString(R.string.monday_long) + " - " + getString(R.string.friday_long);*/
        case 6:
            return "Monday - Saturday" /*getString(R.string.monday_long) + " - " + getString(R.string.saturday_long);*/
        case 7:
            return "Monday - Sunday" /*getString(R.string.monday_long) + " - " + getString(R.string.sunday_long);*/
        default:
            print("Unknown day: \(date)")
            return "Unknown"
        }
    }


    // MARK: - RxSwift

    func getLine(line: Int) -> Observable<LineDetail> {
        return LinesApi.filterLines(lines: String(line))
                .map { lines -> LineDetail in
                    let line = lines[0]

                    let data: String = line.origin + "#" +
                            line.destination + "#" +
                            line.city + "#" +
                            self.getDateString(date: line.days) + "#" +
                            line.info

                    return LineDetail(currentStation: nil, delay: 0, lastStation: nil, lastTime: nil,
                            additionalData: data, vehicle: 0, color: false)
                }
    }

    func getTravelling(line: Int, vehicle: Int) -> Observable<[LineDetail]> {
        if !NetUtils.isOnline() {
            print("No internet connection")
            return Observable.empty()
        }

        return RealtimeApi.line(line: line)
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.background)
                .map { buses in
                    var items = [LineDetail]()

                    for bus in buses {
                        let lastStationId = bus.destination
                        let lastStationName = BusStopRealmHelper.getName(id: lastStationId)

                        let path: [VdvBusStop] = Api.getTrip(tripId: bus.trip).calcTimedPath()

                        if !path.isEmpty {
                            let lastTime = path.last?.time
                            let stationName = BusStopRealmHelper.getName(id: bus.busStop)

                            items.append(LineDetail(
                                    currentStation: stationName,
                                    delay: bus.delay,
                                    lastStation: lastStationName,
                                    lastTime: lastTime,
                                    additionalData: nil,
                                    vehicle: bus.vehicle,
                                    color: vehicle == bus.vehicle
                            ))
                        } else {
                            // TODO show error somehow
                            /*items.add(new LineDetail(null, 0, null, null, "error", 0, false));
                            mErrorGeneral = true;*/
                        }
                    }

                    return items
                }
    }
}

extension LineDetailsBusesViewController {

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "line_details_header", for: indexPath) as! LineDetailsHeaderCell

            let split = (item.additionalData?.characters.split {
                $0 == "#"
            }.map(String.init))!

            cell.originText.text = split[0]
            cell.destinationText.text = split[1]
            cell.cityText.text = split[2]
            cell.timesText.text = split[3]
            cell.infoText.text = split[4]

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "line_details_buses", for: indexPath)
            as! LineDetailsBusesCell

            let date = timeFormatter().string(from: Date())

            let nowAt = String.localizedStringWithFormat(NSLocalizedString("now_at", value: "Now at %@", comment: ""),
                    item.currentStation!)
            let headingTo = String.localizedStringWithFormat("Heading to %@", item.lastStation!)

            cell.currentName.text = nowAt
            cell.currentTime.text = date

            cell.destinationName.text = headingTo
            cell.destinationTime.text = item.lastTime

            cell.delay.text = String(format: "%d'", item.delay)
            cell.delay.textColor = Color.delay(item.delay)

            if item.color {
                cell.backgroundColor = Color.activeLineBackground
            } else {
                cell.backgroundColor = UIColor.white
            }

            return cell
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
