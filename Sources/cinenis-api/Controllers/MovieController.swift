import Fluent

import Vapor

struct MovieController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
    let movies = routes.grouped("movies")
    movies.get(use: getMovie)
    movies.get(":id", use: getMovieById)
    movies.post(use: createMovie)
    movies.put(":id", use: updateMovie)
    movies.delete(":id", use: deleteMovie)
}


    // CRUD
    /// Get all movies
    func getMovie(req: Request) async throws -> [MovieDTO] {
        let movies = try await Movie.query(on: req.db).all()
        return movies.map { movie in
            MovieDTO(
                id: movie.id ?? 0,
                title: movie.title,
                genre: movie.genre,
                year: movie.year,
                director: movie.director,
                actors: movie.actors,
                image: movie.image,
                description: movie.description,
                stars: movie.stars,
                duration: movie.duration,
                classification: movie.classification,
                schedule: movie.schedule
            )
        }
    }

    /// Get movie por ID
    func getMovieById(req: Request) async throws -> MovieDTO {
        guard let movieId = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest, reason: "Movie ID is required")
        }

        guard let movie = try await Movie.query(on: req.db).filter(\Movie.$id == movieId).first() else {
            throw Abort(.notFound, reason: "Movie not found")
        }

        return MovieDTO(
            id: movie.id ?? 0,
            title: movie.title,
            genre: movie.genre,
            year: movie.year,
            director: movie.director,
            actors: movie.actors,
            image: movie.image,
            description: movie.description,
            stars: movie.stars,
            duration: movie.duration,
            classification: movie.classification,
            schedule: movie.schedule
        )
    }

    /// Create new movie
    func createMovie(req: Request) async throws -> MovieDTO {
        let movieDTO = try req.content.decode(MovieDTO.self)

        let movie = Movie(
            title: movieDTO.title,
            genre: movieDTO.genre,
            year: movieDTO.year,
            director: movieDTO.director,
            actors: movieDTO.actors,
            image: movieDTO.image,
            description: movieDTO.description,
            stars: movieDTO.stars,
            duration: movieDTO.duration,
            classification: movieDTO.classification,
            schedule: movieDTO.schedule
        )

        try await movie.save(on: req.db)

        return MovieDTO(
            id: movie.id ?? 0,
            title: movie.title,
            genre: movie.genre,
            year: movie.year,
            director: movie.director,
            actors: movie.actors,
            image: movie.image,
            description: movie.description,
            stars: movie.stars,
            duration: movie.duration,
            classification: movie.classification,
            schedule: movie.schedule
        )
    }

    /// Update a movie by ID
    func updateMovie(req: Request) async throws -> MovieDTO {
        let movieId = try req.parameters.require("id", as: Int.self)
        let input = try req.content.decode(MovieDTO.self)

        guard let movie = try await Movie.find(movieId, on: req.db) else {
            throw Abort(.notFound, reason: "Movie not found")
        }

        movie.title = input.title
        movie.genre = input.genre
        movie.year = input.year
        movie.director = input.director
        movie.actors = input.actors
        movie.image = input.image
        movie.description = input.description
        movie.stars = input.stars
        movie.duration = input.duration
        movie.classification = input.classification
        movie.schedule = input.schedule

        try await movie.save(on: req.db)

        return MovieDTO(
            id: movie.id ?? 0,
            title: movie.title,
            genre: movie.genre,
            year: movie.year,
            director: movie.director,
            actors: movie.actors,
            image: movie.image,
            description: movie.description,
            stars: movie.stars,
            duration: movie.duration,
            classification: movie.classification,
            schedule: movie.schedule
        )
    }

    /// Delete a movie by ID
    func deleteMovie(req: Request) async throws -> HTTPStatus {
        let movieId = try req.parameters.require("id", as: Int.self)

        guard let movie = try await Movie.find(movieId, on: req.db) else {
            throw Abort(.notFound, reason: "Movie not found")
        }

        try await movie.delete(on: req.db)

        return .noContent
    }

}
