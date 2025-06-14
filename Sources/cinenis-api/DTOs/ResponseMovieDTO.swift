import Vapor
import Foundation

struct ResponseMovieDTO: Content {
    var id: Int?
    var title: String
    var genre: String
    var year: Int
    var director: String
    var actors: String
    var image: String
    var description: String
    var stars: Int
    var duration: Int
    var classification: String
    var premiere: Bool
    var schedule: String

    init(movie: Movie) throws {
        self.id = movie.id
        self.title = movie.title
        self.genre = movie.genre
        self.year = movie.year
        self.director = movie.director
        self.actors = movie.actors
        self.image = movie.image
        self.description = movie.description
        self.stars = movie.stars
        self.duration = movie.duration
        self.classification = movie.classification
        self.premiere = movie.premiere
        self.schedule = movie.schedule
    }
}