import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct BuilderMacro: MemberMacro {
    enum Error: Swift.Error, CustomStringConvertible {
        case missingArgument(String)
        case incorrectOptionsArgument
        case incorrectDefaultValuesArgument(String)
        case wrongDeclarationSyntax

        var description: String {
            switch self {
            case .missingArgument(let name):
                return "'\(name)' argument is missing"
            case .incorrectOptionsArgument:
                return "Options argument is incorrect"
            case .incorrectDefaultValuesArgument(let name):
                return "'\(name)' argument is missing"
            case .wrongDeclarationSyntax:
                return "Builder Macro supports only structs"
            }
        }
    }

    public static func expansion<
        Declaration: DeclGroupSyntax, Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct else {
            guard let diagnostic = Diagnostics.diagnose(declaration: declaration) else {
                throw BuilderMacro.Error.wrongDeclarationSyntax
            }

            context.diagnose(diagnostic)
            return []
        }

        let config = try BuilderMacroArgs.Config(from: node, isDebugOnly: false)

        let bodyGenerator = BuilderBodyGenerator(config: config)
        return try bodyGenerator.generateBody(from: declaration)
    }
}

public struct DebugBuilderMacro: MemberMacro {
    public static func expansion<
        Declaration: DeclGroupSyntax, Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct else {
            guard let diagnostic = Diagnostics.diagnose(declaration: declaration) else {
                throw BuilderMacro.Error.wrongDeclarationSyntax
            }

            context.diagnose(diagnostic)
            return []
        }

        let config = try BuilderMacroArgs.Config(from: node, isDebugOnly: true)

        let bodyGenerator = BuilderBodyGenerator(config: config)
        return try bodyGenerator.generateBody(from: declaration)
    }
}
