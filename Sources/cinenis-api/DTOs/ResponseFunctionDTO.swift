import Vapor
import Foundation

struct ResponseFunctionDTO : Content{
    let id: Int?
    let functionDate: Date
    let room: Int
    let availability: String
    let movie: Movie 

    init(function: Function) throws {
        self.id = function.id
        self.functionDate = function.functionDate
        self.room = function.room
        self.availability = function.availability
        self.movie = function.movie
    }
}