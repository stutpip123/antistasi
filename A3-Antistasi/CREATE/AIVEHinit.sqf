private ["_veh","_tipo"];

_veh = _this select 0;
if (isNil "_veh") exitWith {};
if ((_veh isKindOf "FlagCarrier") or (_veh isKindOf "Building") or (_veh isKindOf "ReammoBox_F")) exitWith {};
//if (_veh isKindOf "ReammoBox_F") exitWith {[_veh] call A3A_fnc_NATOcrate};

_tipo = typeOf _veh;

if ((_tipo in vehNormal) or (_tipo in vehAttack) or (_tipo in vehBoats)) then
	{
	_veh addEventHandler ["Killed",
		{
		private _veh = _this select 0;
		(typeOf _veh) call A3A_fnc_removeVehFromPool;
		_veh removeAllEventHandlers "HandleDamage";
		}];
	if !(_tipo in vehAttack) then
		{
		if (_tipo in vehAmmoTrucks) then
			{
			if (_veh distance getMarkerPos respawnTeamPlayer > 50) then {if (_tipo == vehNatoAmmoTruck) then {_nul = [_veh] call A3A_fnc_NATOcrate} else {_nul = [_veh] call A3A_fnc_CSATcrate}};
			};
		if (_veh isKindOf "Car") then
			{
			_veh addEventHandler ["HandleDamage",{if (((_this select 1) find "wheel" != -1) and ((_this select 4=="") or (side (_this select 3) != teamPlayer)) and (!isPlayer driver (_this select 0))) then {0} else {(_this select 2)}}];
			if ({"SmokeLauncher" in (_veh weaponsTurret _x)} count (allTurrets _veh) > 0) then
				{
				_veh setVariable ["within",true];
				_veh addEventHandler ["GetOut", {private ["_veh"]; _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {if (_veh getVariable "within") then {_veh setVariable ["within",false]; [_veh] call A3A_fnc_smokeCoverAuto}}}];
				_veh addEventHandler ["GetIn", {private ["_veh"]; _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {_veh setVariable ["within",true]}}];
				};
			};
		}
	else
		{
		if (_tipo in vehAPCs) then
			{
			_veh addEventHandler ["killed",
				{
				private ["_veh","_tipo"];
				_veh = _this select 0;
				_tipo = typeOf _veh;
				if (side (_this select 1) == teamPlayer) then
					{
					if (_tipo in vehNATOAPC) then {[-2,2,position (_veh)] remoteExec ["A3A_fnc_citySupportChange",2]};
					};
				}];
			_veh addEventHandler ["HandleDamage",{private ["_veh"]; _veh = _this select 0; if (!canFire _veh) then {[_veh] call A3A_fnc_smokeCoverAuto; _veh removeEventHandler ["HandleDamage",_thisEventHandler]};if (((_this select 1) find "wheel" != -1) and (_this select 4=="") and (!isPlayer driver (_veh))) then {0;} else {(_this select 2);}}];
			_veh setVariable ["within",true];
			_veh addEventHandler ["GetOut", {private ["_veh"];  _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {if (_veh getVariable "within") then {_veh setVariable ["within",false];[_veh] call A3A_fnc_smokeCoverAuto}}}];
			_veh addEventHandler ["GetIn", {private ["_veh"];_veh = _this select 0; if (side (_this select 2) != teamPlayer) then {_veh setVariable ["within",true]}}];
			}
		else
			{
			if (_tipo in vehTanks) then
				{
				_veh addEventHandler ["killed",
					{
					private ["_veh","_tipo"];
					_veh = _this select 0;
					_tipo = typeOf _veh;
					if (side (_this select 1) == teamPlayer) then
						{
						if (_tipo == vehNATOTank) then {[-5,5,position (_veh)] remoteExec ["A3A_fnc_citySupportChange",2]};
						};
					}];
				_veh addEventHandler ["HandleDamage",{private ["_veh"]; _veh = _this select 0; if (!canFire _veh) then {[_veh] call A3A_fnc_smokeCoverAuto;  _veh removeEventHandler ["HandleDamage",_thisEventHandler]}}];
				}
			else
				{
				_veh addEventHandler ["HandleDamage",{if (((_this select 1) find "wheel" != -1) and ((_this select 4=="") or (side (_this select 3) != teamPlayer)) and (!isPlayer driver (_this select 0))) then {0} else {(_this select 2)}}];
				};
			};
		};
	}
