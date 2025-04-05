import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum BuilderMacroArgs {
    struct Config {
        struct Options: OptionSet, Hashable, Sendable {
            static let build = Options(rawValue: 1 << 1)
            static let staticBuild = Options(rawValue: 1 << 2)
            static let tryBuild = Options(rawValue: 1 << 3)
            static let staticTryBuild = Options(rawValue: 1 << 4)

            static var standard: Options { [.build, .staticBuild, .tryBuild, .staticTryBuild] }

            let rawValue: Int

            init(rawValue: Int) {
                self.rawValue = rawValue
            }

            init?(value: String) {
                switch value {
                case "build": self = .build
                case "staticBuild": self = .staticBuild
                case "tryBuild": self = .tryBuild
                case "staticTryBuild": self = .staticTryBuild
                default: return nil
                }
            }
        }

        let isDebugOnly: Bool
        let options: Options

        init(isDebugOnly: Bool,
             options: Options) {
            self.isDebugOnly = isDebugOnly
            self.options = options
        }

        init(from node: AttributeSyntax,
             isDebugOnly: Bool) throws {
            guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
                  let config = arguments.first(where: { $0.label?.text == "config" }) else {
                self.init(
                    isDebugOnly: isDebugOnly,
                    options: BuilderMacroArgs.Config.Options.standard)
                return
            }

            let configArguments = config.expression.as(FunctionCallExprSyntax.self)?.arguments

            // options
            let configOptions = try configArguments?.first(where: { $0.label?.text == "options" })?.expression
                .as(ArrayExprSyntax.self)?.elements
                .map { (item: ArrayElementSyntax) -> BuilderMacroArgs.Config.Options in
                    if let value = item.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text,
                       let options = BuilderMacroArgs.Config.Options(value: value) {
                        return options
                    }
                    throw BuilderMacro.Error.incorrectOptionsArgument
                }
                .reduce(BuilderMacroArgs.Config.Options(), { $0.union($1) })

            self.init(
                isDebugOnly: isDebugOnly,
                options: configOptions ?? BuilderMacroArgs.Config.Options.standard
            )
        }
    }
}

enum BuilderDefaultValue {
    case initializer
    case value(String)
    case builder(String)

    var description: String {
        switch self {
        case .initializer:
            return ".init()"
        case .value(let value):
            return "\(value)"
        case .builder(let type):
            return "\(type).Builder.build()"
        }
    }
}
