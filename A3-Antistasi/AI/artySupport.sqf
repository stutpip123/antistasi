if (count hcSelected player == 0) exitWith {hint "You must select an artillery group"};

private ["_groups","_artyArray","_artyRoundsArr","_hasAmmo","_areReady","_hasArty","_areAlive","_soldierX","_veh","_typeAmmunition","_tipoArty","_positionTel","_artyArrayDef1","_artyRoundsArr1","_pieza","_isInRange","_positionTel2","_rounds","_roundsMax","_markerX","_size","_forcedX","_texto","_mrkFinal","_mrkFinal2","_timeX","_eta","_countX","_pos","_ang"];

_groups = hcSelected player;
_unitsX = [];
{_group = _x;
{_unitsX pushBack _x} forEach units _group;
} forEach _groups;
typeAmmunition = nil;
_artyArray = [];
_artyRoundsArr = [];

_hasAmmo = 0;
_areReady = false;
_hasArty = false;
_areAlive = false;

{
_soldierX = _x;
_veh = vehicle _soldierX;
if ((_veh != _soldierX) and (not(_veh in _artyArray))) then
	{
	if (( "Artillery" in (getArray (configfile >> "CfgVehicles" >> typeOf _veh >> "availableForSupportTypes")))) then
		{
		_hasArty = true;
		if ((canFire _veh) and (alive _veh) and (isNil "typeAmmunition")) then
			{
			_areAlive = true;
			_nul = createDialog "mortar_type";
			waitUntil {!dialog or !(isNil "typeAmmunition")};
			if !(isNil "typeAmmunition") then
				{
				_typeAmmunition = typeAmmunition;
				//typeAmmunition = nil;
			//	};
			//if (! isNil "_typeAmmunition") then
				//{
				{
				if (_x select 0 == _typeAmmunition) then
					{
					_hasAmmo = _hasAmmo + 1;
					};
				} forEach magazinesAmmo _veh;
				};
			if (_hasAmmo > 0) then
				{
				if (unitReady _veh) then
					{
					_areReady = true;
					_artyArray pushBack _veh;
					_artyRoundsArr pushBack (((magazinesAmmo _veh) select 0)select 1);
					};
				};
			};
		};
	};
} forEach _unitsX;

if (!_hasArty) exitWith {hint "You must select an artillery group or it is a Mobile Mortar and it's moving"};
if (!_areAlive) exitWith {hint "All elements in this Batery cannot fire or are disabled"};
if ((_hasAmmo < 2) and (!_areReady)) exitWith {hint "The Battery has no ammo to fire. Reload it on HQ"};
if (!_areReady) exitWith {hint "Selected Battery is busy right now"};
if (_typeAmmunition == "not_supported") exitWith {hint "Your current modset doesent support this strike type"};
if (isNil "_typeAmmunition") exitWith {};

hcShowBar false;
hcShowBar true;

if (_typeAmmunition != "2Rnd_155mm_Mo_LG") then
	{
	closedialog 0;
	_nul = createDialog "strike_type";
	}
else
	{
	tipoArty = "NORMAL";
	};

waitUntil {!dialog or (!isNil "tipoArty")};

if (isNil "tipoArty") exitWith {};

_tipoArty = tipoArty;
tipoArty = nil;


positionTel = [];

hint "Select the position on map where to perform the Artillery strike";

if (!visibleMap) then {openMap true};
onMapSingleClick "positionTel = _pos;";

waitUntil {sleep 1; (count positionTel > 0) or (!visibleMap)};
onMapSingleClick "";

if (!visibleMap) exitWith {};

_positionTel = positionTel;

_artyArrayDef1 = [];
_artyRoundsArr1 = [];

for "_i" from 0 to (count _artyArray) - 1 do
	{
	_pieza = _artyArray select _i;
	_isInRange = _positionTel inRangeOfArtillery [[_pieza], ((getArtilleryAmmo [_pieza]) select 0)];
	if (_isInRange) then
		{
		_artyArrayDef1 pushBack _pieza;
		_artyRoundsArr1 pushBack (_artyRoundsArr select _i);
		};
	};

if (count _artyArrayDef1 == 0) exitWith {hint "The position you marked is out of bounds for that Battery"};

_mrkFinal = createMarkerLocal [format ["Arty%1", random 100], _positionTel];
_mrkFinal setMarkerShapeLocal "ICON";
_mrkFinal setMarkerTypeLocal "hd_destroy";
_mrkFinal setMarkerColorLocal "ColorRed";

if (_tipoArty == "BARRAGE") then
	{
	_mrkFinal setMarkerTextLocal "Atry Barrage Begin";
	positionTel = [];

	hint "Select the position to finish the barrage";

	if (!visibleMap) then {openMap true};
	onMapSingleClick "positionTel = _pos;";

	waitUntil {sleep 1; (count positionTel > 0) or (!visibleMap)};
	onMapSingleClick "";

	_positionTel2 = positionTel;
	};

if ((_tipoArty == "BARRAGE") and (isNil "_positionTel2")) exitWith {deleteMarkerLocal _mrkFinal};

