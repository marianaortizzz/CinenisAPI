import Vapor
import Foundation

struct CreateFunctionDTO : Content{
    var functionDate : Date
    var room : Int
    var availability : String
    var id_movie : Int
}