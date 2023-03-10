# SRM_SwitchRelocateMission.lua - ArduPilot Lua script

## OVERVIEW:

That script is derived from SM_SwitchMission.lua in  
https://github.com/ArduPilot/ardupilot/tree/master/libraries/AP_Scripting/applets  
and the examples in https://github.com/ArduPilot/ardupilot/tree/master/libraries/AP_Scripting/examples  

That script is useful to select an existing mission on SD-card via RC-channel, relocate (translate/rotate) it and self-switch to mode-AUTO

The selection of the mission can be done by multi-position-switch or pushbutton.

The relocation is started by long-press of a pushbutton

The kind of relocation can be selected by a 3-pos-switch or directly via parameter setting

The amount of missions is theoretically unlimited.

This script is intended to be used at least with yaapu-script in transmitter, because all info and warning messages of the script you can receive herein. If you can accept not receiving any feedback, the usecase with a multi-position-switch for selection is possible also without yaapu-script. https://github.com/yaapu/FrskyTelemetryScript

### **CAUTION: Use this script AT YOUR OWN RISK**

## GENERAL INFORMATION

  * For not to lose accidentially a mission in FC at start of the script, the Mission in FC is saved to one of five files SRM_Backup#x.waypoints in cyclic manner.  
    The last used Backup# you can find in SRM_Count.txt.

  * Only Waypoints (MAV_CMD_NAV_WAYPOINT/ID:16) and Spline-Waypoints (MAV_CMD_NAV_SPLINE_WAYPOINT/ID:82) will be relocated.
  * The diverse MAV_CMD_NAV_LOITER_xyz commands (e.g. MAV_CMD_NAV_LOITER_UNLIM) with optional location-information will not be relocated. If you want to relocate that commands, just put a Waypoint at the location and use the LOITER_xyz without location as next command.
  * Waypoints after DO_LAND_START (MAV_CMD_DO_LAND_START/ID:189) will never be relocated.
  * The Mission will be rotated by the heading of the vehicle at the moment the Start-Button was pressed (relative to North). I.e. if the vehicles heading is East, the rotation will be 90° clockwise. So you should plan your Missions "North-orinted".
  * The altitude of the relocated Waypoints will be adapted only positive. I.e. if the vehicle at relocation is higher than the first Waypoint in mission, all Waypoint elevations will be increased accordingly. If it's lower, no adaption will take place.
  * To prevent from accidentially relocation at start, there is an adjustable safety-radius arround Home within no relocation will happen.

## SUMMARY OF PARAMETERS:

  * ``SRM_POSITIONS`` -- the selection-method and/or amount of switch-positions  
    * &nbsp;&nbsp;1&ensp;= pushbutton for cyclic selection 
    * \>1 &nbsp;= amount of switch-positions
    * &nbsp;&nbsp;0&ensp;= script paused
  * ``SRM_RC_SELECT`` -- the RCx_Option (300..307) for selecting the mission or 0 to use start-button defined in ``SRM_RC_START``
  * ``SRM_RC_START``  -- the selected RCx_Option (300..307) for pushbutton to start the relocation
  * ``SRM_RELOCATION`` -- the selected RCx_Option (300..307) of 3-pos-switch for definition of the kind of relocation or  
  directly via parameter:
    * 0 = no relocation
    * 1 = translation only
    * 2 = translation+rotation
  * ``SRM_NO_RELOC_M`` -- no relocation of Mission within a radius of XX m around Homepoint
    * should be adapted according to vehicle (kind, size, power, agility, ...)
    * recommended: Plane=50m, Copter\+Heli=10..20m, others=5m


## HOW THE SCRIPT WORKS:

### Initialization:
  - find or add script-specific parameter-table SRM_
  - find correct subdirectory for scripting (SITL or SD-card)
  - read necessary parameters, set corresponding values and find corresponding RCx_OPTION-channels
  - backup mission on FC to file SRM_Backup#x.waypoints
  - count available and check sufficient number of missions
  - load via multi-switch selected Mission# or Mission#0 if selection by pushbutton (unrelocated) to FC

### Running:
  - check ``SRM_RC_SELECT`` and preselect mission accordingly
  - check start-RC-pushbutton (long-press) and if activated:
      - get current location
      - get kind of relocation
      - relocate the first Waypoint(s.c.Basepoint) of the preselected mission to the current location and the other Waypoins relatively.
      - if selected, the Waypoints will be rotated around the Basepoint by the amount of heading of the vehicle (difference to North) at the moment you pushed the button
      - translate altitude and load Waypoints to FC
      - if no problem, set mode-AUTO

### Special Cases:

  - If the Parameter ``MIS_RESTART`` is set to 0 (Resume Mission), a further translation is earliest possible after a started Mission is reset or finished completely.

## HOW TO USE:
### Preparation:
  - activate scripting on your FC as described here: https://ardupilot.org/dev/docs/common-lua-scripts.html#lua-scripts
  - adapt ``SCR_HEAP_SIZE`` to e.g. 102400 to have sufficient memory available for the script
  - create the subdirectory 'missions' in the directory where the sripts are stored
  - load the Missions to that subdir:
    * Mission#0.waypoints
    * Mission#1.waypoints
    * Mission#2.waypoints
    * a.s.o.  
    **Hint:** No gap in the mission-numbers allowed
  - select the RC-input-pushbutton you want to use as ``SRM_RC_START`` (300..307) and set parameter ``RCx_OPTION`` accordingly
  - select the RC-input-3-pos-switch you want to use as ``SRM_RELOCATION`` (300..307) and set parameter ``RCx_OPTION`` accordingly
    or set ``SRM_RELOCATION`` directly to 0=no relocation / 1=translation only / 2=translation+rotation

### Options you have to select before relocation
  - Mission# (via pushbutton or multi-switch)
  - Kind of relocation (via 3-pos-switch or parameter ``SRM_RELOCATION``)

### Relocation
  - start as usual
  - switch to a none-AUTO mode e.g. FBWB in ArduPlane and move to where you want to relocate the Mission
  - push the selected ``SRM_RC_START`` button
  - mode-AUTO is selected automatically

## Hint for experienced users: 
It would be straightforward to use other sources (e.g. a poti on an RC-input) to generate the amount of rotation, but from my side it's not intended to overload that script more than necessary.

