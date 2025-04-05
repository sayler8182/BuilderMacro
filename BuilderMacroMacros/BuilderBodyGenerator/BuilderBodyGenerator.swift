import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct BuilderBodyGenerator {
    fileprivate enum Error: Swift.Error {
        case missingDeclarationName
    }

    private let config: BuilderMacroArgs.Config

    init(config: BuilderMacroArgs.Config) {
        self.config = config
    }

    func generateBody(from declaration: DeclGroupSyntax) throws -> [DeclSyntax] {
        guard let memberName = declaration.name else {
            throw Error.missingDeclarationName
        }

        let accessControlModifier = declaration.accessControlModifier
            .flatMap { "\($0.name.text) " } ?? ""
        let variables = declaration.storedVariables

        return generateBody(
            accessControlModifier: accessControlModifier,
            memberName: memberName,
            variables: variables
        )
    }
}

// MARK: Body Generation
extension BuilderBodyGenerator {
    fileprivate func generateBody(
        accessControlModifier: String,
        memberName: String,
        variables: [VariableDeclSyntax]
    ) -> [DeclSyntax] {
        let syntax = [
            "\(startDebugDecl())",
            "\(accessControlModifier)\(startBuilderDecl())",
            "\(errorDecl())",
            "\(variablesDecl(accessControlModifier: accessControlModifier, variables: variables))",
            "\(accessControlModifier)\(initDecl(variables: variables))",
            "\(accessControlModifier)\(convenienceInitDecl(memberName: memberName))",
            "\(accessControlModifier)\(convenienceInitDecl(variables: variables))",
            "\(accessControlModifier)\(staticBuildDefaultDecl(variables: variables, memberName: memberName))",
            "\(accessControlModifier)\(staticTryBuildDefaultDecl(variables: variables, memberName: memberName))",
            "\(accessControlModifier)\(fillDecl(variables: variables, memberName: memberName))",
            "\(accessControlModifier)\(buildDefaultDecl(variables: variables, memberName: memberName))",
            "\(accessControlModifier)\(buildTryDefaultDecl(variables: variables, memberName: memberName))",
            "\(settersDecl(accessControlModifier: accessControlModifier, variables: variables))",
            "\(stopBuilderDecl())",
            "\(stopDebugDecl())"
        ]
        let result = syntax
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
        return ["\(raw: result)"]
    }

    private func startDebugDecl() -> String {
        guard config.isDebugOnly else { return "" }
        return """
        #if DEBUG
        """
    }

    private func startBuilderDecl() -> String {
        """
        final class Builder {
        """
    }

    private func errorDecl() -> String {
        guard config.options.contains(.tryBuild) || config.options.contains(.staticTryBuild) else { return "" }
        return """
        private enum Error: Swift.Error {
            case missingValue(property: String)
        }
        """
    }

    private func variablesDecl(accessControlModifier: String,
                               variables: [VariableDeclSyntax]) -> String {
        variables
            .map { "\(accessControlModifier)\($0.optionalVarDefinition)" }
            .joined(separator: "\n")
    }

    private func initDecl(variables: [VariableDeclSyntax]) -> String {
        """
        required init() {
        }
        """
    }

    private func convenienceInitDecl(memberName: String) -> String {
        """
        convenience init(_ item: \(memberName)?) {
            self.init()
            fill(with: item)
        }
        """
    }

    private func convenienceInitDecl(variables: [VariableDeclSyntax]) -> String {
        let definition = { (variable: VariableDeclSyntax) in
            if variable.isOptional {
                return "\(variable.name): \(variable.typeString) = nil"
            } else {
                return "\(variable.name): \(variable.typeString)"
            }
        }
        let assignment = { (variable: VariableDeclSyntax) in "self.\(variable.name) = \(variable.name)" }
        return """
        convenience init(
        \(variables.map(definition).joined(separator: ",\n"))
        ) {
            self.init()
            \(variables.map(assignment).joined(separator: "\n"))
        }
        """
    }

