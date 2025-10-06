class JGP_Pistol : JGP_WeaponBase
{
	bool firedLast; //true if we fired our last magazine round

	Default
	{
		Weapon.AmmoType1 'JGP_PistolMagAmmo';
		Weapon.AmmoUse1 1;
		Weapon.AmmoType2 'Clip';
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
			A_SetAnimation('pistol_select', flags:SAF_INSTANT);
		}
		// Don't forget to allow switching out of the weapon:
		M000 A 8 A_WeaponReady(WRF_NOFIRE);
		goto Ready;
	Deselect:
		M000 A 8 A_SetAnimation('pistol_deselect');
		// This can be safely looped since it guarantees
		// deselection:
		M000 A 0 A_Lower();
		wait;
	Ready:
		M000 A 1
		{
			// Pick animation based on whether the mag is empty:
			A_SetAnimation(invoker.ammo1.amount > 0? 'pistol_idle' : 'pistol_idle_empty', flags:SAF_LOOP|SAF_NOOVERRIDE);
			A_MagazineWeaponReady();
		}
		loop;
	Fire:
		M000 A 8
		{
			// Pick animation based on whether this is
			// the last round in the mag:
			invoker.firedLast = invoker.ammo1.amount <= 1;
			A_SetAnimation(invoker.firedLast? 'pistol_fire_last' : 'pistol_fire');
			A_FireBullets(3.2, 1.0, -1, 10);
		}
		M000 A 2 A_ReFire();
		goto Ready;
	Reload:
		// Animation start:
		M000 A 26 A_SetAnimation(invoker.firedLast? 'pistol_reload_magout_dry' : 'pistol_reload_magout');
		// Wait a bit:
		M000 A 10;
		// Finish animation:
		M000 A 10 A_SetAnimation(invoker.firedLast? 'pistol_reload_magin_dry' : 'pistol_reload_magin');
		M000 A 17
		{
			// This one is longer if we're doing dry reload:
			if (invoker.firedLast)
			{
				A_SetTics(27);
			}
			A_ReloadMagazine();
		}
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