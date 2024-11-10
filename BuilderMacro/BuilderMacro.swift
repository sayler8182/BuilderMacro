/// A macro that produces Builder
@attached(member, names: arbitrary)
public macro Builder(
    config: BuilderMacroArgs.Config = .init()
) = #externalMacro(
    module: "BuilderMacroMacros",
    type: "BuilderMacro"
)

/// A macro that produces Builder
@attached(member, names: arbitrary)
public macro DebugBuilder(
    config: BuilderMacroArgs.Config = .init()
) = #externalMacro(
    module: "BuilderMacroMacros",
    type: "DebugBuilderMacro"
)
