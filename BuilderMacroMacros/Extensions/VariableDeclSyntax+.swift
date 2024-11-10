import Foundation
import SwiftSyntax

extension VariableDeclSyntax {
    /// variable name
    /// example `var age: Int?` will return `age`
    var name: String {
        bindings.first!.pattern.as(IdentifierPatternSyntax.self)!.identifier.text
    }
    
    /// variable type
    /// example `var name: String` will return `String`
    var typeString: String {
        bindings.first!.typeAnnotation!.type.typeString
    }

    /// SOURCE: https://github.com/DougGregor/swift-macro-examples
    /// Determine whether this variable has the syntax of a stored property.
    ///
    /// This syntactic check cannot account for semantic adjustments due to,
    /// e.g., accessor macros or property wrappers.
    var isStoredProperty: Bool {
        if bindings.count != 1 {
            return false
        }

        let binding = bindings.first!
        switch binding.accessorBlock?.accessors {
        case .none:
            return true
        case .accessors(let node):
            for accessor in node {
                switch accessor.accessorSpecifier.tokenKind {
                case .keyword(.willSet), .keyword(.didSet):
                    // Observers can occur on a stored property.
                    break

                default:
                    // Other accessors make it a computed property.
                    return false
                }
            }

            return true

        case .getter:
            return false
        }
    }

    var initAssignment: String {
        if isUUID {
            return "\(name): \(name) ?? UUID()"
        }
        return "\(name): \(name)"
    }

    var optionalVarDefinition: String {
        let optionalType = isOptional ? typeString : "\(typeString)?"
        return "var \(name): \(optionalType)"
    }

    var throwingGuardCheck: String? {
        if isUUID {
            return nil
        }
        return "guard let \(name) else { throw Error.missingValue(property: \"\(name)\") }"
    }

    var isArray: Bool {
        (typeString.hasPrefix("[[") && typeString.hasSuffix("]]"))
        || (typeString.hasPrefix("[") && typeString.hasSuffix("]") && !typeString.contains(":"))
    }
    var isDictionary: Bool {
        typeString.hasPrefix("[") && typeString.hasSuffix("]") && !isArray
    }
    var isSet: Bool {
        typeString.hasPrefix("Set<") && typeString.hasSuffix(">")
    }
    var isDate: Bool { typeString == "Date" }
    var isBool: Bool { typeString == "Bool" }
    var isNumber: Bool { ["Int", "Float", "CGFloat", "Double"].contains(typeString) }
    var isString: Bool { typeString == "String" }
    var isUUID: Bool { typeString == "UUID" }
    var isOptional: Bool { typeString.last == "?" }
    var isDefault: Bool { isNumber || isString || isUUID }

    var builderDefaultValue: BuilderDefaultValue? {
        do {
            let text = description
            let pattern = #"/// @BuilderDefaultValue\((.*)\)"#
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(text.startIndex..., in: text)
            let results = regex.matches(in: text, range: range)
            let result = results
                .compactMap { result -> String? in
                    guard let range = Range(result.range(at: 1), in: text) else { return nil }
                    return String(text[range])
                }
                .first
            if let resultValue = result {
                switch resultValue {
                case ".init":
                    return BuilderDefaultValue.initializer
                case ".builder":
                    return BuilderDefaultValue.builder(typeString)
                default:
                    let pattern = #".value\((.*)\)"#
                    let regex = try NSRegularExpression(pattern: pattern, options: [])
                    let range = NSRange(resultValue.startIndex..., in: resultValue)
                    let results = regex.matches(in: resultValue, range: range)
                    let result = results
                        .compactMap { result -> String? in
                            guard let range = Range(result.range(at: 1), in: resultValue) else { return nil }
                            return String(resultValue[range])
                        }
                        .first
                    if let resultValue = result {
                        return BuilderDefaultValue.value(resultValue)
                    }
                }
            }
        } catch { /* use default name */ }
        return nil
    }
}
