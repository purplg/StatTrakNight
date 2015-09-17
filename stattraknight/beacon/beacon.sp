/**
 * vim: set ts=4 :
 * =============================================================================
 * SourceMod Basefuncommands Plugin
 * Provides beacon functionality
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

new g_BeaconSerial[MAXPLAYERS+1] = { 0, ... };

ConVar g_Cvar_BeaconRadius;

CreateBeacon(client)
{
	g_BeaconSerial[client] = ++g_Serial_Gen;
	CreateTimer(1.0, Timer_Beacon, client | (g_Serial_Gen << 7), DEFAULT_TIMER_FLAGS);
}

KillBeacon(client)
{
	g_BeaconSerial[client] = 0;

	if (IsClientInGame(client))
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}

KillAllBeacons()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		KillBeacon(i);
	}
}

PerformBeacon(target)
{
	if (g_BeaconSerial[target] == 0)
	{
		CreateBeacon(target);
	}
}

BeaconRandom(team) {
	new flag;
	if (team == 2) {
		flag = CLIENTFILTER_TEAMONE;
	} else if (team == 3) {
		flag = CLIENTFILTER_TEAMTWO;
	}
	if (flag == 0) return -1;
	flag |= CLIENTFILTER_ALIVE;
	new target = Client_GetRandom(flag);
	PerformBeacon(target);
	return target;
}

public Action:Timer_Beacon(Handle:timer, any:value)
{
	new client = value & 0x7f;
	new serial = value >> 7;

	if (!IsClientInGame(client)
		|| !IsPlayerAlive(client)
		|| g_BeaconSerial[client] != serial)
	{
		KillBeacon(client);
		return Plugin_Stop;
	}

	int team = GetClientTeam(client);

	float vec[3];
	GetClientAbsOrigin(client, vec);
	vec[2] += 10;

	if (g_BeamSprite > -1 && g_HaloSprite > -1)
	{
		TE_SetupBeamRingPoint(vec, 10.0, g_Cvar_BeaconRadius.FloatValue, g_BeamSprite, g_HaloSprite, 0, 15, 0.5, 5.0, 0.0, greyColor, 10, 0);
		TE_SendToAll();

		if (team == 2)
		{
			TE_SetupBeamRingPoint(vec, 10.0, g_Cvar_BeaconRadius.FloatValue, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 10.0, 0.5, redColor, 10, 0);
		}
		else if (team == 3)
		{
			TE_SetupBeamRingPoint(vec, 10.0, g_Cvar_BeaconRadius.FloatValue, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 10.0, 0.5, blueColor, 10, 0);
		}
		else
		{
			TE_SetupBeamRingPoint(vec, 10.0, g_Cvar_BeaconRadius.FloatValue, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 10.0, 0.5, greenColor, 10, 0);
		}
		TE_SendToAll();
	}

	if (g_BlipSound[0])
	{
		GetClientEyePosition(client, vec);
		EmitAmbientSound(g_BlipSound, vec, client, SNDLEVEL_MINIBIKE);
	}

	return Plugin_Continue;
}
