char PointSound[PLATFORM_MAX_PATH];

void Sounds_Load() {
    PointSound = "ui/deathnotice.wav";
    PrecacheSound(PointSound, true);
}

/**
 * Play the earned points sound to client
 *
 * @param client	The attacker that got the points
 * @noreturn
 */
void Sounds_PlayKill(int client) {
    EmitSoundToClient(client, PointSound);
}
