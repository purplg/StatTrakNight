new String:youkillSound[PLATFORM_MAX_PATH];
new String:theyKillSound[PLATFORM_MAX_PATH];

Sounds_Load() {
	youkillSound = "ui/deathnotice.wav";
	theyKillSound = "ui/bonus_alert_end.wav";
	PrecacheSound(youkillSound, true);
	PrecacheSound(theyKillSound, true);
}

/**
 * Play the earned kill sound for the attacker and the lost kill round for
 * everyone else on the attackers team
 *
 * @param client	The attacker that got the kill
 * @noreturn
 */
Sounds_PlayKill(client) {
	new team = GetClientTeam(client);
	new flag;
	if (team == 2) { // T
		flag = CLIENTFILTER_TEAMONE;
	} else if (team == 3) { // CT
			flag = CLIENTFILTER_TEAMTWO;
	}
	if (flag != 0) {
		new size = Team_GetClientCount(team);
		new clients[size];
		Client_Get(clients, flag);
		new j = 0;
		for (new i = 0; i < size; i++) {
			if (clients[i] == client) {
				size -= 1;
				clients[i] = clients[size];
				break;
			}
		}
		EmitSoundToClient(client, youkillSound);
		EmitSound(clients, size, theyKillSound);
	}
}