if (_tipoArty != "BARRAGE") then
	{
	if (_typeAmmunition != "2Rnd_155mm_Mo_LG") then
		{
		closedialog 0;
		_nul = createDialog "rounds_number";
		}
	else
		{
		roundsX = 1;
		};
	waitUntil {!dialog or (!isNil "roundsX")};
	};

if ((isNil "roundsX") and (_tipoArty != "BARRAGE")) exitWith {deleteMarkerLocal _mrkFinal};

if (_tipoArty != "BARRAGE") then
	{
	_mrkFinal setMarkerTextLocal "Arty Strike";
	_rounds = roundsX;
	_roundsMax = _rounds;
	roundsX = nil;
	}
else
	{
	_rounds = round (_positionTel distance _positionTel2) / 10;
	_roundsMax = _rounds;
	};

_markerX = [markersX,_positionTel] call BIS_fnc_nearestPosition;
_size = [_markerX] call A3A_fnc_sizeMarker;
_forcedX = false;

if ((not(_markerX in forcedSpawn)) and (_positionTel distance (getMarkerPos _markerX) < _size) and ((spawner getVariable _markerX != 0))) then
	{
	_forcedX = true;
	forcedSpawn pushBack _markerX;
	publicVariable "forcedSpawn";
	};

_texto = format ["Requesting fire support on Grid %1. %2 Rounds", mapGridPosition _positionTel, round _rounds];
[theBoss,"sideChat",_texto] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];

if (_tipoArty == "BARRAGE") then
	{
	_mrkFinal2 = createMarkerLocal [format ["Arty%1", random 100], _positionTel2];
	_mrkFinal2 setMarkerShapeLocal "ICON";
	_mrkFinal2 setMarkerTypeLocal "hd_destroy";
	_mrkFinal2 setMarkerColorLocal "ColorRed";
	_mrkFinal2 setMarkerTextLocal "Arty Barrage End";
	_ang = [_positionTel,_positionTel2] call BIS_fnc_dirTo;
	sleep 5;
	_eta = (_artyArrayDef1 select 0) getArtilleryETA [_positionTel, ((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0)];
	_timeX = time + _eta;
	_texto = format ["Acknowledged. Fire mission is inbound. ETA %1 secs for the first impact",round _eta];
	[petros,"sideChat",_texto]remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
	[_timeX] spawn
		{
		private ["_timeX"];
		_timeX = _this select 0;
		waitUntil {sleep 1; time > _timeX};
		[petros,"sideChat","Splash. Out"] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
		};
	};

_pos = [_positionTel,random 10,random 360] call BIS_fnc_relPos;

for "_i" from 0 to (count _artyArrayDef1) - 1 do
	{
	if (_rounds > 0) then
		{
		_pieza = _artyArrayDef1 select _i;
		_countX = _artyRoundsArr1 select _i;
		//hint format ["roundsX que faltan: %1, roundsX que tiene %2",_rounds,_countX];
		if (_countX >= _rounds) then
			{
			if (_tipoArty != "BARRAGE") then
				{
				_pieza commandArtilleryFire [_pos,_typeAmmunition,_rounds];
				}
			else
				{
				for "_r" from 1 to _rounds do
					{
					_pieza commandArtilleryFire [_pos,_typeAmmunition,1];
					sleep 2;
					_pos = [_pos,10,_ang + 5 - (random 10)] call BIS_fnc_relPos;
					};
				};
			_rounds = 0;
			}
		else
			{
			if (_tipoArty != "BARRAGE") then
				{
				_pieza commandArtilleryFire [[_pos,random 10,random 360] call BIS_fnc_relPos,_typeAmmunition,_countX];
				}
			else
				{
				for "_r" from 1 to _countX do
					{
					_pieza commandArtilleryFire [_pos,_typeAmmunition,1];
					sleep 2;
					_pos = [_pos,10,_ang + 5 - (random 10)] call BIS_fnc_relPos;
					};
				};
			_rounds = _rounds - _countX;
			};
		};
	};

if (_tipoArty != "BARRAGE") then
	{
	sleep 5;
	_eta = (_artyArrayDef1 select 0) getArtilleryETA [_positionTel, ((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0)];
	_timeX = time + _eta - 5;
	if (isNil "_timeX") exitWith {diag_log format ["Antistasi: Error en artySupport.sqf. Params: %1,%2,%3,%4",_artyArrayDef1 select 0,_positionTel,((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0),(_artyArrayDef1 select 0) getArtilleryETA [_positionTel, ((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0)]]};
	_texto = format ["Acknowledged. Fire mission is inbound. %2 Rounds fired. ETA %1 secs",round _eta,_roundsMax - _rounds];
	[petros,"sideChat",_texto] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
	};

if (_tipoArty != "BARRAGE") then
	{
	waitUntil {sleep 1; time > _timeX};
	[petros,"sideChat","Splash. Out"] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
	};
sleep 10;
deleteMarkerLocal _mrkFinal;
if (_tipoArty == "BARRAGE") then {deleteMarkerLocal _mrkFinal2};

if (_forcedX) then
	{
	sleep 20;
	if (_markerX in forcedSpawn) then
		{
		forcedSpawn = forcedSpawn - [_markerX];
		publicVariable "forcedSpawn";
		};
	};
