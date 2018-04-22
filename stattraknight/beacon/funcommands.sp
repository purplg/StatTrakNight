/**
 * vim: set ts=4 :
 * =============================================================================
 * SourceMod Basic Fun Commands Plugin
 * Implements basic punishment commands.
 *
 * SourceMod (C)2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */

#pragma semicolon 1

// Sounds
new String:g_BlipSound[PLATFORM_MAX_PATH];

// Following are model indexes for temp entities
new g_BeamSprite = -1;
new g_HaloSprite = -1;

// Basic color arrays for temp entities
new redColor[4]		= {255, 75, 75, 255};
new greenColor[4]	= {75, 255, 75, 255};
new blueColor[4]	= {75, 75, 255, 255};
new greyColor[4]	= {128, 128, 128, 255};

// Serial Generator for Timer Safety
new g_Serial_Gen = 0;

// Flags used in various timers
#define DEFAULT_TIMER_FLAGS TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE

// Include various commands and supporting functions
#include "stattraknight/beacon/beacon.sp"

Funcommands_OnPluginStart()
{
	if (FindPluginByFile("funcommands.smx") == null)
	{
		ThrowError("This plugin requires funcommands.  You cannot run both at once.");
	}

	RegisterCvars( );
}

RegisterCvars( )
{
	// beacon
	g_Cvar_BeaconRadius = CreateConVar("sm_beacon_radius", "375", "Sets the radius for beacon's light rings.", 0, true, 50.0, true, 1500.0);

	AutoExecConfig(true, "funcommands");
}

Funcommands_OnMapStart()
{
	new Handle:gameConfig = LoadGameConfigFile("funcommands.games");
	if (gameConfig == null)
	{
		SetFailState("Unable to load game config funcommands.games");
		return;
	}

	if (GameConfGetKeyValue(gameConfig, "SoundBlip", g_BlipSound, sizeof(g_BlipSound)) && g_BlipSound[0])
	{
		PrecacheSound(g_BlipSound, true);
	}

	new String:buffer[PLATFORM_MAX_PATH];
	if (GameConfGetKeyValue(gameConfig, "SpriteBeam", buffer, sizeof(buffer)) && buffer[0])
	{
		g_BeamSprite = PrecacheModel(buffer);
	}

	if (GameConfGetKeyValue(gameConfig, "SpriteHalo", buffer, sizeof(buffer)) && buffer[0])
	{
		g_HaloSprite = PrecacheModel(buffer);
	}

	delete gameConfig;
}

Funcommands_OnMapEnd()
{
	KillAllBeacons( );
}

Funcommands_Event_RoundStart()
{
	KillAllBeacons( );
}
