int Points_Get(int client) {
	char uid[32];
	Client_GetUId(client, uid, sizeof(uid));
	int player_index = scoreboard_players.FindString(uid);
	if (player_index == -1) {
	return 0;
	} else {
	return scoreboard_points.Get(player_index);
	}
}

int Points_Add(int client) {
	char uid[32];
	Client_GetUId(client, uid, sizeof(uid));

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

	Sound_PlayKill(client);
	return points;
}

int Points_GetNumLeaders() {
	// Check if any winners
	if (scoreboard_points.Length == 0) {
	return 0;
	}

	// Count number of winners
	int points = scoreboard_points.Get(0);
	int numLeaders = 1;
	while (numLeaders < scoreboard_points.Length) {
	if (scoreboard_points.Get(numLeaders) < points) {
		break;
	}
	numLeaders++;
	}
	return numLeaders;
}
