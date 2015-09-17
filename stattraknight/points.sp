new ArrayList:winners;
new topPoints;

int getPoints(client) {
		decl String:strBuffer[3];
		GetClientCookie(client, cookie_points, strBuffer, 3);
		return StringToInt(strBuffer);
}

int addPoint(client) {
	decl String:strBuffer[3];
	GetClientCookie(client, cookie_points, strBuffer, 3);
	new points = StringToInt(strBuffer) + 1;
	IntToString(points, strBuffer, 3);
	SetClientCookie(client, cookie_points, strBuffer);
	Sounds_PlayKill(client);
	return points;
}

update_winners() {
	new	size = Client_GetCount(),
		players[size];
	Client_Get(players, CLIENTFILTER_INGAME);

	ClearArray(winners);
	topPoints = 0;
	for (new i; i < size; i++) {
		if (players[i] != 0) {
			new points = getPoints(players[i]);
			if (points == 0) continue;

			if (points > topPoints) {
				ClearArray(winners);
				PushArrayCell(winners, players[i]);
				topPoints = points;
			} else if (points == topPoints) {
				PushArrayCell(winners, players[i]);
			}
		}
	}
}
