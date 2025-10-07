// Base class. Among other things,
// defines functionality for
// magazine-fed weapons
class JGP_WeaponBase : Weapon abstract
{
	int muzzleFlashTimer;

	enum EModelIndexes
	{
		MI_GUN = 0,
		MI_FLASH = 1,
	}

	Default
	{
		+DECOUPLEDANIMATIONS //required for decoupled animations
		+WEAPON.AMMO_OPTIONAL
		Weapon.AmmoGive1 0; //do not give magazine ammo on every pickup
		Weapon.AmmoUse 1;
		Weapon.BobStyle 'InverseSmooth';
		weapon.BobSpeed 1.5;
		weapon.BobRangeX 0.6;
		weapon.BobRangeY 0.3;
	}

	// Returns true if the weapon can be reloaded:
	bool isReloadable()
	{
		return ammo1 && ammo2 && ammo1 != ammo2 && ammo1.amount < ammo1.maxamount && ammo2.amount > 0;
	}

	// Refills current magazine from reserve:
	action void A_ReloadMagazine()
	{
		while (invoker.isReloadable())
		{
			invoker.ammo1.amount++;
			invoker.ammo2.amount--;
		}
	}

	// Allows reloading when appropriate:
	action void A_MagazineWeaponReady(int flags = WRF_ALLOWRELOAD)
	{
		if (!invoker.isReloadable())
		{
			flags &= ~WRF_ALLOWRELOAD;
			if (invoker.ammo1.amount <= 0)
			{
				flags |= WRF_NOFIRE;
			}
		}
		A_WeaponReady(flags);
	}

	// Dedicated function for muzzle flashes.
	// Attaches a muzzle flash model to the 'gun.muzzleflash' bone,
	// then rotates and scales it to add randomization.
	// The model is removed in DoEffect() using muzzleFlashTimer
	// as a timer.
	// This isn't required per se, i.e. the muzzle flash animation
	// could be baked into the firing animation; however, this
	// provides more procedural control over its looks.
	action void A_ShowMuzzleFlash(double minsize = 0.75, double maxsize = 1.0, double maxTilt = 20)
	{
		invoker.muzzleFlashTimer = 2;
		double sc = frandom[muzflash](-maxsize + 1.0, -minsize + 1.0);
		invoker.SetNamedBoneScaling('gun.muzzleflash', (sc, sc, sc), SB_ADD, 0.0);
		invoker.SetNamedBoneRotationAngles('gun.muzzleflash', 0, frandom[muzflash](-abs(maxTilt), abs(maxTilt)), 0, SB_ADD, 0.0);
		invoker.A_ChangeModel("", MI_FLASH,
			modelpath: "models/MuzzleFlash",
			model: "muzzleflash.iqm"
		);
	}

	// Go to Reload when trying to fire without having enough ammo.
	// If not enough ammo to reload, return null state.
	override State GetAtkState(bool hold)
	{
		if (ammo1 && ammo1.amount <= 0)
		{
			owner.player.refire = 0;
			return isReloadable()? ResolveState("Reload") : GetReadyState();
		}
		return Super.GetAtkState(hold);
	}

	override void AttachToOwner(Actor other)
	{
		Super.AttachToOwner(other);
		if (owner)
		{
			// Enable this flag when received (in case
			// in was disabled for Spawn), so decoupled
			// animations can actually be used:
			bDECOUPLEDANIMATIONS = true;
			// Fill magazine when the weapon is
			// first received:
			if (ammoGive1 == 0 && ammoType1)
			{
				let ammoClass = GetDefaultByType((class<Ammo>)(ammoType1));
				if (ammoClass)
				{
					owner.A_GiveInventory(ammoType1, ammoClass.maxAmount);
				}
			}
		}
	}

	override void DoEffect()
	{
		Super.DoEffect();
		if (muzzleFlashTimer)
		{
			if (--muzzleFlashTimer <= 0)
			{
				A_ChangeModel("", MI_FLASH, flags:CMDL_HIDEMODEL);
			}
		}
	}
}

// Base class for magazine ammo. Not affected by backpack.
class JGP_MagAmmoBase : Ammo abstract
{
	Default
	{
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount 0;
	}

	// This makes sure every class based on that is
	// considered its own ammo type:
	override Class<Ammo> GetParentAmmo ()
	{
		class<Object> type = GetClass();

		while (type.GetParentClass() && type.GetParentClass() != 'JGP_MagAmmoBase')
		{
			type = type.GetParentClass();
		}
		return (class<Ammo>)(type);
	}
}