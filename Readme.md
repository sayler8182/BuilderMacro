## BuilderMacro

`BuilderMacro` is a macro for generating builders for your structs, simplifying object creation with default values and optional fields. By annotating your struct with `@Builder`, `BuilderMacro` will automatically generate a `Builder` class, allowing you to build instances with default values or custom configurations.

### Usage

To create a builder for a struct, annotate it with `@Builder` and specify default values using `@BuilderDefaultValue`.

```swift
@Builder
struct Breathing {
    /// @BuilderDefaultValue(.init)
    let uuid: UUID
    /// @BuilderDefaultValue(.value(5))
    let duration: Double
    /// @BuilderDefaultValue(.value("defaultValue"))
    let thoughts: String?
}
```
The above code will generate an internal Builder class, which includes methods for setting properties, filling values, and constructing the final instance. The builder provides two main methods for object creation:

- `build()` — Constructs the object using the specified values or default values if properties are omitted.
- `tryBuild()` — Similar to `build()`, but throws an error if required properties are missing.
Generated Builder Code

The generated Builder class for the Breathing struct will look like this:
```swift
final class Builder {
    private enum Error: Swift.Error {
        case missingValue(property: String)
    }
    var uuid: UUID?
    var duration: Double?
    var thoughts: String?

    // Initializers
    required init() { }
    convenience init(_ item: Breathing?) { ... }
    convenience init(uuid: UUID, duration: Double, thoughts: String? = nil) { ... }

    // Static build methods with defaults
    static func build(uuid: UUID = .init(), duration: Double = 5, thoughts: String? = "defaultValue") -> Breathing { ... }
    static func tryBuild(uuid: UUID = .init(), duration: Double = 5, thoughts: String? = "defaultValue") throws -> Breathing { ... }

    // Instance methods for setting values
    func set(uuid: UUID) -> Self { ... }
    func set(duration: Double) -> Self { ... }
    func set(thoughts: String?) -> Self { ... }

    // Final build methods
    func build() -> Breathing { ... }
    func tryBuild() throws -> Breathing { ... }
}

```

## Using the Builder
The Builder allows for flexible object construction:

Option 1: Static build Method

You can call the build method directly on the Builder to create an instance with default or customized values:

```swift
let breathing = Breathing.Builder.build(duration: 7)
```

Option 2: Instance Builder with Chaining

You can create an instance of the Builder and set properties in a chainable way, then call build():

```swift
let breathing = Breathing.Builder()
    .set(duration: 7)
    .set(thoughts: "Calm and focused")
    .build()
```

This chaining approach provides a fluent interface for constructing complex instances with optional properties.

### Error Handling with `tryBuild`
If you want to ensure that all required fields are set, use tryBuild(), which throws an error if any required property is missing:

```swift
do {
    let breathing = try Breathing.Builder().tryBuild()
} catch {
    print("Error building Breathing: \(error)")
}
```

Notes
- `Default Values` - Properties annotated with @BuilderDefaultValue will use the specified default if no value is provided.
- `Required Properties` - Properties without a default must be set before calling build() or tryBuild(), otherwise, the latter will throw an error.

### BuilderDefaultValue Annotations

`@BuilderDefaultValue` allows you to specify default values for properties in your struct when using the `BuilderMacro` or `DebugBuilder`. It offers three main options for defining default values:

1. **`.init`** — Uses the default initializer for the property type.
2. **`.value(...)`** — Uses a specific constant value you define.
3. **`.builder`** — Uses a builder instance to construct the default value for complex types.

Here’s how each option works in practice:

```swift
struct User {
    typealias UserID = String

    /// @BuilderDefaultValue(.init) - Uses `UserID()` as the default value.
    let id: UserID

    /// @BuilderDefaultValue(.value("defaultName")) - Sets `"defaultName"` as the default value.
    let name: String

    /// @BuilderDefaultValue(.builder) - Uses `Value.Builder().build()` as the default value, 
    /// which is useful for complex nested types.
    let value: Value
}
```

Default Value Options
- `.init` - Initializes the property with its type's default initializer, e.g., UUID(), [], "", etc.
- `.value(...)` - Accepts a specific value to use as the default for this property.
- `.builder` - Calls the Builder for a nested type to create a default value, making it ideal for complex properties or nested objects with their own Builder.

This flexibility allows you to control how default values are set for each property, giving you the option to keep initialization concise for common types, set constant defaults for basic data, or initialize complex objects with their own builders.

### Customizing Generated Build Options

The `@Builder` and `@DebugBuilder` macros support an optional configuration property called `config`, which allows you to customize the generated build options. This configuration controls which methods (`build`, `tryBuild`, `staticBuild`, `staticTryBuild`) are included in the generated `Builder` class for each struct.

#### Usage

You can specify `config` by passing in a `BuilderConfig` instance, which takes an `options` array. Each option corresponds to a method in the generated builder:

- `.build`: Adds an instance method `build()` for constructing the struct without throwing errors.
- `.tryBuild`: Adds an instance method `tryBuild()` that throws an error if required properties are missing.
- `.staticBuild`: Adds a static method `build()` that uses default values if no parameters are provided.
- `.staticTryBuild`: Adds a static method `tryBuild()` that throws errors on missing values and provides default values for parameters.

```swift
@DebugBuilder
struct UserDefault {
    let id: String
}

@DebugBuilder(config: .init(options: [.build, .staticBuild]))
struct UserBuild {
    let id: String
}

@DebugBuilder(config: .init(options: [.tryBuild, .staticTryBuild]))
struct UserTryBuild {
    let id: String
}
```

Examples of Generated Code

- `UserDefault` - Without specifying config, the builder includes both build() and tryBuild() instance and static methods by default.
- `UserBuild` - With config: .init(options: [.build, .staticBuild]), the builder includes only build() methods:
- `build()` - Instance method that constructs the struct without throwing errors.
- `static build()` - Static method that constructs the struct, using default values if none are specified.
- `UserTryBuild` - With config: .init(options: [.tryBuild, .staticTryBuild]), the builder includes only tryBuild() methods:
- `tryBuild()` - Instance method that throws an error if required properties are missing.
- `static tryBuild()` - Static method that throws an error on missing values and provides default values for parameters.

This configuration allows you to fine-tune the generated builder to include only the methods needed for your struct, making the builder class leaner and focused on your requirements.

## DebugBuilder Macro

`DebugBuilder` is a variation of the `BuilderMacro` that wraps all generated builder code in `#if DEBUG` conditionals. This ensures that builder classes are only generated and accessible in debug builds, keeping production builds optimized and free from additional code that’s only useful for testing or debugging.
To use `DebugBuilder`, simply replace `@Builder` with `@DebugBuilder` on your struct.

Key Points
- `Debug-only` - @DebugBuilder keeps builder code out of production builds, ideal for debugging and testing environments.
- `Easy Swap` - Switch between @Builder and @DebugBuilder based on whether you want builder code in production or debug-only builds.
