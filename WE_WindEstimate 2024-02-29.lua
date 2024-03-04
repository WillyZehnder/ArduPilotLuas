--[[

WE_WindEstimate.lua - ArduPilot Lua script
  
This script is useful get info about the current wind-estimation on your GCS

CAUTION: Use this script AT YOUR OWN RISK.

-- Willy Zehnder -- 02.02.2024
-- Willy Zehnder -- 29.02.2024 10s -> 15s und WARN zu INFO

]]
-------- SCRIPT 'CONSTANTS' --------
local SCRIPT_NAME           = 'WE'          -- abbreviation of scriptname for messages on GCS
local SHORT_INTERV_MS       = 20            -- interval to find param_table_key
local INTERRUPTED_MS        = 15000         -- restart interval

local WARN                  =   4           -- MAV_SEVERITY_WARNING
local INFO                  =   6           -- MAV_SEVERITY_INFO

-------- SCRIPT PARAMETERS --------
local PARAM_PREFIX          = 'WE_'
local PARAM_TABLE           = {
--  {          name  ,          default },
    { 'RC_RUN'       ,              307 },    -- the selected RCx_Option (300..307) for continually running the script
    { 'INTERVAL'     ,               15 },    -- waiting time to restart the script
}
local INTERVAL = Parameter()                  -- create Parameter() objects for frequently read paramters
local param_table_key       = 0               -- start-value for searching free or still used table-key between 0 and 200
local scr_rc_run          = nil               -- RC-channel of start-button


local function send_msg(msg_type, msg)
  -- wrapper for sending messages to the GCS
  gcs:send_text(msg_type, string.format('%s: %s', SCRIPT_NAME, msg))
end

local function add_params(key, prefix, tbl)
-- add script-specific parameter table
  if not param:add_table(key, prefix, #tbl) then
--    send_msg(INFO, string.format('key %d occupied', key))
    return false
  end
  for num, data in ipairs(tbl) do
      assert(param:add_param(key, num, data[1], data[2]), string.format('%s: Could not add %s%s.', SCRIPT_NAME, prefix, data[1]))
  end
  return true
end

local function get_wind_direction()
  if (scr_rc_run:get_aux_switch_pos() >= 1) then
    local wind = ahrs:wind_estimate() -- get the wind estimate
    if wind then
      local wind_xy = Vector2f()
      -- function Vector2f_ud:angle() end
      wind_xy:x(wind:x())
      wind_xy:y(wind:y())
      local speed = wind_xy:length()
      local winddir = math.fmod((180+math.deg(wind_xy:angle())), 360.0)
      send_msg(INFO, string.format('Wind %4.1f m/s %4.0f Grad', speed, winddir))
    else
      send_msg(WARN, 'Aktuell keine Windabschätzung vorhanden')
    end
  end
  return get_wind_direction, INTERRUPTED_MS
end
  

-- ### initialisation of all necessary environment ###
function initialize()

-- add script-specific parameter-table
  if not add_params(param_table_key, PARAM_PREFIX, PARAM_TABLE) then
    if param_table_key < 200 then
      param_table_key = param_table_key + 1
      return initialize, SHORT_INTERV_MS
    else
      send_msg(WARN, string.format('Could not add table %s', PARAM_PREFIX))
      return initialize, INTERRUPTED_MS
    end
  end

  local option_name = string.format('%s%s', PARAM_PREFIX, 'INTERVAL')
  if not INTERVAL:init(option_name) then
    send_msg(WARN, string.format('get parameter %s failed', option_name))
    return initialize, INTERRUPTED_MS
  end


  -- read the selected option in SRM_ parameter and find corresponding rc-channel for the run-button  
  option_name = string.format('%s%s', PARAM_PREFIX, 'RC_RUN')
  local option_value = param:get(option_name)
  if option_value then
    if (option_value >= 300) and (option_value <= 307) then
      -- find channel for start-button
      scr_rc_run = rc:find_channel_for_option(option_value)
      if not scr_rc_run then
        send_msg(WARN, string.format('RCx_OPTION(%s) = %d not found', option_name, option_value))
        return initialize, INTERRUPTED_MS
      end
    else
      send_msg(WARN, string.format('%s: %i out of range (300..307)', option_name, option_value))
      return initialize, INTERRUPTED_MS
    end
  else
    send_msg(WARN, string.format('get parameter %s failed', option_name))
    return initialize, INTERRUPTED_MS
  end

  return get_wind_direction, INTERVAL:get()*1000
end

return initialize()
