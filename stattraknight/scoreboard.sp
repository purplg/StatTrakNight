public int ScoreboardMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

Action Scoreboard_Show(int client) {
	Menu menu = new Menu(ScoreboardMenuHandler);
	menu.ExitButton = false;
	menu.SetTitle("StatTrakNight Scoreboard");
	for (int i = 0; i < scoreboard_players.Length; i++) {
		char uid[32];
		scoreboard_players.GetString(i, uid, sizeof(uid));

		int c = Client_FindBySteamId(uid);
		if (c == -1) {
			c = Client_FindByName(uid, false, true);
		}

		char name[MAX_NAME_LENGTH];
		GetClientName(c, name, sizeof(name));

		int player_index = scoreboard_players.FindString(uid);

		int points = scoreboard_points.Get(player_index);

		char entry[64];
		Format(entry, sizeof(entry), "%s [%i points]", name, points);
		menu.AddItem("", entry);
	}
	if (scoreboard_players.Length == 0) {
		menu.AddItem("", "No one has any points");
	} else if (scoreboard_players.Length < 10) {
		menu.Pagination = false;
	}
	menu.Display(client, 20);

	return Plugin_Handled;
}
