print_leaders() {
	if (topPoints > 0) {
		if (GetArraySize(winners) == 1) {
			Client_PrintToChatAll(false, "[ST] \x04%s is leading with %i %s!", GetName(GetArrayCell(winners, 0)), topPoints, plural_points(topPoints));
		} else if (GetArraySize(winners) > 1) {
			Client_PrintToChatAll(false, "[ST] \x04%s are leading with %i %s!",
				format_tie_message(), topPoints, plural_points(topPoints));
		}
	} else {
		Client_PrintToChatAll(false, "[ST] \x04No one has scored any points yet.");
	}
}

print_winners() {
	if (topPoints > 0) {
		if (GetArraySize(winners) == 1) {
			Client_PrintToChatAll(false, "[ST] \x04%s won with %i %s!",
				GetName(GetArrayCell(winners, 0)), topPoints, plural_points(topPoints));
		} else if (GetArraySize(winners) > 1) {
			Client_PrintToChatAll(false, "[ST] \x04%s won with %i %s",
				format_tie_message(), topPoints, plural_points(topPoints));
		}
	} else {
		Client_PrintToChatAll(false, "[ST] \x04No one won.");
	}
}

String:format_tie_message() {
	decl String:str[255];
	if (GetArraySize(winners) == 1) {
		Format(str, sizeof(str), "%s", GetName(GetArrayCell(winners, 0)));
	} else if (GetArraySize(winners) == 2) {
		Format(str, sizeof(str), "%s and %s", GetName(GetArrayCell(winners, 0)), GetName(GetArrayCell(winners, 1)));
	} else {
		Format(str, sizeof(str), "%s, %s", GetName(GetArrayCell(winners, 0)), GetName(GetArrayCell(winners, 1)));
		for (new i = 2; i < GetArraySize(winners)-1; i++) {
			Format(str, sizeof(str), "%s, %s", str, GetName(GetArrayCell(winners, i)));
		}
		Format(str, sizeof(str), "%s, and %s", str, GetName(GetArrayCell(winners, GetArraySize(winners)-1)));
	}
	return str;
}
