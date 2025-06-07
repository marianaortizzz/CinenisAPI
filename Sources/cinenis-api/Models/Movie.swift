import Fluent
import Vapor

final class Movie: Model, Content, @unchecked Sendable {
    static let schema = "movies" // Fluent will use "movies" as the table name

    @ID(custom: .id)
    var id: Int?

    @Field(key: "title")
    var title: String

    @Field(key: "genre")
    var genre: String

    @Field(key: "year")
    var year: Int 
    @Field(key: "image")
    var image: String

    @Field(key: "description")
    var description: String 
    
    @Field(key: "stars")
    var stars: Int

    @Field(key: "duration")
    var duration: Int

    @Field(key: "classification")
    var classification: String 

    @Field(key: "schedule")
    var schedule: String

    @Children(for: \.$movie)
    var functions: [Function]

    nonisolated(unsafe) init() { } 

    nonisolated(unsafe) init(id: Int? = nil, title: String, genre: String, year: Int, image: String, description: String, stars: Int, duration: Int, classification: String, schedule: String) {
        self.id = id
        self.title = title
        self.genre = genre
        self.year = year
        self.image = image
        self.description = description
        self.stars = stars
        self.duration = duration
        self.classification = classification
        self.schedule = schedule
    }
}