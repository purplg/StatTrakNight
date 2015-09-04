char File_weapongroups[] = "addons/sourcemod/configs/st_weapongroups.txt";
KeyValues kv;
int weapon_numGroups;
char weapon_targetGroup[16];

Weapons_Load() {
	kv = new KeyValues("");

	bool exists = FileExists(File_weapongroups);
	if (exists) {
		if (!kv.ImportFromFile(File_weapongroups)) {
			PrintToServer("[ST] Formatting of '%s' invalid", File_weapongroups);
			kv = Weapons_New();
		}
	} else {
		kv = Weapons_New();
	}
	weapon_numGroups = kv.GetNum("numGroups");
	Weapons_IsTargetGroup("");
}

KeyValues:Weapons_New(write=true) {
		kv = CreateKeyValues("weaponGroups");
		kv.SetNum("version", 1);
		kv.SetNum("numGroups", 2);

		kv.JumpToKey("groups", true);

		kv.JumpToKey("sniper", true);
		kv.SetNum("ssg08", 0);
		kv.SetNum("awp", 0);
		kv.SetNum("g3sg1", 0);
		kv.SetNum("scar20", 0);
		kv.GoBack();

		kv.JumpToKey("pistol", true);
		kv.SetNum("elite", 0);
		kv.SetNum("cz75a", 0);
		kv.SetNum("usp_silencer", 0);
		kv.SetNum("usp_silencer_off", 0);
		kv.SetNum("p250", 0);
		kv.SetNum("hkp2000", 0);
		kv.SetNum("tec9", 0);
		kv.SetNum("glock", 0);
		kv.SetNum("fiveseven", 0);
		kv.SetNum("deagle", 0);

		kv.Rewind();
		if (write) {
			kv.ExportToFile(File_weapongroups);
		}
		return kv;
}

void Weapon_NewGroup() {
	int rand = Math_GetRandomInt(0, weapon_numGroups-1);
	kv.Rewind();
	kv.JumpToKey("groups");
	kv.GotoFirstSubKey();
	for (new i = 0; i < rand; i++) {
		kv.GotoNextKey();
	}
	kv.GetSectionName(weapon_targetGroup, 16);
}

bool Weapons_IsTargetGroup(const char[] weapon) {
	kv.Rewind();
	kv.JumpToKey("groups", false);
	kv.JumpToKey(weapon_targetGroup, false);
	return kv.JumpToKey(weapon, false);
}
