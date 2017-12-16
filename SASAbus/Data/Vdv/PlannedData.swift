import Foundation

import RxSwift
import RxCocoa

class PlannedData {

    static let PREF_UPDATE_AVAILABLE = "pref_data_update_available"
    static let PREF_DATA_DATE = "pref_data_date"

    public static var dataAvailable: Bool?

    
    public static func isAvailable() -> Bool {
        if dataAvailable == nil {
            let url = IOUtils.dataDir()
            
            if !FileManager.default.fileExists(atPath: url.path) {
                Log.error("Planned data folder does not exist")
                
                dataAvailable = false
                return false
            }

            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: url.path)

                if files.isEmpty {
                    Log.error("Planned data folder is empty")
                    dataAvailable = false
                    return false
                }

                let hasMainFile = files.contains {
                    $0 == "planned_data.json"
                }

                if !hasMainFile {
                    Log.error("Main data file 'planned_data.json' is missing")
                    dataAvailable = false
                    return false
                }
                
                Log.info("Downloaded planned data on '\(PlannedData.getUpdateDate())'")

                for file in files {
                    Log.info("Found data file '\(file)'")

                    if file.hasPrefix("trips_") {
                        dataAvailable = true
                        return true
                    }
                }

                Log.error("Planned data (JSON file) is missing")
                dataAvailable = false
            } catch let error {
                ErrorHelper.log(error, message: "Cannot check if planned data exists: \(error)")
                dataAvailable = false
            }
        }

        return dataAvailable!
    }

    public static func checkIfValid(_ closure: (() -> Void)? = nil) {
        guard isAvailable() else {
            Log.info("Data does not exist, skipping update check")
            return
        }
        
        guard Settings.isIntroFinished() else {
            Log.info("Into not yet finished, skipping update check")
            return
        }
        
        let unixDate = PlannedData.getUpdateDate()
        
        _ = ValidityApi.checkData(unix: unixDate)
            .subscribeOn(MainScheduler.background)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { json in
                guard let isValid = json["valid"].bool else {
                    Log.error("Could not find json object 'valid' in API response")
                    return
                }
                
                if !isValid {
                    PlannedData.setUpdateAvailable(true)
                    
                    if let closure = closure {
                        Log.error("Data is not valid, redownloading now")
                        closure()
                    } else {
                        Log.error("Data is not valid, redownloading on next app start")
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

    
    static func setUpdateDate() {
        let time = Date().seconds()
        UserDefaults.standard.set(time, forKey: PREF_DATA_DATE)
    }

    static func getUpdateDate() -> Int {
        return UserDefaults.standard.integer(forKey: PREF_DATA_DATE)
    }
}
