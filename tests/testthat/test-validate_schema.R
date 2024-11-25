test_that("validate_schema works", {
  expect_true(validate_schema(schema = '{"type": "string"}',
                              version = "draft202012"))

})
