Handle HitTimers[MAXPLAYERS+1];
int HitPoints[MAXPLAYERS+1];
ArrayList winners;
int topPoints;

int getPoints(int client) {
    char strBuffer[5];
    GetClientCookie(client, cookie_points, strBuffer, sizeof(strBuffer));
    return StringToInt(strBuffer);
}

void setPoints(int client, int points) {
    char strBuffer[5];
    IntToString(points, strBuffer, sizeof(strBuffer));
    SetClientCookie(client, cookie_points, strBuffer);
}

int addPoints(int client, int points) {
    if (points > 100) points = 100;
    setPoints(client, getPoints(client) + points);
    Sounds_PlayKill(client);

    HitPoints[client] += points;
    if (HitTimers[client] != null) {
	KillTimer(HitTimers[client]);	
	HitTimers[client] = INVALID_HANDLE;
    }
    HitTimers[client] = CreateTimer(5.0, HitTimer_Tick, client);
    char hint[255];
    Format(hint, sizeof(hint), "+%i point%s",
	HitPoints[client], plural(HitPoints[client]));
    Client_PrintHintText(client, hint);
    return HitPoints[client];
}

public Action HitTimer_Tick(Handle timer, client) {
    HitTimers[client] = null;
    HitPoints[client] = 0;
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
