public Action Command_stattrak(int client, int args) {
	if (GetCmdArgs() == 0) {
		//Scoreboard_Show(client); 
		Menu_Show(client);
		return Plugin_Handled;
	} else {
		char arg[32];
		GetCmdArg(1, arg, sizeof(arg));

		// st_start
		if (StrEqual(arg, "start", false)) {
			GetCmdArg(2, arg, sizeof(arg));
			Game_Start(client, StringToInt(arg));
			return Plugin_Handled;

		// st_stop
		} else if (StrEqual(arg, "stop", false)) {
			GetCmdArg(2, arg, sizeof(arg));
			Game_Stop(client, StringToInt(arg));
			return Plugin_Handled;

		// st_restart
		} else if (StrEqual(arg, "restart", false)) {
			GetCmdArg(2, arg, sizeof(arg));
			Game_Restart(StringToInt(arg));
			return Plugin_Handled;

		// st_points
		} else if (StrEqual(arg, "points", false)) {
			Print_Points(client);
			return Plugin_Handled;

		// st_optout
		} else if (StrEqual(arg, "optout", false)) {
			Print_NotImplemented(client);
			return Plugin_Handled;
			if (Client_IsValid(client)) {
				if (optout_players.FindValue(client) == -1) {
					optout_players.Push(client);
					// TODO Detect last player to optout and stop game
					Print_OptOut(client);
				} else {
					Print_AlreadyOptOut(client);
				}
			}
			return Plugin_Handled;

		// st_optin
		} else if (StrEqual(arg, "optin", false)) {
			Print_NotImplemented(client);
			return Plugin_Handled;
			if (Client_IsValid(client)) {
				int index = optout_players.FindValue(client);
				if (index > -1) {
					optout_players.Erase(index);
					Print_OptIn(client);
				} else {
					Print_AlreadyOptIn(client);
				}
			}
			return Plugin_Handled;

		// st_status
		} else if (StrEqual(arg, "status", false)) {
			if (running) {
				Print_NotImplemented(client);
				return Plugin_Handled;
				int index = optout_players.FindValue(client);
				if (index > -1) {
					Print_OptOut(client);
				} else {
					Print_OptIn(client);
				}
			} else {
				Print_NotRunning(client);
			}
			return Plugin_Handled;
			

		// st_debug
		} else if (StrEqual(arg, "debug", false)) {
			GetCmdArg(2, arg, sizeof(arg));
			if (StrEqual(arg, "state", false)) {
				char buffer[256];
				Format(buffer, sizeof(buffer), "starting:%b, running:%b, stopping:%b", starting, running, stopping);
				PrintClient(client, buffer);
				Format(buffer, sizeof(buffer), "targetGroup:%s, weapon_rand:%i", weapon_targetGroup, weapon_rand);
				PrintClient(client, buffer);
			} else if (StrEqual(arg, "weapon", false)) {
				GetCmdArg(3, arg, sizeof(arg));
				if (Weapons_SelectGroup(arg)) {
					Print_WeaponGroup();
				} else {
					char buffer[256];
					Format(buffer, sizeof(buffer), "%s is not a valid weapon group", arg);
				}
			}
		}
	}
	return Plugin_Continue;
}
