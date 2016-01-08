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
	    PrintAll("\x04Starting StatTrak event in %i second%s.", time, Format_Plural(time));
	    InsertServerCommand("mp_restartgame %i", time);
	    InsertServerCommand("mp_warmup_end");
	} else {
	    Client_Reply(client, "\x04StatTrak event already starting next round.");
	}
    } else if (stopping) {
	stopping = false;
	PrintAll("\x04StatTrak Night set to continue.");
    } else if (running) {
	Client_Reply(client, "\x04StatTrak event already running.");
    } else {
	starting = true;
	if (time > 0) {
	    PrintAll("\x04Starting StatTrak event in %i second%s.", time, Format_Plural(time));
	    InsertServerCommand("mp_restartgame %i", time);
	    InsertServerCommand("mp_warmup_end");
	} else {
	    Reply(client, "\x04Starting StatTrak event next round.");
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
	if (time > 0) {
	    PrintAll("\x04Stopping StatTrak event in %i seconds.", time);
	    InsertServerCommand("mp_restartgame %i", time);
	    InsertServerCommand("mp_warmup_end");
	} else {
	    Reply(client, "\x04StatTrak event already starting next round.");
	}
    } else if (starting) {
	starting = false;
	PrintAll("\x04StatTrak Event cancelled for next round.");
    } else if (running) {
	stopping = true;
	if (time > 0) {
	    PrintAll("\x04Stopping StatTrak event in %i seconds.", time);
	    InsertServerCommand("mp_restartgame %i", time);
	    InsertServerCommand("mp_warmup_end");
	} else {
	    PrintAll("\x04StatTrak Night will end next round.");
	}
    } else {
	Reply(client, "\x04There isn't a StatTrak Event running.");
    }
}

void Game_FullStop() {
    running = false;
    stopping = false;
    starting = false;
    Print_Winners();
    Game_Reset();
}

void Game_Reset() {
    scoreboard_players.Clear();
    scoreboard_points.Clear();
}

