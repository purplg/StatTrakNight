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
	new String:name[16];
	GetClientName(client, name, 16)
	return name;
}

String:plural_points(num) {
	new String:str[6] = "point";
	if (num > 1) {
		str = "points";
	}
	return str;
}
