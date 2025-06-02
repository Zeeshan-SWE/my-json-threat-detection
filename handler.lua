
local JsonThreatHandler = {
    VERSION = kong_meta.version,
    PRIORITY = 1000,
}

local cjson = require("cjson")
local cjson_safe = require("cjson.safe")

local content_type = kong.request.get_header("content-type")
local request_method = kong.request.get_method()

local function get_body()
    local body, err = kong.request.get_raw_body()
    if err then
      kong.log.info("Cannot process request body: ", err)
      return EMPTY
    end
  
    return body
end
  
local function server_error(message)
    return { status = 500, message = message }
end

local function bad_request(errorCode, errorReason)
    return { status = 400, message = { 
        errorCode = errorCode,
        message = "JSON Threat Detected",
        reason = errorReason,
        href = "https://api.random-website.com/docs/errors#" .. errorCode
    }, headers = { ["Content-Type"] = "application/json" } }
end

local function is_array(table)
    local max = 0
    local count = 0
    for k, v in pairs(table) do
        if type(k) == "number" then
            if k > max then max = k end
            count = count + 1
        else
            return -1
        end
    end
    if max > count * 2 then
        return -1
    end

    return max
end

local function validateJson(json, array_element_count, object_entry_count, object_entry_name_length, string_value_length)
    if type(json) == "table" then
        if array_element_count > 0 then
            local array_children = is_array(json)
            if array_children > array_element_count then
                return nil, bad_request("1000", "JSONThreatProtection[ExceededArrayElementCount]: Exceeded array element count, max " .. array_element_count .. " allowed, found " .. array_children .. ".")
            end
        end

        local children_count = 0
        for k,v in pairs(json) do
            children_count = children_count + 1
            if object_entry_name_length > 0 then
                if string.len(k) > object_entry_name_length then
                    return nil, bad_request("1001", "JSONThreatProtection[ExceededObjectEntryNameLength]: Exceeded object entry name length, max " .. object_entry_name_length .. " allowed, found " .. string.len(k) .. " (" .. k .. ").") 
                end
            end

            local result, message = validateJson(v, array_element_count, object_entry_count, object_entry_name_length, string_value_length)
            if result == false then
                return false, message
            end
        end

        if object_entry_count > 0 then
            if children_count > object_entry_count then
                return nil, bad_request("1002", "JSONThreatProtection[ExceededObjectEntryCount]: Exceeded object entry count, max " .. object_entry_count .. " allowed, found " .. children_count .. ".")
            end
        end

    else
        if string_value_length > 0 then
            if string.len(json) > string_value_length then
                return  nil, bad_request("1003", "JSONThreatProtection[ExceededStringValueLength]: Exceeded string value length, max " .. string_value_length .. " allowed, found " .. string.len(json) .. " (" .. json .. ").")
            end
        end
    end
end

local function JsonValidator(body, container_depth, array_element_count, object_entry_count, object_entry_name_length, string_value_length)

    local valid = cjson_safe.decode(body)
    if not valid then
        return nil, bad_request("1004", "")
    end

    if container_depth > 0 then
        cjson.decode_max_depth(container_depth)
    end

    local status, json = pcall(cjson.decode, body)

    if not status then
        return nil, bad_request("1005", "JSONThreatProtection[ExceededContainerDepth]: Exceeded container depth, max " .. container_depth .. " allowed.")
    end
    validateJson(json, array_element_count, object_entry_count, object_entry_name_length, string_value_length)
end

function JsonThreatHandler:access(config)
    -- check if preflight request
    if not config.run_on_preflight and kong.request.get_method() == "OPTIONS" then
      return
    end

    if string.match(content_type, "application/json") and  request_method ~= "GET" then
        JsonValidator(get_body(), config.container_depth, config.array_element_count, config.object_entry_count, config.object_entry_name_length, config.string_value_length)
    end
end

return JsonThreatHandler