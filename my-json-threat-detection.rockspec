package = "my-json-threat-detection"
version = "0.1.0-0"
rockspec_format = "3.0"
supported_platforms = {"linux", "macosx"}
source = {
  url = "git+https://github.com/Kong/kong.git",
  tag = "3.10.0"
}
description = {
  summary = "My JSON Threat Detection plugin is useful to detect and prevent json payload attacks.",
  homepage = "https://konghq.com",
  license = "Apache 2.0"
}

dependencies = {
   "lua-cjson >= 2.1"
   "lua ~> 5.1",
   "stringy ~> 0.4-1"
}


build = {
  type = "builtin",
  modules = {
    ["kong.plugins.my-json-threat-detection.handler"] = "kong/plugins/my-json-threat-detection/handler.lua",
    ["kong.plugins.my-json-threat-detection.schema"] = "kong/plugins/my-json-threat-detection/schema.lua",
  }
}