public void MenuHandler(Handle menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
	char info[32];
	bool found = GetMenuItem(menu, param2, info, sizeof(info));
	Client_PrintToChatAll(false, "You selected item: %d (found? %d info: %s)", param2, found, info);
    } else if (action == MenuAction_Cancel) {
	Client_PrintToChatAll(false, "Client %d's menu was cancelled. Reason: %d", param1, param2);
    } else if (action == MenuAction_End) {
	CloseHandle(menu);
    }
}

void showScores(int client) {
    Handle menu = CreateMenu(MenuHandler);
    SetMenuTitle(menu, "StatTrak Scoreboard");
    AddMenuItem(menu, "", "Coming soon...");
    SetMenuExitButton(menu, true);
    DisplayMenu(menu, client, 20);
}
