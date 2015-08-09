Beacon(name) {
	InsertServerCommand("sm_beacon %s", GetName(name));
}

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
	return points;
}

char[] GetName(client) {
	new String:name[MAX_NAME_LENGTH];
	GetClientName(client, name, MAX_NAME_LENGTH);
	return name;
}

String:plural_points(num) {
	new String:str[6] = "points";
	if (num == 1) {
		str[5] = 0;
	}
	return str;
}

Client_Init(client) {
	if (Client_IsValid(client)) {
		if (GetClientCookieTime(client, cookie_points) < event_starttime) {
			SetClientCookie(client, cookie_points, "0");
		}
	}
}
