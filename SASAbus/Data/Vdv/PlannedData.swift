import Foundation

import RxSwift
import RxCocoa

class PlannedData {

    static let PREF_UPDATE_AVAILABLE = "pref_data_update_available"
    static let PREF_DATA_DATE = "pref_data_date"

    public static var dataExists: Bool?

    public static func planDataExists() -> Bool {
        if dataExists == nil {
            let url = IOUtils.dataDir()

            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: url.path)

                if files.isEmpty {
                    Log.error("Planned data folder does not exist or is empty")
                    dataExists = false
                    return false
                }

                let hasMainFile = files.contains {
                    $0 == "planned_data.json"
                }

                if !hasMainFile {
                    Log.error("Main data file 'planned_data.json' is missing")
                    dataExists = false
                    return false
                }
                
                Log.info("Downloaded planned data on '\(PlannedData.getDataDate())'")

                for file in files {
                    Log.info("Found data file '\(file)'")

                    if file.hasPrefix("trips_") {
                        dataExists = true
                        return true
                    }
                }

                Log.error("Planned data (JSON file) is missing")
                dataExists = false
            } catch let error {
                Utils.logError(error, message: "Cannot list contents of data directory, re-downloading: \(error)")
                dataExists = false
            }
        }

        return dataExists!
    }
    
    public static func checkIfDataIsValid(_ closure: (() -> Void)? = nil) {
        let unixDate = PlannedData.getDataDate()
        
        _ = ValidityApi.checkData(unix: unixDate)
            .subscribeOn(MainScheduler.background)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { json in
                guard let isValid = json["valid"].bool else {
                    Log.error("Could not find 'valid' json object in API response")
                    return
                }
                
                if !isValid {
                    Log.error("Data is not valid, redownloading on next app start")
                    PlannedData.setUpdateAvailable(true)
                    
                    if let closure = closure {
                        closure()
                    }
                } else {
                    Log.info("Planned data is still valid")
                }
            }, onError: { error in
                Log.error("Could not check data validity")
            })
    }
}

extension PlannedData {

    static func setUpdateAvailable(_ newValue: Bool) {
        Log.info("Updating plan data update available flag to '\(newValue)'")
        UserDefaults.standard.set(newValue, forKey: PREF_UPDATE_AVAILABLE)
    }

    static func isUpdateAvailable() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_UPDATE_AVAILABLE)
    }

    static func setDataDate() {
        let time = Date().seconds()

        UserDefaults.standard.set(time, forKey: PREF_DATA_DATE)
    }

    static func getDataDate() -> Int {
        return UserDefaults.standard.integer(forKey: PREF_DATA_DATE) - 50000000
    }
}