    private func staticBuildDefaultDecl(variables: [VariableDeclSyntax],
                                        memberName: String) -> String {
        guard config.options.contains(.staticBuild) else { return "" }
        return """
        static func build(
        \(variables.map(defaultDefinition).joined(separator: ",\n"))
        ) -> \(memberName) {
            let item = Self.init()
            \(variables.map(defaultAssignment).joined(separator: "\n"))
            return item.build()
        }
        """
    }

    private func staticTryBuildDefaultDecl(variables: [VariableDeclSyntax],
                                           memberName: String) -> String {
        guard config.options.contains(.staticTryBuild) else { return "" }
        return """
        static func tryBuild(
        \(variables.map(defaultDefinition).joined(separator: ",\n"))
        ) throws -> \(memberName) {
            let item = Self.init()
            \(variables.map(defaultAssignment).joined(separator: "\n"))
            return try item.tryBuild()
        }
        """
    }

    private func fillDecl(variables: [VariableDeclSyntax],
                          memberName: String) -> String {
        let assignment = { (variable: VariableDeclSyntax) in "\(variable.name) = item?.\(variable.name)" }
        let fillAssignments = variables
            .map { assignment($0) }
            .joined(separator: "\n")
        return """
        func fill(with item: \(memberName)?) {
            \(fillAssignments)
        }
        """
    }

    private func buildDefaultDecl(variables: [VariableDeclSyntax],
                                  memberName: String) -> String {
        guard config.options.contains(.build) else { return "" }
        let guardVariables = variables
            .filter { !$0.isOptional }
            .compactMap { $0.isUUID ? nil : "let \($0.name)" }
            .joined(separator: ", ")
        let buildGuards = guardVariables.isEmpty
            ? ""
           : "guard " + guardVariables + " else { fatalError() }"
        let initAssignments = variables
            .map(\.initAssignment)
            .joined(separator: ",\n")
        return """
        func build() -> \(memberName) {
            \(buildGuards)
            return \(memberName)(
            \(initAssignments)
            )
        }
        """
    }

    private func buildTryDefaultDecl(variables: [VariableDeclSyntax],
                                     memberName: String) -> String {
        guard config.options.contains(.tryBuild) else { return "" }
        let throwingBuildGuards = variables
            .filter { !$0.isOptional }
            .compactMap(\.throwingGuardCheck)
            .joined(separator: "\n")
        let initAssignments = variables
            .map(\.initAssignment)
            .joined(separator: ",\n")
        return """
        func tryBuild() throws -> \(memberName) {
            \(throwingBuildGuards)
            return \(memberName)(
            \(initAssignments)
            )
        }
        """
    }

    private func defaultDefinition(variable: VariableDeclSyntax) -> String {
        let name = variable.name
        let typeString = variable.typeString
        var result = "\(name): \(typeString)"
        if let defaultValue = variable.builderDefaultValue {
            result += " = \(defaultValue.description)"
        } else if variable.isOptional {
            result += " = nil"
        } else if variable.isUUID {
            result += " = UUID()"
        } else if variable.isString {
            result += " = \"_\(variable.name)_\""
        } else if variable.isNumber {
            result += " = 0"
        } else if variable.isBool {
            result += " = false"
        } else if variable.isArray {
            result += " = []"
        } else if variable.isDictionary {
            result += " = [:]"
        } else if variable.isSet {
            result += " = []"
        } else if variable.isDate {
            result += " = Date()"
        } 

        return result
    }

    private func defaultAssignment(variable: VariableDeclSyntax) -> String {
        "item.\(variable.name) = \(variable.name)"
    }

    private func settersDecl(accessControlModifier: String,
                             variables: [VariableDeclSyntax]) -> String {
        variables.map {
        """
        \(accessControlModifier)func set(\($0.name): \($0.typeString)) -> Self {
            self.\($0.name) = \($0.name)
            return self
        }
        """
        }
        .joined(separator: "\n")
    }

    private func stopBuilderDecl() -> String {
        "}"
    }

    private func stopDebugDecl() -> String {
        guard config.isDebugOnly else { return "" }
        return """
        #endif
        """
    }
}
