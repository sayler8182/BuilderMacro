import SwiftSyntax

extension GenericArgumentListSyntax {
    var typeString: String {
        var result = ""
        result += "<"
        result += self
            .map { $0.argument.typeString }
            .joined(separator: ", ")
        result += ">"
        return result
    }
}
