// Hope you like pointers and references, they are used widely in the following code to improve performance
// [35,15] spawn A3A_fnc_NG_start;

params [
    ["_degTolerance",35,[ 35 ]],  // if straight roads azimuth are within this tolerance, they are merged.
    ["_maxDistance",15,[ 15 ]] // Junctions are only merged if within this distance.
];

private _diag_step_main = "";
private _diag_step_sub = "";
private _diag_step_sub_progress = []; // <Array<island,totalIslandSegments>>

private _diag_totalSegments = -1;
private _diag_islandCounter = -1;
private _diag_segmentCounter = 0;

private _fnc_diag_render = { // call _fnc_diag_render;
    [
        "Nav Grid++",
        "<t align='left'>" +
        _diag_step_main+"<br/>"+
        "Completed Islands: <br/>"+
        ((_diag_step_sub_progress apply {"  " + (str (_x#0)) + " : " + (str (_x#1))}) joinString "<br/>") +"<br/>"+
        _diag_step_sub+"<br/>"+
        "</t>"
    ] remoteExec ["A3A_fnc_customHint",0];
};

_diag_step_main = "Extracting roads";
call _fnc_diag_render;

private _halfWorldSize = worldSize/2;
private _worldCentre = [_halfWorldSize,_halfWorldSize];
private _worldMaxRadius = sqrt(0.5 * (worldSize^2));

private _const_allowedRoadTypes = ["ROAD", "MAIN ROAD", "TRACK"];
private _allRoadObjects = nearestTerrainObjects [_worldCentre, _const_allowedRoadTypes, _worldMaxRadius, false, true];
private _navGrid = _allRoadObjects apply {
    private _road = _x;
    private _connected = roadsConnectedTo [_x,true] select {getRoadInfo _x #0 in _const_allowedRoadTypes};
    [_road,_connected,_connected apply {_X distance2D _road}];
};

_navGrid = [_navGrid] call A3A_fnc_NG_missingRoadCheck;

_navGrid = [_navGrid,_degTolerance] call A3A_fnc_NG_simplify_flat;    // Gives less markers for junc to work on. (junc is far more expensive)
_navGrid = [_navGrid,_maxDistance] call A3A_fnc_NG_simplify_junc;
_navGrid = [_navGrid] call A3A_fnc_NG_simplify_conDupe;
_navGrid = [_navGrid,15] call A3A_fnc_NG_simplify_flat;    // Clean up after junc, much smaller tolerance

_diag_step_main = "Separating Island";
call _fnc_diag_render;
_navIslands = [_navGrid] call A3A_fnc_NG_seperateIslands;

private _navGridDB = [_navIslands] call A3A_fnc_NG_convert_navIslands_navGridDB;
copyToClipboard str _navGridDB;
_navIslands = [_navGridDB] call A3A_fnc_NG_convert_navGridDB_navIslands;

_diag_step_main = "Drawing Markers";
_diag_step_sub = "Drawing LinesBetweenRoads";
call _fnc_diag_render;
[_navIslands,true,true] call A3A_fnc_NG_draw_linesBetweenRoads;
_diag_step_main = "Drawing Markers";
_diag_step_sub = "Drawing DotsOnRoads";
call _fnc_diag_render;
[_navIslands] call A3A_fnc_NG_draw_dotOnRoads;

_diag_step_main = "Done";
_diag_step_sub = "Done";
call _fnc_diag_render;