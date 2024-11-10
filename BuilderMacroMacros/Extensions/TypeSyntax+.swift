import SwiftSyntax

extension TypeSyntax {
    /// variable type
    /// example `var name: String` will return `String`
    var typeString: String {
        if let type = self.as(IdentifierTypeSyntax.self) {
            var result = type.name.text
            if let arguments = type.genericArgumentClause?.arguments, !arguments.isEmpty {
                result += arguments.typeString
            }
            return result
        } else if let type = self.as(OptionalTypeSyntax.self)?.wrappedType {
            return "\(type.typeString)?"
        } else if let type = self.as(ArrayTypeSyntax.self)?.element {
            return "[\(type.typeString)]"
        } else if let key = self.as(DictionaryTypeSyntax.self)?.key,
                  let value = self.as(DictionaryTypeSyntax.self)?.value {
            return "[\(key.typeString):\(value.typeString)]"
        }
        return self.description
    }
}
