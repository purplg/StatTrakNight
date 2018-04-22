char File_weapongroups[] = "addons/sourcemod/configs/st_weapongroups.txt";
KeyValues kv;
int weapon_numGroups;
char weapon_targetGroup[32];
int weapons_version = 5;
int weapon_rand;

void Weapons_Load() {
	kv = new KeyValues("");

	bool exists = FileExists(File_weapongroups);
	if (exists) {
		if (!kv.ImportFromFile(File_weapongroups)) {
			PrintServer("Formatting of '%s' invalid", File_weapongroups);
			kv = Weapons_New();
		} else if (kv.GetNum("version") < weapons_version) {
			PrintServer("Updated weapon groups");
			kv = Weapons_New();
		}
	} else {
		kv = Weapons_New();
	}
	weapon_numGroups = kv.GetNum("numGroups");
	Weapons_IsTargetGroup("");
}

KeyValues Weapons_New(bool write=true) {
	kv = CreateKeyValues("weaponGroups");
	kv.SetNum("version", weapons_version);
	kv.SetNum("numGroups", 6);

	kv.JumpToKey("groups", true);

	kv.JumpToKey("snipers", true);
	kv.SetNum("ssg08", 0);
	kv.SetNum("awp", 0);
	kv.SetNum("g3sg1", 0);
	kv.SetNum("scar20", 0);
	kv.GoBack();

	kv.JumpToKey("assault rifles", true);
	kv.SetNum("galilar", 0);
	kv.SetNum("ak47", 0);
	kv.SetNum("sg556", 0);
	kv.SetNum("famas", 0);
	kv.SetNum("m4a1", 0);
	kv.SetNum("m4a1_silencer_off", 0);
	kv.SetNum("m4a1_silencer", 0);
	kv.SetNum("aug", 0);
	kv.GoBack();

	kv.JumpToKey("smgs", true);
	kv.SetNum("mac10", 0);
	kv.SetNum("mp7", 0);
	kv.SetNum("ump45", 0);
	kv.SetNum("bizon", 0);
	kv.SetNum("p90", 0);
	kv.SetNum("mp9", 0);
	kv.GoBack();

	kv.JumpToKey("shotguns", true);
	kv.SetNum("nova", 0);
	kv.SetNum("xm1014", 0);
	kv.SetNum("sawedoff", 0);
	kv.SetNum("mag7", 0);
	kv.GoBack();

	kv.JumpToKey("machine guns", true);
	kv.SetNum("m249", 0);
	kv.SetNum("negev", 0);
	kv.GoBack();

	kv.JumpToKey("pistols", true);
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
	weapon_rand = Math_GetRandomInt(1, weapon_numGroups);
	kv.Rewind();
	kv.JumpToKey("groups");
	kv.GotoFirstSubKey();
	for (int i = 1; i <= weapon_rand; i++) {
		kv.GotoNextKey();
	}
	kv.GetSectionName(weapon_targetGroup, sizeof(weapon_targetGroup));
}

bool Weapons_IsValidGroup(const char weaponGroup[32]) {
	kv.Rewind();
	kv.JumpToKey("groups", false);
	return kv.JumpToKey(weaponGroup, false);
}

bool Weapons_SelectGroup(const char weaponGroup[32]) {
	if (Weapons_IsValidGroup(weaponGroup)) {
		weapon_targetGroup = weaponGroup;
		return true;
	}
	return false;
}

bool Weapons_IsTargetGroup(const char weapon[32]) {
	if (strcmp("taser", weapon) == 0 ||
		strcmp("knife_default_ct", weapon) == 0 ||
		strcmp("knife_default_t", weapon) == 0 ||
		strcmp("knife_t", weapon) == 0) {

		return true;
	}
	kv.Rewind();
	kv.JumpToKey("groups", false);
	kv.JumpToKey(weapon_targetGroup, false);
	return kv.JumpToKey(weapon, false);
}
