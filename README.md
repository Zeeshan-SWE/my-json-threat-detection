## 👨‍💻 Developed By

**Zeeshan Shah Syed**  
DevOps & Cloud Engineer | 9+ years experience in building scalable, secure, and highly available infrastructure.

# 🛡️ My JSON Threat Detection Plugin for Kong

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Lua](https://img.shields.io/badge/language-Lua-blue.svg)](https://www.lua.org/)
[![Kong](https://img.shields.io/badge/kong-plugin-blueviolet.svg)](https://docs.konghq.com/)

This Kong plugin inspects JSON request bodies and blocks those that violate configurable structural limits. It acts as a **lightweight JSON application firewall**, preventing abuse from oversized or deeply nested payloads.

---

## 📖 Table of Contents

- [Features](#-features)
- [Use Case](#-use-case)
- [Configuration Options](#-configuration-options)
- [Error Format](#-error-format)
- [Installation](#-installation)
- [Enable the Plugin](#-enable-the-plugin)
- [Example](#-example)
- [Development](#-development)
- [License](#-license)

---

## ✅ Features

- Enforce max **container depth** for nested objects/arrays
- Block large arrays via **array element count**
- Limit object size via **object entry count**
- Restrict **object key name lengths**
- Enforce max **string value lengths**
- Rejects invalid JSON or request types with structured error responses
- Skips GET and OPTIONS requests for performance

---

## 💡 Use Case

This plugin is useful for:

- APIs that accept JSON and are vulnerable to **Denial of Service (DoS)** via deep or oversized payloads.
- APIs that need **strict structure validation** as a basic security enforcement layer.
- Environments where gateway-level data sanitization is critical before hitting upstream systems.

---

## ⚙️ Configuration Options

| Name                    | Type    | Default | Description                                                                 |
|-------------------------|---------|---------|-----------------------------------------------------------------------------|
| `container_depth`       | integer | `-1`    | Maximum allowed nested JSON levels (objects/arrays)                         |
| `array_element_count`   | integer | `-1`    | Maximum number of elements in a JSON array                                 |
| `object_entry_count`    | integer | `-1`    | Maximum number of fields (key-value pairs) in a JSON object                |
| `object_entry_name_length` | integer | `-1` | Maximum character length for any JSON key name                             |
| `string_value_length`   | integer | `-1`    | Maximum character length for string values in the JSON                     |
| `run_on_preflight`      | boolean | `false` | Whether to run this plugin on `OPTIONS` (CORS preflight) requests          |

> **Note**: Any value set to `-1` means **no limit** for that field.

---

## 🚨 Error Format

When a request violates any configured rule, the plugin returns:

```json
{
  "errorCode": "1002",
  "message": "JSON Threat Detected",
  "reason": "JSONThreatProtection[ExceededObjectEntryCount]: Exceeded object entry count, max 50 allowed, found 100.",
  "href": "https://api.random-website.com/docs/errors#1002"
}
All errors respond with HTTP status 400 (Bad Request) except internal server issues, which return 500.

📦 Installation
Copy plugin files to your Kong plugin directory:

pgsql
kong/plugins/my-json-threat-detection/
├── handler.lua
├── schema.lua
└── my-json-threat-detection.rockspec
Update Kong configuration:

bash
plugins = bundled,my-json-threat-detection
Restart Kong:

bash
kong restart
🚀 Enable the Plugin
Enable globally, on a service, or on a route:

bash
curl -i -X POST http://localhost:8001/plugins \
  --data "name=my-json-threat-detection" \
  --data "config.container_depth=5" \
  --data "config.array_element_count=10" \
  --data "config.object_entry_count=20"

🔍 Example
Example Valid Payload:

json
{
  "user": {
    "name": "John Doe",
    "roles": ["admin", "editor"]
  }
}
Example Invalid Payload:

json
{
  "a": { "b": { "c": { "d": { "e": { "f": "too deep" } } } } }
}
If container_depth = 4, the above will be blocked with error 1005.

🧪 Development
To test locally:

bash
# Inside your plugin directory
luarocks make my-json-threat-detection.rockspec

# Restart Kong with plugin loaded
kong restart
Ensure test APIs are available that accept JSON bodies via POST, PUT, etc.

📄 License
This plugin is licensed under the MIT License.

🤝 Contributing
Feel free to submit issues or pull requests. All feedback is welcome!

📬 Contact
Feel free to connect with me on LinkedIn: https://www.linkedin.com/in/syed-s-2a3638264/ or reach out at zeeshanshahsyed14@gmail.com for collaboration or questions!