else
	{
	if (_tipo in vehPlanes) then
		{
		_veh addEventHandler ["killed",
			{
			private ["_veh","_tipo"];
			_veh = _this select 0;
			(typeOf _veh) call A3A_fnc_removeVehFromPool;
			}];
		_veh addEventHandler ["GetIn",
			{
			_positionX = _this select 1;
			if (_positionX == "driver") then
				{
				_unit = _this select 2;
				if ((!isPlayer _unit) and (_unit getVariable ["spawner",false]) and (side group _unit == teamPlayer)) then
					{
					moveOut _unit;
					hint "Only Humans can pilot an air vehicle";
					};
				};
			}];
		if (_veh isKindOf "Helicopter") then
			{
			if (_tipo in vehTransportAir) then
				{
				_veh setVariable ["within",true];
				_veh addEventHandler ["GetOut", {private ["_veh"];_veh = _this select 0; if ((isTouchingGround _veh) and (isEngineOn _veh)) then {if (side (_this select 2) != teamPlayer) then {if (_veh getVariable "within") then {_veh setVariable ["within",false]; [_veh] call A3A_fnc_smokeCoverAuto}}}}];
				_veh addEventHandler ["GetIn", {private ["_veh"];_veh = _this select 0; if (side (_this select 2) != teamPlayer) then {_veh setVariable ["within",true]}}];
				}
			else
				{
				_veh addEventHandler ["killed",
					{
					private ["_veh","_tipo"];
					_veh = _this select 0;
					_tipo = typeOf _veh;
					if (side (_this select 1) == teamPlayer) then
						{
						if (_tipo in vehNATOAttackHelis) then {[-5,5,position (_veh)] remoteExec ["A3A_fnc_citySupportChange",2]};
						};
					}];
				};
			};
		if (_veh isKindOf "Plane") then
			{
			_veh addEventHandler ["killed",
				{
				private ["_veh","_tipo"];
				_veh = _this select 0;
				_tipo = typeOf _veh;
				if (side (_this select 1) == teamPlayer) then
					{
					if ((_tipo == vehNATOPlane) or (_tipo == vehNATOPlaneAA)) then {[-8,8,position (_veh)] remoteExec ["A3A_fnc_citySupportChange",2]};
					};
				}];
			};
		}
	else
		{
		if (_veh isKindOf "StaticWeapon") then
			{
			_veh setCenterOfMass [(getCenterOfMass _veh) vectorAdd [0, 0, -1], 0];
			if ((not (_veh in staticsToSave)) and (side gunner _veh != teamPlayer)) then
				{
				if (activeGREF and ((_tipo == staticATteamPlayer) or (_tipo == staticAAteamPlayer))) then {[_veh,"moveS"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_veh]} else {[_veh,"steal"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_veh]};
				};
			if (_tipo == SDKMortar) then
				{
				if (!isNull gunner _veh) then
					{
					[_veh,"steal"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_veh];
					};
				_veh addEventHandler ["Fired",
					{
					_mortarX = _this select 0;
					_dataX = _mortarX getVariable ["detection",[position _mortarX,0]];
					_positionX = position _mortarX;
					_chance = _dataX select 1;
					if ((_positionX distance (_dataX select 0)) < 300) then
						{
						_chance = _chance + 2;
						}
					else
						{
						_chance = 0;
						};
					if (random 100 < _chance) then
						{
						{if ((side _x == Occupants) or (side _x == )) then {_x reveal [_mortarX,4]}} forEach allUnits;
						if (_mortarX distance posHQ < 300) then
							{
							if (!(["DEF_HQ"] call BIS_fnc_taskExists)) then
								{
								_lider = leader (gunner _mortarX);
								if (!isPlayer _lider) then
									{
									[[],"A3A_fnc_attackHQ"] remoteExec ["A3A_fnc_scheduler",2];
									}
								else
									{
									if ([_lider] call A3A_fnc_isMember) then {[[],"A3A_fnc_attackHQ"] remoteExec ["A3A_fnc_scheduler",2]};
									};
								};
							}
						else
							{
							_bases = airportsX select {(getMarkerPos _x distance _mortarX < distanceForAirAttack) and ([_x,true] call A3A_fnc_airportCanAttack) and (lados getVariable [_x,sideUnknown] != teamPlayer)};
							if (count _bases > 0) then
								{
								_base = [_bases,_positionX] call BIS_fnc_nearestPosition;
								_lado = lados getVariable [_base,sideUnknown];
								[[getPosASL _mortarX,_lado,"Normal",false],"A3A_fnc_patrolCA"] remoteExec ["A3A_fnc_scheduler",2];
								};
							};
						};
					_mortarX setVariable ["detection",[_positionX,_chance]];
					}];
				}
			else
				{
				_veh addEventHandler ["killed",
					{
					private ["_veh","_tipo"];
					_veh = _this select 0;
					(typeOf _veh) call A3A_fnc_removeVehFromPool;
					}];
				};
			}
		else
			{
			if ((_tipo in vehAA) or (_tipo in vehMRLS)) then
				{
				_veh addEventHandler ["killed",
					{
					private ["_veh","_tipo"];
					_veh = _this select 0;
					_tipo = typeOf _veh;
					if (side (_this select 1) == teamPlayer) then
						{
						if (_tipo == vehNATOAA) then {[-5,5,position (_veh)] remoteExec ["A3A_fnc_citySupportChange",2]};
						};
					_tipo call A3A_fnc_removeVehFromPool;
					}];
				};
			};
		};
	};

[_veh] spawn A3A_fnc_cleanserVeh;

_veh addEventHandler ["Killed",{[_this select 0] spawn A3A_fnc_postmortem}];

if (not(_veh in staticsToSave)) then
	{
	if (((count crew _veh) > 0) and (not (_tipo in vehAA)) and (not (_tipo in vehMRLS) and !(_veh isKindOf "StaticWeapon"))) then
		{
		[_veh] spawn A3A_fnc_VEHdespawner
		}
	else
		{
		_veh addEventHandler ["GetIn",
			{
			_unit = _this select 2;
			if ((side _unit == teamPlayer) or (isPlayer _unit)) then {[_this select 0] spawn A3A_fnc_VEHdespawner};
			}
			];
		};
	if (_veh distance getMarkerPos respawnTeamPlayer <= 50) then
		{
		clearMagazineCargoGlobal _veh;
		clearWeaponCargoGlobal _veh;
		clearItemCargoGlobal _veh;
		clearBackpackCargoGlobal _veh;
		};
	};