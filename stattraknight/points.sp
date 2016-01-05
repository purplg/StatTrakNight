ArrayList winners;
int topPoints;

int getPoints(int client) {
    char uid[32];
    GetUId(client, uid, sizeof(uid));
    int player_index = scoreboard_players.FindString(uid);
    if (player_index == -1) {
	return -1;
    } else {
	return scoreboard_points.Get(player_index);
    }
}

int addPoint(int client) {
    char uid[32];
    GetUId(client, uid, sizeof(uid));

    int points = 1;
    int player_index = scoreboard_players.FindString(uid);
    if (player_index == -1) {
	scoreboard_players.PushString(uid);
	scoreboard_points.Push(1);
    } else {
	points = scoreboard_points.Get(player_index)+1;
	scoreboard_points.Set(player_index, points);

	// Sort
	int swap_index = player_index;
	while (swap_index > 0 && points > scoreboard_points.Get(swap_index-1)) {
	    swap_index--;
	}
	scoreboard_players.SwapAt(player_index, swap_index);
	scoreboard_points.SwapAt(player_index, swap_index);
    }

    Sounds_PlayKill(client);
    return points;
}

void update_winners() {
    int size = Client_GetCount();
    int[] clients = new int[size];
    Client_Get(clients, CLIENTFILTER_INGAME);

    ClearArray(winners);
    topPoints = 0;
    for (int i; i < size; i++) {
	if (clients[i] != 0) {
	    int points = getPoints(clients[i]);
	    if (points == 0) continue;

	    if (points > topPoints) {
		ClearArray(winners);
		PushArrayCell(winners, clients[i]);
		topPoints = points;
	    } else if (points == topPoints) {
		PushArrayCell(winners, clients[i]);
	    }
	}
    }
}

void GetUId(client, char[] buffer, int len) {
    if (IsFakeClient(client)) {
	GetClientName(client, buffer, len);
    } else {
	GetClientAuthId(client, AuthId_Steam2, buffer, len);	
    }
}
