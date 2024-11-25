use extendr_api::prelude::*;

// Validates a schema in the default config
#[extendr]
fn validate_rs(schema: String, instance: Vec<String>, version: String) -> Vec<bool> {

  let schema_json = serde_json::from_str(&schema).unwrap();
  let validator: jsonschema::Validator;

  if version == "draft4" {
    validator = jsonschema::draft4::new(&schema_json).unwrap();
  } else if version == "draft6" {
    validator = jsonschema::draft6::new(&schema_json).unwrap();
  } else if version == "draft7" {
    validator = jsonschema::draft7::new(&schema_json).unwrap();
  } else if version == "draft201909" {
    validator = jsonschema::draft201909::new(&schema_json).unwrap();
  } else if version == "draft202012" {
    validator = jsonschema::draft202012::new(&schema_json).unwrap();
  } else {
    // eg let schema = json!({"$schema": "http://json-schema.org/draft-07/schema#", "type": "string"});
    validator = jsonschema::validator_for(&schema_json).unwrap();
  }

  let instance_json: Vec<serde_json::Value> = instance
    .iter()
    .map(|x| serde_json::from_str(x).unwrap())
    .collect();

  instance_json
    .iter()
    .map(|x| validator.is_valid(x))
    .collect()
}

// Validates a schema in the basic config, see also:
// https://docs.rs/jsonschema/latest/jsonschema/index.html#output-styles
#[extendr]
fn validate_basic_rs(schema: String, instance: Vec<String>, version: String) -> Vec<String> {

  let schema_json = serde_json::from_str(&schema).unwrap();
  let validator: jsonschema::Validator;

  if version == "draft4" {
    validator = jsonschema::draft4::new(&schema_json).unwrap();
  } else if version == "draft6" {
    validator = jsonschema::draft6::new(&schema_json).unwrap();
  } else if version == "draft7" {
    validator = jsonschema::draft7::new(&schema_json).unwrap();
  } else if version == "draft201909" {
    validator = jsonschema::draft201909::new(&schema_json).unwrap();
  } else if version == "draft202012" {
    validator = jsonschema::draft202012::new(&schema_json).unwrap();
  } else {
    // eg let schema = json!({"$schema": "http://json-schema.org/draft-07/schema#", "type": "string"});
    validator = jsonschema::validator_for(&schema_json).unwrap();
  }


  let instance_json: Vec<serde_json::Value> = instance
    .iter()
    .map(|x| serde_json::from_str(x).unwrap())
    .collect();

  instance_json
    .iter()
    .map(|x| serde_json::to_value(validator.apply(x).basic()).unwrap().to_string())
    .collect()
}


// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod rjsonschema;
    fn validate_rs;
    fn validate_basic_rs;
}
