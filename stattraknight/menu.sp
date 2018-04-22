public int MenuHandler(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_End) {
		CloseHandle(menu);
	}

	if (action == MenuAction_Select) {
		char info[32];
		bool found = menu.GetItem(item, info, sizeof(info));
		if (found) {
			if (StrEqual(info, "scoreboard")) {
				Scoreboard_Show(client);
			} else if (StrEqual(info, "points")) {
				Print_Points(client);
			}
		}
	}
}

public Action Menu_Show(int client) {
	Menu menu = new Menu(MenuHandler);
	menu.ExitButton = true;
	menu.SetTitle("StatTrakNight");
	menu.AddItem("scoreboard", "Scoreboard");
	menu.AddItem("points", "Show my points");
	menu.Display(client, 20);
	return Plugin_Handled;
}
