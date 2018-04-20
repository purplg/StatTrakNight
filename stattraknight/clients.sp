int Client_FindByUid(char[] uid) {
    int client = Client_FindBySteamId(uid);
    if (client == -1) {
	client = Client_FindByName(uid);
    }
    return client;
}

void Client_GetUId(client, char[] buffer, int len) {
    if (IsFakeClient(client)) {
	GetClientName(client, buffer, len);
    } else {
	GetClientAuthId(client, AuthId_Steam2, buffer, len);	
    }
}

char[] Client_GetName(int client) {
    char name[MAX_NAME_LENGTH];
    GetClientName(client, name, MAX_NAME_LENGTH);
    return name;
}

