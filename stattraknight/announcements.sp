print_leaders(winners[], num_winners, points) {
	if (points > 0) {
		if (num_winners == 1) {
			Client_PrintToChatAll(false, "[ST] \x04%s is leading with %i %s!", GetName(winners[0]), points, plural_points(points));
		} else if (num_winners > 1) {
			Client_PrintToChatAll(false, "[ST] \x04%s are leading with %i %s!",
				format_tie_message(winners, num_winners), points, plural_points(points));
		}
	} else {
		Client_PrintToChatAll(false, "[ST] \x04No one has scored any points yet.");
	}
}

print_winners(winners[], num_winners, points) {
	if (points > 0) {
		if (num_winners == 1) {
			Client_PrintToChatAll(false, "[ST] \x04%s won with %i %s!",
				GetName(winners[0]), points, plural_points(points));
		} else if (num_winners > 1) {
			Client_PrintToChatAll(false, "[ST] \x04%s won with %i %s",
				format_tie_message(winners, num_winners), points, plural_points(points));
		}
	} else {
		Client_PrintToChatAll(false, "[ST] \x04No one won.");
	}
}

String:format_tie_message(winners[], size) {
	decl String:str[255];
	if (size == 1) {
		Format(str, sizeof(str), "%s", GetName(winners[0]));
	} else if (size == 2) {
		Format(str, sizeof(str), "%s and %s", GetName(winners[0]), GetName(winners[1]));
	} else {
		Format(str, sizeof(str), "%s, %s", GetName(winners[0]), GetName(winners[1]));
		for (new i = 2; i < size-1; i++) {
			Format(str, sizeof(str), "%s, %s", str, GetName(winners[i]));
		}
		Format(str, sizeof(str), "%s, and %s", str, GetName(winners[size-1]));
	}
	return str;
}
