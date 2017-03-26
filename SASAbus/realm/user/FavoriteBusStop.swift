import RealmSwift

/**
 * Holds the favorite bus stops by their group. As the bus stops get displayed grouped by their
 * group, we need to save the group of the bus stop instead of the individual id.
 *
 * @author Alex Lardschneider
 */
class FavoriteBusStop: Object {
    
    dynamic var group: Int = 0
}
