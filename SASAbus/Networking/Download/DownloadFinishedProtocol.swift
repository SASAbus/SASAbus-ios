//
// Created by Alex Lardschneider on 27/03/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

protocol DownloadFinishedProtocol {
    func finished()

    func error()
}

class DownloadMapFinished: DownloadFinishedProtocol {

    weak var appDelegate: AppDelegate! = nil

    func finished() {
        self.appDelegate.startApplication()
    }

    func error() {
        self.finished()
    }
}

class DownloadDataFinished: DownloadFinishedProtocol {

    weak var appDelegate: AppDelegate! = nil

    func finished() {
        // Get privacy
        Alamofire.request(PrivacyApiRouter.getPrivacyHtml("ios")).responseString { response in
            if response.result.isSuccess {
                let privacyHtml = response.result.value!
                UserDefaultHelper.instance.setPrivacyHtml(privacyHtml)
            }
        }

        if UserDefaultHelper.instance.getMapDownloadStatus() == false &&
                   UserDefaultHelper.instance.shouldAskForMapDownload() {

            let delegate = DownloadMapFinished()
            delegate.appDelegate = self.appDelegate
            let downloadViewController = DownloadViewController(nibName: "DownloadViewController", bundle: nil,
                    downloader: MapTilesDownloader(), downloadFinishedDelegate: delegate,
                    canBeCanceled: true, showFinishedDialog: true, askForDownload: true)

            downloadViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.appDelegate.window!.rootViewController = downloadViewController
        } else {
            self.appDelegate.startApplication()
        }
    }

    func error() {
        exit(0)
    }
}
