import Foundation
import MapKit

// TODO: Implement file cache?
class BusTileOverlay: MKTileOverlay {

    let cache = NSCache<NSString, NSData>()
    let operationQueue = OperationQueue()

    let showAllPaths: Bool
    var parent: MapViewController!

    init(parent: MapViewController) {
        self.showAllPaths = MapUtils.allMapOverlaysEnabled()
        if showAllPaths {
            Log.info("Showing all map tile paths")
        }

        super.init(urlTemplate: "")

        self.parent = parent
        self.tileSize = CGSize(width: 512, height: 512)
    }

    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let urlFormatted: String

        if showAllPaths {
            let url = Endpoint.dataApiUrl + Endpoint.MAP_TILES_ALL
            urlFormatted = String(format: url, path.x, path.y, path.z)

        } else {
            let url = Endpoint.dataApiUrl + Endpoint.MAP_TILES
            urlFormatted = String(format: url,
                    path.x, path.y, path.z,
                    parent.selectedBus?.lineId ?? 0, parent.selectedBus?.variant ?? 0
            )
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
}