# Tech Context

## Technologies Used

*   **R:** The primary language for the package interface and for users.
    *   **R Version:** Not explicitly specified, but RoxygenNote 7.3.2 and testthat (>= 3.0.0) suggest a relatively modern R environment.
    *   **`yyjsonr`:** Listed in `Imports` in the `DESCRIPTION` file. This R package is likely used for parsing and handling JSON data within R, possibly for converting R objects to JSON strings or vice-versa before passing to/from Rust.
    *   **`testthat`:** Used for unit testing (>= 3.0.0, edition 3).
    *   **`roxygen2`:** Used for documentation generation (version 7.3.2).
*   **Rust:** Used for the core JSON schema validation logic for performance.
    *   **Rust Version:** `rustc (>= 1.70)` is specified in `SystemRequirements`.
    *   **`extendr`:** (version `0.3.1.9001` from `Config/rextendr/version`) Framework used to integrate R and Rust. It generates wrapper code for calling Rust functions from R. This is evident in `R/extendr-wrappers.R` and the `extendr-api` dependency in `Cargo.toml`.
    *   **`jsonschema` crate:** (version `0.26.1`) The Rust library used to perform the actual JSON schema validation, as seen in `src/rust/Cargo.toml`. This is a key component.
    *   **`serde_json` crate:** (version `1.0.133`) A popular Rust library for serializing and deserializing JSON data. Likely used to work with JSON data within the Rust portion of the codebase.
    *   **Cargo:** Rust's package manager and build system, specified in `SystemRequirements`.

## Development Setup

*   **Build System:** The R package build system, which in turn calls Cargo to build the Rust static library.
    *   `configure` and `configure.win`: Scripts to set up the build environment, particularly for Rust.
    *   `src/Makevars.in` and `src/Makevars.win.in`: Makefiles that define how to compile the Rust code and link it into the R package. These are processed by `configure` to create `src/Makevars` and `src/Makevars.win`.
*   **Package Structure:** Standard R package layout (`R/`, `src/`, `man/`, `tests/`, `DESCRIPTION`, `NAMESPACE`).
*   **Version Control:** Git is used (implied by `.gitignore` and `.github/` files).

## Technical Constraints

*   **CRAN Policies:** As an R package potentially targeting CRAN, it must adhere to CRAN policies regarding build processes, system dependencies, and code portability.
*   **Rust Toolchain:** Users and developers will need a Rust toolchain (rustc and cargo) installed to build the package from source or contribute.
*   **Cross-Platform Compilation:** The Rust code needs to compile and work correctly on Windows, macOS, and Linux, the primary platforms supported by R.

## Dependencies

*   **R Package Dependencies:**
    *   `yyjsonr` (Import)
*   **Rust Crate Dependencies (from `src/rust/Cargo.toml`):**
    *   `extendr-api`
    *   `jsonschema = "0.26.1"`
    *   `serde_json = "1.0.133"`
*   **System Dependencies:**
    *   `Cargo`
    *   `rustc (>= 1.70)`

## Tool Usage Patterns

*   **`extendr`:** Used to generate the FFI bridge between R and Rust. The command `.Call("wrap__make_rjsonschema_wrappers", ...)` in `R/extendr-wrappers.R` indicates its use.
*   **`roxygen2`:** For generating R documentation from inline comments.
*   **`testthat`:** For running unit tests located in `tests/testthat/`.
*   **GitHub Actions:** Used for CI/CD, as indicated by files in `.github/workflows/`.
    *   `R-CMD-check.yaml`: Likely runs R CMD check on pushes/pull requests.
    *   `pkgdown.yaml`: Likely builds and deploys package documentation using `pkgdown`.

This gives a good technical overview. The next files, `activeContext.md` and `progress.md`, are more about the *current state* of work, so I will create them with minimal initial content, as I'm just starting to understand the repository.
