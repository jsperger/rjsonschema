library(testthat)

test_that("validate works", {
  expect_true(validate(schema = '{"type": "string"}', instance = '"hello"'))
  expect_false(validate(schema = '{"type": "string"}', instance = '123'))
  expect_equal(validate(schema = '{"type": "string"}', instance = c('"hello"', '123')),
               c(TRUE, FALSE))

  # or provide R objects directly, mixing json and R lists is possible
  expect_false(validate(schema = list(type = "string"), instance = list(hello = "world")))
  expect_false(validate(schema = '{"type": "string"}', instance = list(hello = "world")))

  # FYI, the correct schema for the above instance is:
  expect_true(validate(schema = '{"type": "object", "properties": {"hello": {"type": "string"}}}',
                       instance = list(hello = "world")))

  # err_on_invalid = TRUE
  expect_error(validate(schema = '{"type": "string"}', instance = '123',
                        err_on_invalid = TRUE),
               regexp = "'123 is not of type \"string\"' for field '/type'")

  # wrong JSON format throws an error
  expect_error(validate(schema = 'wrong JSON format"', ""),
               regexp = "Schema must be valid JSON")
  expect_error(validate(schema = '{"type": "string"}', "'wrong JSON"),
               regexp = "Instance must be valid JSON \\(index 1\\)")

  # a little more involved example
  schema <- '{
    "type": "object",
    "properties": {
      "name": { "type": "string" },
      "age": { "type": "integer" }
    },
    "required": ["name"]
  }'
  expect_true(validate(schema, "{\"name\": \"John\"}")) # age is optional
  expect_true(validate(schema, "{\"name\": \"John\", \"age\": 30}"))
  expect_false(validate(schema, "{\"age\": 30}")) # name is required

  res <- validate(schema, "{\"age\": 30}", style = "basic")
  expect_equal(
    res,
    list(list(errors = list(list(error = '"name" is a required property', instanceLocation = "", keywordLocation = "/required")),
              valid = FALSE))
  )

  # use different versions
  # if credit_card is present, billing_address must be present as a string
  # the dependentSchemas keyword is only available after draft-07
  dep_schema <- '
    {
      "type": "object",
      "properties": {
        "name": { "type": "string" },
        "credit_card": { "type": "string" }
       },
      "dependentSchemas": {
        "credit_card": {
          "properties": {
            "billing_address": { "type": "string" }
          },
        "required": ["billing_address"]
        }
      }
    }'
  expect_false(validate(dep_schema, '{"name": "Alice", "credit_card": "123"}')) # billing address is missing
  expect_false(validate(dep_schema, '{"name": "Alice", "credit_card": "123"}', version = "draft04"))

  # basic style
  expect_equal(
    validate(dep_schema, '{"name": "Alice", "credit_card": "123"}', style = "basic"),
    list(list(errors = list(list(error = '"billing_address" is a required property',
                                 instanceLocation = "", keywordLocation = "/dependentSchemas")),
              valid = FALSE))
  )

  # err_on_invalid = TRUE
  expect_error(validate(dep_schema, '{"name": 123, "credit_card": "123"}',
                        err_on_invalid = TRUE),
               regexp = "Found 2 errors.")

  # validate with $schema
  expect_true(validate(
    schema = '{"$schema": "http://json-schema.org/draft-07/schema#", "type": "string"}',
    instance = '"hello"'
  ))

  # schema and instance in files
  schema_file <- tempfile(fileext = ".json")
  writeLines('{"type": "string"}', schema_file)

  instance_file <- tempfile(fileext = ".json")
  writeLines('"hello"', instance_file)

  expect_true(validate(schema_file, instance_file))

  file.remove(c(schema_file, instance_file))
})
