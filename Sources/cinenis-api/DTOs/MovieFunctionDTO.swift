import Vapor 
import Foundation

struct MovieFunctionDTO : Content{
    let movieID : Int
    let genre : String
    let day : Int
    let month: Int
    let year: Int
}