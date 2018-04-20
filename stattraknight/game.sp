/**
* Set a StatTrak Event to start next round or after [time] in seconds
*
* @param client	The client that called the event to start
* @param time	The amount of time to wait to restart game to start event. 0 = Next round
* @noreturn
*/
void Game_Start(int client, int time=0) {
	if (starting) {
		Reply(client, "Event already starting next round.");
	} else if (stopping) {
		stopping = false;
		PrintAll("Event set to continue.");
	} else if (running) {
		Reply(client, "Event already running.");
	} else {
		starting = true;
		if (time > 0) {
			PrintAll("Starting event in %i second%s.", time, Format_Plural(time));
			if (GameRules_GetProp("m_bWarmupPeriod")) {
				Game_WarmupRestart(time);
			} else {
				InsertServerCommand("mp_restartgame %i", time);
			}
		} else {
			Reply(client, "Starting event next round.");
		}
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
		Reply(client, "Event already stopping next round.");
    } else if (starting) {
		starting = false;
		PrintAll("Event cancelled for next round.");
    } else if (running) {
		stopping = true;
		if (time > 0) {
			PrintAll("Stopping event in %i second%s.", time, Format_Plural(time));
			if (GameRules_GetProp("m_bWarmupPeriod")) {
				Game_WarmupRestart(time);
			} else {
				InsertServerCommand("mp_restartgame %i", time);
			}
		} else {
			PrintAll("Event will end next round.");
		}
    } else {
		Reply(client, "There isn't an event running.");
    }
}

void Game_FullStop() {
    Print_Winners();
    Game_Reset();
}

void Game_Reset() {
    running = false;
    stopping = false;
    starting = false;
    scoreboard_players.Clear();
    scoreboard_points.Clear();
}

void Game_WarmupRestart(int time) {
    CreateTimer(float(time), Game_StopWarmup);
}

public Action Game_StopWarmup(Handle timer) {
    InsertServerCommand("mp_warmup_end");
}
