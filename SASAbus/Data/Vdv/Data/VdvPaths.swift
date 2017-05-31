import Foundation
import SwiftyJSON

class VdvPaths {

    static var VARIANTS = [Int: Int]()
    static var PATHS = [Int: [[VdvBusStop]]]()

    static func loadPaths(jPaths: [JSON]) {
        var pathsMap = [Int: [[VdvBusStop]]]()

        // iterates through all the lines
        for i in 0...jPaths.count - 1 {
            var jVariants = jPaths[i]["variants"]
            let line = jPaths[i]["line_id"].intValue

            // HashMap with variants
            var variants = [[VdvBusStop]]()

            // iterates through all the variants
            for j in 0...jVariants.count - 1 {
                var path = [VdvBusStop]()

                var jPath = jVariants[j]["path"]

                for k in 0...jPath.count - 1 {
                    path.append(VdvBusStop(id: jPath[k].intValue))
                }

                variants.append(path)
            }

            pathsMap[line] = variants
        }

        PATHS = pathsMap

        Log.info("Loaded paths")
    }

    static func getPath(lineId: Int, variant: Int) -> [VdvBusStop] {
        VdvHandler.blockTillLoaded()

        var path = PATHS[lineId]
        if path == nil {
            Log.error("Requesting path failed: line=\(lineId), variant=\(variant)")
            return []
        }

        return path![variant - 1]
    }

    static func getPaths() -> [Int : [[VdvBusStop]]] {
        VdvHandler.blockTillLoaded()
        return PATHS
    }
}
