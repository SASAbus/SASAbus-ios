import Foundation
import MapKit

class BusTileOverlay: MKTileOverlay {

    let cache = NSCache<NSString, NSData>()
    let operationQueue = OperationQueue()

    var parent: MapViewController!

    init(parent: MapViewController) {
        super.init(urlTemplate: "")

        self.parent = parent

        self.tileSize = CGSize(width: 512, height: 512)
    }

    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let urlFormatted: String

        if parent.allMapOverlaysEnabled {
            let url = Endpoint.dataApiUrl + Endpoint.MAP_TILES_ALL
            urlFormatted = String(format: url, path.x, path.y, path.z)

        } else {
            let url = Endpoint.dataApiUrl + Endpoint.MAP_TILES
            urlFormatted = String(format: url, path.x, path.y, path.z,
                    parent.selectedBus!.lineId, parent.selectedBus!.variant)
        }

        return URL(string: urlFormatted)!
    }

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Swift.Void) {
        let url = self.url(forTilePath: path)

        if let cachedData = cache.object(forKey: url.absoluteString as NSString) as Data? {
            result(cachedData, nil)
        } else {
            let session = URLSession.shared

            let request = NSURLRequest(url: url)

            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, _, error -> Void in
                if let data = data {
                    self.cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
                }

                result(data, error)
            })

            task.resume()
        }
    }

    func checkTileExists(zoom: Int) -> Bool {
        let minZoom = 10
        let maxZoom = 16

        if zoom < minZoom || zoom > maxZoom {
            return false
        }

        return parent.allMapOverlaysEnabled || parent.selectedBus != nil
    }
}