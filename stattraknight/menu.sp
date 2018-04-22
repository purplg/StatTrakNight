public Action Menu_Show(int client) {
	Menu menu = new Menu(MenuHandler);
	menu.ExitButton = true;
	menu.SetTitle("StatTrakNight");
	menu.AddItem("scoreboard", "Scoreboard");
	menu.AddItem("points", "Show my points");
	menu.Display(client, 20);
	return Plugin_Handled;
}

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

public void OnAdminMenuReady(Handle aTopMenu) {
	TopMenu topmenu = TopMenu.FromHandle(aTopMenu);

	/* Block us from being called twice */
	if (topmenu == hTopMenu) {
		return;
	}
	
	/* Save the Handle */
	hTopMenu = topmenu;
	
	/* Find the "Player Commands" category */
	TopMenuObject player_commands = hTopMenu.FindCategory(ADMINMENU_SERVERCOMMANDS);

	if (player_commands != INVALID_TOPMENUOBJECT) {
		hTopMenu.AddItem("sm_st", AdminMenu, player_commands, "sm_st", ADMFLAG_SLAY);
	}
}

public void AdminMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength) {
	if (action == TopMenuAction_DisplayOption) {
		Format(buffer, maxlength, "%s", "StatTrak Night");
	} else if (action == TopMenuAction_SelectOption) {
		DisplayAdminMenu(param);
	}
}

void DisplayAdminMenu(int client) {
	Menu menu = new Menu(AdminMenuHandler);
	
	char title[100];
	Format(title, sizeof(title), "%s", "StatTrak Night");
	menu.SetTitle(title);
	menu.ExitBackButton = true;
	
	menu.AddItem("start", "Start");
	menu.AddItem("stop", "Stop");
	menu.AddItem("restart", "Restart");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int AdminMenuHandler(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_End) {
		delete menu;
	} else if (action == MenuAction_Cancel) {
		if (item == MenuCancel_ExitBack && hTopMenu) {
			hTopMenu.Display(client, TopMenuPosition_LastCategory);
		}
	} else if (action == MenuAction_Select) {
		char info[32];
		bool found = menu.GetItem(item, info, sizeof(info));
		if (found) {
			if (StrEqual(info, "start")) {
				DisplayStartMenu(client);
			} else if (StrEqual(info, "stop")) {
				DisplayStopMenu(client);
			} else if (StrEqual(info, "restart")) {
				DisplayRestartMenu(client);
			}
		}
	}
}

// START
void DisplayStartMenu(int client) {
	Menu menu = new Menu(StartMenuHandler);
	
	char title[100];
	Format(title, sizeof(title), "%s", "Start when?");
	menu.SetTitle(title);
	menu.ExitBackButton = true;
	
	menu.AddItem("now", "Now");
	menu.AddItem("5", "5 seconds");
	menu.AddItem("10", "10 seconds");
	menu.AddItem("30", "30 seconds");
	menu.AddItem("60", "60 seconds");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int StartMenuHandler(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_End) {
		delete menu;
	} else if (action == MenuAction_Cancel) {
		if (item == MenuCancel_ExitBack && hTopMenu) {
			hTopMenu.Display(client, TopMenuPosition_LastCategory);
		}
	} else if (action == MenuAction_Select) {
		char info[32];
		bool found = menu.GetItem(item, info, sizeof(info));
		if (found) {
			if (StrEqual(info, "now")) {
				Game_Start(client, 1);
			} else if (StrEqual(info, "5")) {
				Game_Start(client, 5);
			} else if (StrEqual(info, "10")) {
				Game_Start(client, 10);
			} else if (StrEqual(info, "30")) {
				Game_Start(client, 30);
			} else if (StrEqual(info, "60")) {
				Game_Start(client, 60);
			}
		}
	}
}

// STOP
void DisplayStopMenu(int client) {
	Menu menu = new Menu(StopMenuHandler);
	
	char title[100];
	Format(title, sizeof(title), "%s", "Stop when?");
	menu.SetTitle(title);
	menu.ExitBackButton = true;
	
	menu.AddItem("now", "Now");
	menu.AddItem("5", "5 seconds");
	menu.AddItem("10", "10 seconds");
	menu.AddItem("30", "30 seconds");
	menu.AddItem("60", "60 seconds");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int StopMenuHandler(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_End) {
		delete menu;
	} else if (action == MenuAction_Cancel) {
		if (item == MenuCancel_ExitBack && hTopMenu) {
			hTopMenu.Display(client, TopMenuPosition_LastCategory);
		}
	} else if (action == MenuAction_Select) {
		char info[32];
		bool found = menu.GetItem(item, info, sizeof(info));
		if (found) {
			if (StrEqual(info, "now")) {
				Game_Stop(client, 1);
			} else if (StrEqual(info, "5")) {
				Game_Stop(client, 5);
			} else if (StrEqual(info, "10")) {
				Game_Stop(client, 10);
			} else if (StrEqual(info, "30")) {
				Game_Stop(client, 30);
			} else if (StrEqual(info, "60")) {
				Game_Stop(client, 60);
			}
		}
	}
}

// RESTART
void DisplayRestartMenu(int client) {
	Menu menu = new Menu(RestartMenuHandler);
	
	char title[100];
	Format(title, sizeof(title), "%s", "Restart when?");
	menu.SetTitle(title);
	menu.ExitBackButton = true;
	
	menu.AddItem("now", "Now");
	menu.AddItem("5", "5 seconds");
	menu.AddItem("10", "10 seconds");
	menu.AddItem("30", "30 seconds");
	menu.AddItem("60", "60 seconds");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int RestartMenuHandler(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_End) {
		delete menu;
	} else if (action == MenuAction_Cancel) {
		if (item == MenuCancel_ExitBack && hTopMenu) {
			hTopMenu.Display(client, TopMenuPosition_LastCategory);
		}
	} else if (action == MenuAction_Select) {
		char info[32];
		bool found = menu.GetItem(item, info, sizeof(info));
		if (found) {
			if (StrEqual(info, "now")) {
				Game_Restart(1);
			} else if (StrEqual(info, "5")) {
				Game_Restart(5);
			} else if (StrEqual(info, "10")) {
				Game_Restart(10);
			} else if (StrEqual(info, "30")) {
				Game_Restart(30);
			} else if (StrEqual(info, "60")) {
				Game_Restart(60);
			}
		}
	}
}
