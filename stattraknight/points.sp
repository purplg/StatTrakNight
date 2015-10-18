ArrayList winners;
int topPoints;

int getPoints(int client) {
    char strBuffer[3];
    GetClientCookie(client, cookie_points, strBuffer, 3);
    return StringToInt(strBuffer);
}

int addPoint(int client) {
    char strBuffer[3];
    GetClientCookie(client, cookie_points, strBuffer, 3);
    int points = StringToInt(strBuffer) + 1;
    IntToString(points, strBuffer, 3);
    SetClientCookie(client, cookie_points, strBuffer);
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
