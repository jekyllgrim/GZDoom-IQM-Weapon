class JGP_Pistol : JGP_WeaponBase
{
	bool firedLast; //true if we fired our last magazine round

	Default
	{
		Weapon.AmmoType1 'JGP_PistolMagAmmo';
		Weapon.AmmoUse1 1;
		Weapon.AmmoType2 'Clip';
		Weapon.AmmoGive2 30;
		Weapon.SlotNumber 2;
	}

	States {
	Spawn:
		// DECOUPLEDANIMATIONS has to be disabled here so
		// our direct frame assignment for M000Z in MODELDEF
		// actually works (it's re-enabled in AttachToOwner):
		M000 Z -1 NoDelay { bDECOUPLEDANIMATIONS = false; }
		stop;
	Select:
		M000 A 0
		{
			// Instantly move the PSPRIte up, since the animation
			// of the weapon already has the upward movement:
			A_WeaponOffset(0, WEAPONTOP);
			A_SetAnimation(invoker.ammo1.amount > 0? 'pistol_select' : 'pistol_select_empty', flags:SAF_INSTANT);
		}
		// Don't forget to allow switching out of the weapon:
		M000 A 8 A_WeaponReady(WRF_NOFIRE);
		goto Ready;
	Deselect:
		M000 A 8 A_SetAnimation(invoker.ammo1.amount > 0? 'pistol_deselect' : 'pistol_deselect_empty');
		// This can be safely looped since it guarantees
		// deselection:
		M000 A 0 A_Lower();
		wait;
	Ready:
		M000 A 1
		{
			A_SetAnimation(invoker.ammo1.amount > 0? 'pistol_idle' : 'pistol_idle_empty', flags:SAF_NOOVERRIDE);
			A_MagazineWeaponReady();
		}
		loop;
	Fire:
		M000 A 8
		{
			// Do the muzzle flash (see weapon.zs for source). It's best
			// to place this *before* A_SetAnimation, because this
			// calls A_ChangeModel to attach a model, and it's best to
			// do this before playing animations. (Actually, this shouldn't
			// be a problem unless the main model at index 0 is swapped,
			// but it's best to be safe.)
			A_ShowMuzzleFlash(0.5, 1.2, 180);
			// Pick animation based on whether this is
			// the last round in the mag:
			invoker.firedLast = invoker.ammo1.amount <= 1;
			A_SetAnimation(invoker.firedLast? 'pistol_fire_last' : 'pistol_fire');
			A_FireBullets(3.2, 1.0, -1, 10);
			A_StartSound("jgp/pistol/shot", CHAN_WEAPON);
		}
		M000 A 2 A_ReFire();
		goto Ready;
	Reload:
		// Animation start (26 frames, both versions):
		M000 A 14 A_SetAnimation(invoker.firedLast? 'pistol_reload_magout_dry' : 'pistol_reload_magout');
		M000 A 12 A_StartSound("jgp/pistol/magOut", CHAN_WEAPON);
		// Wait a bit (no animation)
		M000 A 10;
		M000 A 0
		{
			return invoker.firedLast? ResolveState("Reload.End.Dry") : ResolveState("ReloadEnd");
		}
	Reload.End:
		// End animation normal (27 frames):
		M000 A 2 A_SetAnimation(invoker.firedLast? 'pistol_reload_magin_dry' : 'pistol_reload_magin');
		M000 A 13 A_StartSound("jgp/pistol/magIn", CHAN_WEAPON);
		M000 A 12 A_ReloadMagazine();
		goto Ready;
	Reload.End.Dry:
		// End animation dry (37 frames):
		M000 A 2 A_SetAnimation(invoker.firedLast? 'pistol_reload_magin_dry' : 'pistol_reload_magin');
		M000 A 16 A_StartSound("jgp/pistol/magIn", CHAN_WEAPON);
		M000 A 3 A_StartSound("jgp/pistol/slide", CHAN_WEAPON);
		M000 A 16 A_ReloadMagazine();
		goto Ready;
	}
}

class JGP_PistolMagAmmo : JGP_MagAmmoBase
{
	Default
	{
		Inventory.MaxAmount 15;
	}
}