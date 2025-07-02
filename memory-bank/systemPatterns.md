# System Patterns

## System Architecture

The `rjsonschema` package follows a common pattern for R packages that incorporate compiled code (in this case, Rust):

1.  **R Interface Layer:**
    *   Located in the `R/` directory.
    *   Contains R functions that users will interact with (e.g., `validate()`, `validate_schema()`).
    *   These functions handle R-specific data types, argument checking, and then call the underlying Rust functions via an interface.
    *   `R/extendr-wrappers.R` suggests the use of the `extendr` framework for R-Rust integration.

2.  **Rust Core Logic Layer:**
    *   Located in the `src/rust/` directory.
    *   Contains the core JSON schema validation logic implemented in Rust.
    *   This layer is responsible for the heavy lifting of parsing schemas and validating JSON data.
    *   It likely uses a Rust crate (library) specializing in JSON schema validation.
    *   `src/rust/Cargo.toml` will define Rust dependencies.

3.  **Integration Layer (extendr):**
    *   `extendr` provides the bridge between R and Rust.
    *   It generates wrapper code (likely in `src/entrypoint.c` and `R/extendr-wrappers.R`) to allow R to call Rust functions and vice-versa.
    *   `src/Makevars.in` and `src/Makevars.win.in` will contain build instructions for compiling the Rust code and linking it into the R package.

## Key Technical Decisions

*   **Using Rust for Performance:** The choice to implement the core validation logic in Rust is driven by the need for performance, especially when dealing with large JSON documents or complex schemas.
*   **Using `extendr` for R-Rust Integration:** `extendr` simplifies the process of creating R packages with Rust code, handling much of the boilerplate for type conversions and function calls.
*   **Supporting Multiple Schema Drafts:** The package intends to support various versions of the JSON Schema specification, which requires careful handling of different meta-schemas and validation rules. This is evident from the schema files in the `inst/` directory (e.g., `inst/schema-draft07.json`).

## Design Patterns in Use

*   **Wrapper/Facade Pattern:** The R functions in `R/` act as a facade, providing a simplified interface to the more complex underlying Rust implementation.
*   **Foreign Function Interface (FFI):** The interaction between R and Rust is a form of FFI. `extendr` abstracts many of the complexities of this.

## Component Relationships

```mermaid
graph TD
    User --> R_Interface[R Functions (R/)]
    R_Interface -- extendr --> Rust_Logic[Rust Validation Core (src/rust/)]
    Rust_Logic -- Uses --> JSON_Schema_Crate[JSON Schema Rust Crate]
    R_Interface -- Returns --> Validation_Result[Validation Result (Boolean/Errors)]
    User -- Receives --> Validation_Result
```

## Critical Implementation Paths

*   **Data Serialization/Deserialization:** Efficient and correct conversion of R objects to JSON strings (or a format Rust can understand) and vice-versa is crucial.
*   **Error Handling:** Propagating detailed validation errors from Rust back to R in a user-friendly format.
*   **Schema Compilation/Caching:** For performance, pre-compiling or caching parsed schemas might be implemented or considered.
*   **Build Process:** Ensuring the Rust code compiles correctly across different platforms (Windows, macOS, Linux) and integrates seamlessly with the R package build system. This is managed via `configure`, `Makevars` files, and `Cargo`.

This provides a good overview of how the system is likely structured. The next step will be to create `techContext.md`.
