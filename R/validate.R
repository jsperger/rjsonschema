#' Validates an instance against a JSON schema
#'
#' @description
#' See also official documentation at <https://json-schema.org/>
#'
#' @param schema the schema to validate against, either a json string,
#' an R list of lists, or a file
#' @param instance the instance to validate, either a json string,
#' an R list of lists, or a file
#' @param version the version of the JSON schema to use, one of '2020-12',
#' '2019-09', 'draft-07', 'draft-06', 'draft-05', see also <https://json-schema.org/specification>
#' @param style the style of the output, one of 'minimal' or 'basic'.
#' Minimal returns only TRUE/FALSE, whereas basic returns a list with more details.
#' @param err_on_invalid when set to TRUE, the function calls stop with an error message.
#' The error message is the output of the 'basic' style error for a single error,
#' or 'multiple errors' otherwise. Default FALSE.
#'
#' @return TRUE/FALSE depending on whether the instance is valid against the schema
#' @export
#' @seealso [`validate_schema()`]
#'
#' @examples
#' validate(schema = '{"type": "string"}', instance = '"hello"')
#' validate(schema = '{"type": "string"}', instance = '123')
#' validate(schema = '{"type": "string"}', instance = c('"hello"', '123'))
#'
#' # or provide R objects directly, mixing json and R lists is possible
#' validate(schema = list(type = "string"), instance = list("hello"))
#' validate(schema = list(type = "string"), instance = list(hello = "world"))
#' validate(schema = '{"type": "string"}', instance = list(hello = "world"))
#'
#' # FYI, the correct schema for the above instance is:
#' validate(schema = '{"type": "object", "properties": {"hello": {"type": "string"}}}',
#'          instance = list(hello = "world"))
#'
#' # err_on_invalid throws error for invalid instances
#' tryCatch(validate('{"type": "string"}', instance = '123', err_on_invalid = TRUE),
#'          error = function(e) errorCondition(e))
#'
#' # wrong JSON format throws an error
#' tryCatch(validate(schema = 'wrong JSON format"', ""),
#'          error = function(e) errorCondition(e))
#'
#' # a little more involved example
#' schema <- '{
#'   "type": "object",
#'   "properties": {
#'   "name": { "type": "string" },
#'   "age": { "type": "integer" }
#'   },
#'   "required": ["name"]
#' }'
#' validate(schema, "{\"name\": \"John\"}") # age is optional
#' validate(schema, "{\"name\": \"John\", \"age\": 30}")
#' validate(schema, "{\"age\": 30}") # name is required
#'
#' validate(schema, "{\"age\": 30}", style = "basic")
#'
#' # use different versions
#' # if credit_card is present, billing_address must be present as a string
#' # the dependentSchemas keyword is only available after draft-07
#' dep_schema <- '
#' {
#'   "type": "object",
#'   "properties": {
#'     "name": { "type": "string" },
#'     "credit_card": { "type": "string" }
#'    },
#'   "dependentSchemas": {
#'     "credit_card": {
#'       "properties": {
#'         "billing_address": { "type": "string" }
#'       },
#'     "required": ["billing_address"]
#'     }
#'   }
#' }'
#' validate(dep_schema, '{"name": "Alice", "credit_card": "123"}') # billing address is missing
#' validate(dep_schema, '{"name": "Alice", "credit_card": "123"}', version = "draft04")
#'
#' validate(
#'   schema = '{"$schema": "http://json-schema.org/draft-07/schema#", "type": "string"}',
#'   instance = '"hello"'
#' )
#'
#' # schema and instance in files
#' schema_file <- tempfile(fileext = ".json")
#' writeLines('{"type": "string"}', schema_file)
#'
#' instance_file <- tempfile(fileext = ".json")
#' writeLines('"hello"', instance_file)
#'
#' validate(schema_file, instance_file)
#'
#' file.remove(c(schema_file, instance_file))
validate <- function(schema, instance,
                     version = c("draft202012", "draft201909", "draft07", "draft06",
                                 "draft04"),
                     style = c("minimal", "basic"),
                     err_on_invalid = FALSE) {
  version <- match.arg(version)
  style <- match.arg(style)
  if (err_on_invalid) style <- "basic"

  if (!is.character(schema))
    schema <- yyjsonr::write_json_str(schema, auto_unbox = TRUE)
  if (!is.character(instance))
    instance <- yyjsonr::write_json_str(instance, auto_unbox = TRUE)

  stopifnot("Schema must be a string of length 1" = length(schema) == 1)

  if (endsWith(schema, ".json"))
    schema <- paste(readLines(schema, warn = FALSE), collapse = " ")

  is_json_file <- endsWith(instance, ".json")
  if (any(is_json_file)) {
    stopifnot("If instance is a file, all instances must be a file" = all(is_json_file))
    instance <- sapply(instance, \(f) paste(readLines(f), collapse = " "))
  }

  stopifnot("Schema must be valid JSON" = yyjsonr::validate_json_str(schema))
  for (i in seq_along(instance))
    if (!yyjsonr::validate_json_str(instance[[i]]))
      stop(sprintf("Instance must be valid JSON (index %d)", i))

  if (style == "minimal") {
    r <- validate_rs(schema, instance, version)
  } else {
    r <- lapply(instance, function(inst) validate_basic_rs(schema, inst, version))
  }

  if (style == "basic")
    r <- lapply(r, yyjsonr::read_json_str, arr_of_objs_to_df = FALSE)

  if (err_on_invalid) {
    if (all(sapply(r, "[[", "valid"))) return(TRUE)

    errs <- unlist(lapply(r, "[[", "errors"), recursive = FALSE)
    if (length(errs) == 1)
      stop(sprintf("'%s' for field '%s'", errs[[1]]$error, errs[[1]]$keywordLocation))
    stop(sprintf(
      "Found %s errors.\n\tUse validate(..., style = 'basic') to see details",
      length(errs)
    ))
  }
  r
}
