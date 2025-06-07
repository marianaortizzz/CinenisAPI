import Fluent
import Vapor

final class Function: Model, Content, @unchecked Sendable {
    static let schema = "functions" 

    @ID(key: .id)
    var id: UUID?

    @Field(key: "function_date")
    var functionDate: Date

    @Field(key: "room")
    var room: Int

    @Field(key: "availability")
    var availability: String 

    @Parent(key: "id_movie")
    var movie: Movie

   
    // @Children(for: \.$function)
    // var sales: [Sale]

    nonisolated(unsafe) init() { }

    nonisolated(unsafe) init(id: UUID? = nil, functionDate: Date, room: Int, availability: String, movieID: Movie.IDValue) {
        self.id = id
        self.functionDate = functionDate
        self.room = room
        self.availability = availability
        self.$movie.id = movieID // Assigning the ID of the parent Movie
    }
}