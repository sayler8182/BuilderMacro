import SwiftSyntax

extension DictionaryElementListSyntax {
    enum Error: Swift.Error, CustomStringConvertible {
        case incorrectArgument

        var description: String {
            switch self {
            case .incorrectArgument:
                return "Argument is incorrect"
            }
        }
    }

    func asDictionary() throws -> [String: String] {
        let result = try self.map { (item: DictionaryElementSyntax) -> (key: String, value: String) in
            if let key = item.key.as(StringLiteralExprSyntax.self),
               let keyText = key.segments.first?.as(StringSegmentSyntax.self)?.content.text,
               let value = item.value.as(MemberAccessExprSyntax.self) {
                let valueText = value.declName.baseName.text
                return (key: keyText, value: valueText)
            }
            throw Error.incorrectArgument
        }
        return Dictionary(uniqueKeysWithValues: result)
    }
}
