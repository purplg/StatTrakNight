char prefix[] = "[ \x03StatTrakNight\x01 ]";

void Print_AlreadyStarting(int client) {
	PrintClient(client, "Event already starting next round.");
}

void Print_Continue() {
	PrintAll("Event set to continue.");
}

void Print_AlreadyRunning(int client) {
	PrintClient(client, "Event already running.");
}

void Print_AlreadyStopping(int client) {
	PrintClient(client, "Event already stopping next round.");
}

void Print_Starting(int time=0) {
	if (time > 0) {
		if (running) {
			PrintAll("Restarting event in %i second%s.", time, Format_Plural(time));
		} else {
			PrintAll("Starting event in %i second%s.", time, Format_Plural(time));
		}
	} else {
		if (running) {
			PrintAll("Restarting event next round.");
		} else {
			PrintAll("Starting event next round.");
		}
	}
}

void Print_NotRunning(int client) {
	PrintClient(client, "There isn't an event running.");
}

void Print_Beta() {
	PrintAll("\x04This is a beta version of the StatTrakNight plugin. Expect bugs.");
}

void Print_Targets() {
	PrintAll("%s%s\x01 and %s%s\x01 are the targets.",
		Format_GetPlayerColor(CT_TARGET), Client_GetName(CT_TARGET),
		Format_GetPlayerColor(T_TARGET), Client_GetName(T_TARGET));
}

void Print_NewTarget(int newTarget) {
	PrintAll("%s%s\x01 is the new target.", Format_GetPlayerColor(newTarget), Client_GetName(newTarget));
}

void Print_WeaponGroup() {
	PrintAll("Kill them with \x04%s\x01.", weapon_targetGroup);
}

void Print_WrongWeapon(int victim) {
	PrintAll("%s%s\x01 was killed with the wrong weapon.",
		Format_GetPlayerColor(victim),
		Client_GetName(victim)
	);
}

void Print_TargetKilled(int attacker, int victim, int points) {
	PrintAll("%s%s\x01 was killed by %s%s\x01 \x04[%i point%s]",
		Format_GetPlayerColor(victim),
		Client_GetName(victim),
		Format_GetPlayerColor(attacker),
		Client_GetName(attacker),
		points,
		Format_Plural(points)
	);
}

void Print_Points(int client) {
	int points = Points_Get(client);
	PrintClient(client, "You have %i point%s.",
		points,
		Format_Plural(points)
	);
}

void Print_OptIn(int client) {
	PrintClient(client, "You are opted in.");
}

void Print_AlreadyOptIn(int client) {
	PrintClient(client, "You are already opted in.");
}

void Print_OptOut(int client) {
	PrintClient(client, "You are opted out");
}

void Print_AlreadyOptOut(int client) {
	PrintClient(client, "You are already opted out");
}

void Print_Cancelled() {
	PrintAll("Event cancelled for next round.");
}

void Print_Stopping(int time=0) {
	if (time > 0) {
		PrintAll("Stopping event in %i second%s.", time, Format_Plural(time));
	} else {
	}
}

void Print_Leaders() {
	int numLeaders = Points_GetNumLeaders();

	if (numLeaders == 0) {
	PrintAll("No one has scored any points yet.");
	} else if (numLeaders == 1) {
		int points = scoreboard_points.Get(0);
		PrintAll("%s is leading with %i point%s",
			Format_Tie(numLeaders),
			points,
			Format_Plural(points)
		);
	} else {
		int points = scoreboard_points.Get(0);
		PrintAll("%s are leading with %i point%s",
			Format_Tie(numLeaders),
			points,
			Format_Plural(points)
		);
	}
}

void Print_Winners() {
	int numWinners = Points_GetNumLeaders();

	if (numWinners == 0) {
		PrintAll("No one won.");
	} else {
		int points = scoreboard_points.Get(0);
		PrintAll("%s won with %i point%s",
			Format_Tie(numWinners),
			points,
			Format_Plural(points)
		);
	}
}

void PrintServer(const char[] msg, any:...) {
	char buffer[254];
	VFormat(buffer, sizeof(buffer), msg, 2);
	PrintToServer("%s %s", prefix, buffer);
}

void PrintClient(int client, const char[] msg, any:...) {
	char buffer[254];
	VFormat(buffer, sizeof(buffer), msg, 3);
	PrintToChat(client, "%s %s", prefix, buffer);
}

void PrintAll(const char[] msg, any:...) {
	char buffer[512];
	VFormat(buffer, sizeof(buffer), msg, 2);
	PrintToChatAll("%s %s", prefix, buffer);
	PrintToServer("%s %s", prefix, buffer);
}
