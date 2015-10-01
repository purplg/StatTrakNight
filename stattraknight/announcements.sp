print_leaders() {
	if (topPoints > 0) {
		if (GetArraySize(winners) == 1) {
			Client_PrintToChatAll(false, "[ST] %s%s\x01 is leading with \x04[%i point%s]",
				Chat_GetPlayerColor(GetArrayCell(winners, 0)),
				GetName(GetArrayCell(winners, 0)),
				topPoints,
				plural(topPoints));
		} else if (GetArraySize(winners) > 1) {
			Client_PrintToChatAll(false, "[ST] %s\x01 are leading with \x04[%i point%s]",
				format_tie_message(),
				topPoints,
				plural(topPoints));
		}
	} else {
		Client_PrintToChatAll(false, "[ST] No one has scored any points yet.");
	}
}

print_winners() {
	if (topPoints > 0) {
		if (GetArraySize(winners) == 1) {
			Client_PrintToChatAll(false, "[ST] \x04%s won with %i point%s",
				GetName(GetArrayCell(winners, 0)), topPoints, plural(topPoints));
		} else if (GetArraySize(winners) > 1) {
			Client_PrintToChatAll(false, "[ST] \x04%s won with %i point%s",
				format_tie_message(), topPoints, plural(topPoints));
		}
	} else {
		Client_PrintToChatAll(false, "[ST] \x04No one won.");
	}
}

String:format_tie_message() {
	decl String:str[255];
	if (GetArraySize(winners) == 1) {
		Format(str, sizeof(str), "%s%s\x01",
		Chat_GetPlayerColor(GetArrayCell(winners, 0)), GetName(GetArrayCell(winners, 0)));
	} else if (GetArraySize(winners) == 2) {
		Format(str, sizeof(str), "%s%s\x01 and %s%s\x01",
			Chat_GetPlayerColor(GetArrayCell(winners, 0)), GetName(GetArrayCell(winners, 0)),
			Chat_GetPlayerColor(GetArrayCell(winners, 1)), GetName(GetArrayCell(winners, 1)));
	} else {
		Format(str, sizeof(str), "%s%s\x01, %s%s\x01",
			Chat_GetPlayerColor(GetArrayCell(winners, 0)), GetName(GetArrayCell(winners, 0)),
			Chat_GetPlayerColor(GetArrayCell(winners, 1)), GetName(GetArrayCell(winners, 1)));
		for (new i = 2; i < GetArraySize(winners)-1; i++) {
			Format(str, sizeof(str), "%s, %s%s\x01",
				str, Chat_GetPlayerColor(GetArrayCell(winners, i)), GetName(GetArrayCell(winners, i)));
		}
		Format(str, sizeof(str), "%s, and %s%s\x01",
		str,
		Chat_GetPlayerColor(GetArrayCell(winners, GetArraySize(winners)-1)),
		GetName(GetArrayCell(winners, GetArraySize(winners)-1)));
	}
	return str;
}
