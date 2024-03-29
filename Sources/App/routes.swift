import Vapor
import Fluent

public func routes(_ router: Router) throws {
    
    router.get { req in
        return "It works!"
    }
    
    // CREATE
    
    router.post("api", "acronyms") { req -> Future<Acronym> in
        return try req.content.decode(Acronym.self)
            .flatMap(to: Acronym.self, { acronym in
                return acronym.save(on: req)
            })
    }
    
    // READ
    
    router.get("api", "acronyms") { req -> Future<[Acronym]> in
        return Acronym.query(on: req).all()
    }
    
    router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try req.parameters.next(Acronym.self)
    }
    
    router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        //return Acronym.query(on: req).filter(\.short == searchTerm).all()
        return Acronym.query(on: req).group(.or, closure: { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }).all()
    }
    
    router.get("api", "acronyms", "first") { req -> Future<Acronym> in
        return Acronym.query(on: req).first().map(to: Acronym.self, { acronym in
            guard let acronym = acronym else { throw Abort(.notFound)}
            return acronym
        })
    }
    
    router.get("api", "acronyms", "sorted") {req -> Future<[Acronym]> in
        return Acronym.query(on: req).sort(\.short, .ascending).all()
    }
    
    // UPDATE
    
    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self), { acronym, updatedAcronym in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            return acronym.save(on: req)
        })
    }
    
    // DELETE
    
    router.delete("api", "acronyms", Acronym.parameter) { req -> Future<HTTPStatus> in
        return try req.parameters.next(Acronym.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    // Example of configuring a controller
    //    let todoController = TodoController()
    //    router.get("todos", use: todoController.index)
    //    router.post("todos", use: todoController.create)
    //    router.delete("todos", Todo.parameter, use: todoController.delete)
}
