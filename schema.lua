local typedefs = require "kong.db.schema.typedefs"

local PLUGIN_NAME = "my-json-threat-detection"


local schema = {
  name = PLUGIN_NAME,
  fields = {
    -- the 'fields' array is the top-level entry with fields defined by Kong
    { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer (typical for auth plugins)
    { protocols = typedefs.protocols_http },
    { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
          { container_depth = { 
              type = "integer",
              default = -1,
              required = false} },
          { array_element_count = { 
              type = "integer",
              default = -1,
              required = false}},
          { object_entry_count = {
              type = "integer",
              default = -1,
              required = false} },
          { object_entry_name_length = { 
              type = "integer",
              default = -1,
              required = false}},
          { string_value_length = {
              type = "integer",
              default = -1,
              required = false} },
        },
      },
    },
  },
}

return schema