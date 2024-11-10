import SwiftSyntax

extension DeclGroupSyntax {
    /// Declaration name
    /// example: `struct User` will return `User`
    var name: String? {
        asProtocol(NamedDeclSyntax.self)?.name.text
    }

    var accessControlModifier: DeclModifierSyntax? {
        modifiers.first(where: {
            let tokenKind = $0.name.tokenKind
            return tokenKind == .keyword(.fileprivate)
            || tokenKind == .keyword(.private)
            || tokenKind == .keyword(.internal)
            || tokenKind == .keyword(.public)
        })
    }

    var storedVariables: [VariableDeclSyntax] {
        memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter(\.isStoredProperty)
    }

    var isStruct: Bool {
        self.as(StructDeclSyntax.self) != nil
    }
}
