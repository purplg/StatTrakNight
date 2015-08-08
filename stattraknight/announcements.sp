print_leaders(t_winners[], t_num_winners, t_points, ct_winners[], ct_num_winners, ct_points) {
	if (t_points > 0) {
		if (t_num_winners == 1) {
			Client_PrintToChatAll(false, "[ST] \x09%s is leading the Ts with %i %s!", GetName(t_winners[0]), t_points, plural_points(t_points));
		} else if (t_num_winners > 1) {
			Client_PrintToChatAll(false, "[ST] \x09%s are leading with %i %s!",
				format_tie_message(t_winners, t_num_winners), t_points, plural_points(t_points));
		}
	} else {
		Client_PrintToChatAll(false, "[ST] \x09No one on Terrorists has scored any points yet.");
	}
	if (ct_points > 0) {
		if (ct_num_winners == 1) {
			Client_PrintToChatAll(false, "[ST] \x0D%s is leading the CTs with %i %s!",
				GetName(ct_winners[0]), ct_points, plural_points(ct_points));
		} else if (ct_num_winners > 1) {
			Client_PrintToChatAll(false, "[ST] \x0D%s are leading with %i %s",
				format_tie_message(ct_winners, ct_num_winners), ct_points, plural_points(ct_points));
		}
	} else {
		Client_PrintToChatAll(false, "[ST] \x0DNo one on CT has scored any points yet.");
	}
}

print_winners(t_winners[], t_num_winners, t_points, ct_winners[], ct_num_winners, ct_points) {
	if (t_points > 0) {
		if (t_num_winners == 1) {
			Client_PrintToChatAll(false, "[ST] \x09%s won with %i %s!",
				GetName(t_winners[0]), t_points, plural_points(t_points));
		} else if (t_num_winners > 1) {
			Client_PrintToChatAll(false, "[ST] \x09%s won with %i %s",
				format_tie_message(t_winners, t_num_winners), t_points, plural_points(t_points));
		}
	} else {
		Client_PrintToChatAll(false, "[ST] \x09No one won on T");
	}
	if (ct_points > 0) {
		if (ct_num_winners == 1) {
			Client_PrintToChatAll(false, "[ST] \x0D%s won with %i %s!",
				GetName(ct_winners[0]), ct_points, plural_points(ct_points));
		} else if (ct_num_winners > 1) {
			Client_PrintToChatAll(false, "[ST] \x0D%s won with %i %s!",
				format_tie_message(ct_winners, ct_num_winners), ct_points, plural_points(ct_points));
		}
	} else {
		Client_PrintToChatAll(false, "[ST] \x0DNo one won on CT.");
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
