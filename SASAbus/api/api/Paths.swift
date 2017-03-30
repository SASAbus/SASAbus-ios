import Foundation
import SwiftyJSON

class Paths {

    static var VARIANTS = [Int: Int]()
    static var PATHS = [Int: [Int: [ApiBusStop]]]()

    static func loadPaths(baseDir: URL) {
        let jPaths: JSON = IOUtils.readFileAsJson(path: baseDir.appendingPathComponent("LID_VERLAUF.json"))!

        var variantsMap = [Int: Int]()
        var pathsMap = [Int: [Int: [ApiBusStop]]]()

        // iterates through all the lines
        for item in jPaths.arrayValue {

            let jVariants = item["varlist"].arrayValue
            let line = item["LI_NR"].intValue

            var variants = [Int: [ApiBusStop]]()

            var j = 0
            // iterates through all the variants
            for variants1 in jVariants {
                var path = [ApiBusStop]()

                let jPath = variants1["routelist"].arrayValue

                for singlePath in jPath {
                    path.append(ApiBusStop(id: singlePath.intValue))
                }

                variants[j + 1] = path
                j += 1
            }

            variantsMap[line] = variants.count
            pathsMap[line] = variants
        }

        VARIANTS = variantsMap
        PATHS = pathsMap

        Log.info("Loaded paths")
    }

    static func getPaths() -> [Int: [Int: [ApiBusStop]]] {
        return PATHS
    }

    static func getPath(line: Int, variant: Int) -> [ApiBusStop] {
        let paths = PATHS[line]
        let path = paths?[variant]
        return path!
    }
}
