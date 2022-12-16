# SRM_SwitchRelocateMission.lua - ArduPilot Lua script

## OVERVIEW:

That script is derived from SM_SwitchMission.lua in  
https://github.com/ArduPilot/ardupilot/tree/master/libraries/AP_Scripting/applets  
and the examples in https://github.com/ArduPilot/ardupilot/tree/master/libraries/AP_Scripting/examples  

That script is useful to select an existing mission on SD-card via RC-channel, relocate (translate/rotate) it and switch to mode-AUTO

The selection can be done by multi-position-switch or pushbutton.

The relocation can be started by long-press of a pushbutton

The kind of relocation can be selected by a 3-pos-switch or directly via parameter

The amount of missions is theoretically unlimited.

This script is intended to use with yaapu-script in transmitter, because all info and warning messages of the script you can receive herein. If you can accept not receiving any feedback, the usecase with a multi-position-switch for selection is possible also without yaapu-script. https://github.com/yaapu/FrskyTelemetryScript

**CAUTION: Use this script AT YOUR OWN RISK**

## GENERAL

  * For not to loose accidentially a mission in FC, at start of the script the Mission in FC is saved to one of five files SRM_Backup#x.waypoints in cyclic manner.  
    The last Backup# you can find in SRM_Count.txt.
  * The file SRM_test is just for finding the correct subdirectory at start of the scrip (it's still existing because lua is not allowed to delete a file).

  * Only Waypoints(MAV_CMD_NAV_WAYPOINT/ID:16) and Spline-Waypoints(MAV_CMD_NAV_SPLINE_WAYPOINT/ID:82) will be relocated.
  * The different MAV_CMD_NAV_LOITER_xyz commands (e.g. MAV_CMD_NAV_LOITER_UNLIM) with optional location-information will not be relocated. If you want to relocate that commands, just put a Waypoint at the location and use the LOITER_xyz without location.
  * Waypoints after DO_LAND_START(MAV_CMD_DO_LAND_START/ID:189) will never be relocated.
  * The Mission will be rotated by the heading of the vehicle at the moment the Start-Button was pressed (relative to North). I.e. if the vehicles heading is East, the rotation will be 90° clockwise. So you should plan your Missions "North-orinted".
  * The altitude of the relocated Waypoints will be adapted only positive. I.e. if the vehicle at relocation is higher than the first Waypoint, all Waypoint elevations will be increased accordingly. If it's lower, no adaption will take place.
  * To prevent from accidentially relocation at start, there is an adjustable safety-radius arround Home. By default that's 50m. If necessary, adapt the parameter SRM_NO_RELOC_M (no relocation of Mission within a radius of XX m around Home) according to your vehicle (kind, size, power, agility, ... - recommended values: Plane:50m, Heli:20m, Copter:10m, Rover:5m)

## HOW THE SCRIPT WORKS:

### Initialization:
  - find or add script-specific parameter-table SRM_
  - find correct subdirectory for SITL or SD-card
  - read necessary parameters, set corresponding values and find corresponding RCx_OPTION-channels
  - backup mission on FC to file SRM_Backup#x.waypoints
  - count available and check sufficient number of missions
  - load selected mission (unrelocated) to FC

### Running:
  - check selection-RC and preselect mission accordingly
  - check start-RC-pushbutton:
      - get current location
      - get kind of relocation
      - relocate the first Waypoint(s.c.Basepoint) of the preselected mission to the current location and the other Waypoins relatively.
  - if selected, the Waypoints will be rotated around the Basepoint by the amount of heading of the vehicle (difference to North) at the moment you pushed the button
      - translate altitude and load Waypoints to FC
      - if no problem, set mode-AUTO

### Special Cases:

    - ??? beim PR nachschauen

## HOW TO USE:
### Preparation:
  - activate scripting on your FC as described here: https://ardupilot.org/dev/docs/common-lua-scripts.html#lua-scripts
  - create the subdirectory 'missions' in the directory where the sripts are stored
  - load the Missions to that subdir
  - select the RC-input-pushbutton you want to use as SRM_RC_START (300..307) and set parameter RCx_OPTION accordingly
  - select the RC-input-3-pos-switch you want to use as SRM_RELOCATION (300..307) and set parameter RCx_OPTION accordingly
    or set SRM_RELOCATION directly to 0=no relocation / 1=translation only / 2=translation+rotation

### Selections
  - Mission
  - Kind of relocation

### Relocation
  - start as usual
  - switch to a none-AUTO mode e.g. FBWB or FBWA in ArduPlane and move to where you want to relocate the Mission
  - push the selected SRM_RC_START button
  - mode-AUTO is selected automatically

Hint for experienced users: 
It would be straightforward to use other sources (e.g. a poti on an RC-Input) to generate the amount of rotation, but from my side it's not intended to overload that script more than necessary.

