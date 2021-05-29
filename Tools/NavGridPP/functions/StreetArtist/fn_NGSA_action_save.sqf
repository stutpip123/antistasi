/*
Maintainer: Caleb Serafin
    Exports the formatted navGridDB to clipboard.

Return Value:
    <ANY> undefined.

Scope: Client, Local Arguments, Local Effect
Environment: Any
Public: No

Example:
    call A3A_fnc_NGSA_action_save;
*/

private _fnc_diag_report = {
    params ["_diag_step_main"];

    [3,_diag_step_main,"fn_NGSA_action_save"] call A3A_fnc_log;
    private _hintData = [
        "Export",
        "<t align='left'>" +
        _diag_step_main+
        "</t>",
        false,
        200
    ];
    _hintData call A3A_fnc_customHint;
    _hintData remoteExec ["A3A_fnc_customHint",-clientOwner];
};

"navGridHM is being processed." call _fnc_diag_report;

private _navGridHM = [localNamespace,"A3A_NGPP","navGridHM",0] call Col_fnc_nestLoc_get;
private _navGridDB = [_navGridHM] call A3A_fnc_NG_convert_navGridHM_navGridDB;

private _flatMaxDrift = -1;
private _juncMergeDistance = -1;
private _navGridDB_formatted = ("/*{""systemTimeUCT_G"":"""+(systemTimeUTC call A3A_fnc_systemTime_format_G)+""",""worldName"":"""+worldName+""",""StreetArtist_Config"":{""_flatMaxDrift"":"+str _flatMaxDrift+",""_juncMergeDistance"":"+str _juncMergeDistance+",""_humanEdited"": true}}*/
") + ([_navGridDB] call A3A_fnc_NG_format_navGridDB);
copyToClipboard _navGridDB_formatted;

"Exported!<br/>navGridDB copied to clipboard!" call _fnc_diag_report;
