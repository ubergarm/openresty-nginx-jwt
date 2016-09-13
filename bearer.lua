local jwt = require "resty.jwt"

local auth_header = ngx.var.http_Authorization
if auth_header == nil then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say("{error: 'missing Authorization header'}")
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

local _, _, token = string.find(auth_header, "Bearer%s+(.+)")
if token == nil then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say("{error: 'missing Bearer token'}")
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

-- validate any specific claims you need here
-- https://github.com/SkyLothar/lua-resty-jwt#jwt-validators
local validators = require "resty.jwt-validators"
local claim_spec = {
    sub = validators.opt_matches("^[0-9]+$"),
    name = validators.equals_any_of({ "John Doe", "Mallory", "Alice", "Bob" }),
}

-- make sure to set and put "env JWT_SECRET;" in nginx.conf
local jwt_obj = jwt:verify(os.getenv("JWT_SECRET"), token, claim_spec)
if not jwt_obj["verified"] then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.log(ngx.WARN, jwt_obj.reason);
    ngx.say("{error: '" .. jwt_obj.reason .. "'}");
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end
