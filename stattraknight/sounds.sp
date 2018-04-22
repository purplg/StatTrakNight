char youkillSound[PLATFORM_MAX_PATH];
char theyKillSound[PLATFORM_MAX_PATH];

void Sounds_Load() {
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
void Sound_PlayKill(int client) {
	int team = GetClientTeam(client);
	int flag;
	if (team == 2) { // T
		flag = CLIENTFILTER_TEAMONE;
	} else if (team == 3) { // CT
		flag = CLIENTFILTER_TEAMTWO;
	}
	if (flag != 0) {
		int size = Team_GetClientCount(team);
		int[] clients = new int[size];
		Client_Get(clients, flag);
		for (int i = 0; i < size; i++) {
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
