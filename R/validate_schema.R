#' Validates a JSON schema against the JSON schema specification
#'
#' @description
#' Sources for the schema definitions can be found here:
#' - <https://json-schema.org/draft/2020-12/schema>
#' - <https://json-schema.org/draft/2019-09/schema>
#' - <https://json-schema.org/draft-07/hyper-schema>
#' - <https://json-schema.org/draft-06/hyper-schema>
#' - <https://json-schema.org/draft-04/hyper-schema>
#'
#' @param schema A JSON schema
#' @param version The version of the JSON schema specification to use
#' @param ... Additional arguments passed to [`validate()`]
#'
#' @return TRUE if the schema is valid, FALSE otherwise
#' @export
#'
#' @seealso [`validate()`]
#' @examples
#' validate_schema(schema = '{"type": "string"}', version = "draft202012")
validate_schema <- function(schema,
                            version = c("draft202012", "draft201909", "draft07", "draft06",
                                        "draft04"),
                            ...) {
  version <- match.arg(version)

  draft_file <- system.file(paste0("schema-", version, ".json"), package = "rjsonschema")
  if (!file.exists(draft_file)) stop(sprintf("Could not find schema file for '%s'", version))

  validate(draft_file, schema, ...)
  # validate(draft_file, schema, style = "basic")
}
