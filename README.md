
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rjsonschema 

<!-- badges: start -->

[![R-CMD-check](https://github.com/DavZim/rjsonschema/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/DavZim/rjsonschema/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/rjsonschema)](https://CRAN.R-project.org/package=rjsonschema)
<!-- badges: end -->

The goal of `rjsonschema` is to validate JSON strings or objects against
JSON schema definitions. For an introduction to JSON schemas, visit:
<https://json-schema.org/>.

The package is a light wrapper around the
[`jsonschema-rs`](https://docs.rs/jsonschema/latest/jsonschema/)
([Github source](https://github.com/Stranger6667/jsonschema)) Rust
crate.

## Installation

You can install the development version of `rjsonschema` like so:

``` r
# DEV version
# remotes::install_github("DavZim/rjsonschema")

# CRAN version
install.packages("rjsonschema")
```

## Usage Example

``` r
library(rjsonschema)

# 1. define a simple schema
schema <- '{"type": "string"}'

# 2. test the schema against JSON strings
# note '123' is a JSON string, which represents an integer and not a string!
validate(schema = schema, instance = '"hello world"') # passes as "hello" is a string
#> [1] TRUE
validate(schema = schema, instance = '123') # fails as 123 is not a string
#> [1] FALSE

# multiple instances work!
validate(schema = '{"type": "string"}', instance = c('"hello"', '123'))
#> [1]  TRUE FALSE

# get more information about the validation with style basic
validate(schema = '{"type": "string"}', instance = '123', style = "basic") |> 
  str()
#> List of 1
#>  $ :List of 2
#>   ..$ errors:List of 1
#>   .. ..$ :List of 3
#>   .. .. ..$ error           : chr "123 is not of type \"string\""
#>   .. .. ..$ instanceLocation: chr ""
#>   .. .. ..$ keywordLocation : chr "/type"
#>   ..$ valid : logi FALSE

validate(schema = '{"type": "string"}', instance = c('"hello"', '123'), style = "basic") |> 
  str()
#> List of 2
#>  $ :List of 2
#>   ..$ annotations: list()
#>   ..$ valid      : logi TRUE
#>  $ :List of 2
#>   ..$ errors:List of 1
#>   .. ..$ :List of 3
#>   .. .. ..$ error           : chr "123 is not of type \"string\""
#>   .. .. ..$ instanceLocation: chr ""
#>   .. .. ..$ keywordLocation : chr "/type"
#>   ..$ valid : logi FALSE
```

Note, both instance and schema can be JSON strings (as shown above),
file names to JSON files, or R objects (mostly lists).

You can also validate a schema against a specific JSON meta schema (the
JSON schema definition of a schema).

``` r
schema <- '{"type": "string"}'
# if you want to have a look at the meta scheme, see the following file:
# system.file("schema-draft202012.json", package = "rjsonschema") or
# <https://json-schema.org/draft/2020-12/schema>
validate_schema(schema, version = "draft202012")
#> [1] TRUE
```

If you want to use this function with `stopifnot()`, or similar
assertion libraries, you can set `err_on_invalid` to `TRUE`:

``` r
validate(schema = '{"type": "string"}', instance = '123', err_on_invalid = TRUE)
#> Error in validate(schema = "{\"type\": \"string\"}", instance = "123", : '123 is not of type "string"' for field '/type'
```

## Full Example

A longer example, taken from [the official getting started
guide](https://json-schema.org/learn/getting-started-step-by-step), is
the following. For a store, we are given the following schema, which
defines a JSON for a product:

``` json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://example.com/product.schema.json",
  "title": "Product",
  "description": "A product from Acme's catalog",
  "type": "object",

  "properties": {

    "productId": {
      "description": "The unique identifier for a product",
      "type": "integer"
    },

    "productName": {
      "description": "Name of the product",
      "type": "string"
    },

    "price": {
      "description": "The price of the product",
      "type": "number",
      "exclusiveMinimum": 0
    },

    "tags": {
      "description": "Tags for the product",
      "type": "array",
      "items": {
        "type": "string"
      },
      "minItems": 1,
      "uniqueItems": true
    }

  },
  "required": [ "productId", "productName", "price" ]
}
```

The schema is shipped with the package and can be accessed like so:

``` r
schema <- system.file("example_schema_catalog.json", package = "rjsonschema")
```

We can now validate a JSON object against the schema:

``` r
validate(
  schema,
  '{"productId": 1, "productName": "A green door", "price": 12.50}'
)
#> [1] TRUE
```

Note that instance can also be an R list directly (will be converted to
JSON for validation):

``` r
validate(
  schema,
  list(productId = 1, productName = "A green door", price = 12.50)
)
#> [1] TRUE
```

The JSON object is valid, as it adheres to the schema.

However, the following JSON object is not valid:

``` r
validate(
  schema,
  '{"productId": "1", "productName": "A green door", "price": 0}'
)
#> [1] FALSE
res <- validate(
  schema,
  '{"productId": "1", "productName": "A green door", "price": 0}',
  style = "basic"
)
str(res)
#> List of 1
#>  $ :List of 2
#>   ..$ errors:List of 2
#>   .. ..$ :List of 4
#>   .. .. ..$ absoluteKeywordLocation: chr "https://example.com/product.schema.json#/properties/price/exclusiveMinimum"
#>   .. .. ..$ error                  : chr "0 is less than or equal to the minimum of 0"
#>   .. .. ..$ instanceLocation       : chr "/price"
#>   .. .. ..$ keywordLocation        : chr "/properties/price/exclusiveMinimum"
#>   .. ..$ :List of 4
#>   .. .. ..$ absoluteKeywordLocation: chr "https://example.com/product.schema.json#/properties/productId/type"
#>   .. .. ..$ error                  : chr "\"1\" is not of type \"integer\""
#>   .. .. ..$ instanceLocation       : chr "/productId"
#>   .. .. ..$ keywordLocation        : chr "/properties/productId/type"
#>   ..$ valid : logi FALSE
```
