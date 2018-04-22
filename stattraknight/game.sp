/**
* Set a StatTrak Event to start next round or after [time] in seconds
*
* @param client	The client that called the event to start
* @param time	The amount of time to wait to restart game to start event. 0 = Next round
* @noreturn
*/
void Game_Start(int client, int time=0) {
	if (starting) {
		if (time > 0) {
			Print_Starting(time);
			restartMatch(time);
		} else {
			Print_AlreadyStarting(client);
		}
	} else if (stopping) {
		stopping = false;
		Print_Continue();
	} else if (running) {
		Print_AlreadyRunning(client);
	} else {
		starting = true;
		Print_Starting(time);
		if (time > 0) {
			restartMatch(time);
		}
	}
}

void Game_NewRound() {
	Print_Beta();
	Print_Leaders();

	T_TARGET = BeaconRandom(T_TEAM);
	CT_TARGET = BeaconRandom(CT_TEAM);
	Print_Targets();

	Print_WeaponGroup();
}

void Game_Restart(int time=0) {
	starting = true;
	Print_Starting(time);
	if (time > 0) {
		restartMatch(time);
	} else {
		starting = true;
	}
}

/**
* Stop a StatTrak Event next round or after [time] in seconds
*
* @param client	The client that called the event to stop
* @param time	The amount of time to wait to restart game to stop event. 0 = Next round
* @noreturn
*/
void Game_Stop(client=0, time=0) {
	if (stopping) {
		Print_AlreadyStopping(client);
	} else if (starting) {
		starting = false;
		Print_Cancelled();
	} else if (running) {
		stopping = true;
		Print_Stopping(time);
		if (time > 0) {
			restartMatch(time);
		}
	} else {
		Print_NotRunning(client);
	}
}

void Game_FullStop() {
	if ( running ) {
		Print_Winners();
	}
	Game_Reset();
}

void Game_Reset() {
	running = false;
	stopping = false;
	starting = false;
	T_TARGET = 0;
	CT_TARGET = 0;
	scoreboard_players.Clear();
	scoreboard_points.Clear();
}

void Game_WarmupRestart(int time) {
	CreateTimer(float(time), Game_StopWarmup);
}

public Action Game_StopWarmup(Handle timer) {
	InsertServerCommand("mp_warmup_end");
}

void restartMatch(int time) {
	if (GameRules_GetProp("m_bWarmupPeriod")) {
		Game_WarmupRestart(time);
	} else {
		InsertServerCommand("mp_restartgame %i", time);
	}
}

