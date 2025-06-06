import Vapor
import Foundation

struct MovieDTO: Content {
    var id: Int
    var title: String
    var genre: String
    var year: Int
    var image: String
    var description: String
    var stars: Int
    var duration: Int
    var classification: String
    var schedule: String
}