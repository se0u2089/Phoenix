class DemoInventoryManager extends UTInventoryManager



      config(Game);

/** Holds the last weapon used */
var Weapon PreviousWeapon;
struct native AmmoStore
{
	var	int				Amount;
	var class<UTWeapon> WeaponClass;
};

/** Stores the currently stored up ammo */
var array<AmmoStore> AmmoStorage;
var bool bInfiniteAmmo;
 simulated function Inventory CreateInventoryArchetype(Inventory NewInventoryItemArchetype, optional bool bDoNotActivate)
{
	local Inventory	Inv;
	
	// Ensure the inventory archetype is valid
	if (NewInventoryItemArchetype != None)
	{
		// Spawn the inventory archetype
		Inv = Spawn(NewInventoryItemArchetype.Class, Owner,,,, NewInventoryItemArchetype);
		
		// Spawned the inventory, and add the inventory
		if (Inv != None && !AddInventory(Inv, bDoNotActivate))
		{
			// Unable to add the inventory, so destroy the spawned inventory
			Inv.Destroy();
			Inv = None;
		}
	}

	// Return the spawned inventory
	return Inv;
}



simulated function GetWeaponList(out array<UTWeapon> WeaponList, optional bool bFilter, optional int GroupFilter, optional bool bNoEmpty)
{
	local UTWeapon Weap;
	local int i;

	ForEach InventoryActors( class'UTWeapon', Weap )
	{
		if ( (!bFilter || Weap.InventoryGroup == GroupFilter) && ( !bNoEmpty || Weap.HasAnyAmmo()) )
		{
			if ( WeaponList.Length>0 )
			{
				// Find it's place and put it there.

				for (i=0;i<WeaponList.Length;i++)
				{
					if (WeaponList[i].InventoryWeight > Weap.InventoryWeight)
					{
						WeaponList.Insert(i,1);
						WeaponList[i] = Weap;
						break;
					}
				}
				if (i==WeaponList.Length)
				{
					WeaponList.Length = WeaponList.Length+1;
					WeaponList[i] = Weap;
				}
			}
			else
			{
				WeaponList.Length = 1;
				WeaponList[0] = Weap;
			}
		}
	}
}


 function bool NeedsAmmo(class<UTWeapon> TestWeapon)
{
	local array<UTWeapon> WeaponList;
	local int i;

	// Check the list of weapons
	GetWeaponList(WeaponList);
	for (i=0;i<WeaponList.Length;i++)
	{
		if ( ClassIsChildOf(WeaponList[i].Class, TestWeapon) )	// The Pawn has this weapon
		{
			if ( WeaponList[i].AmmoCount < WeaponList[i].MaxAmmoCount )
				return true;
			else
				return false;
		}
	}

	// Check our stores.
	for (i=0;i<AmmoStorage.Length;i++)
	{
		if ( ClassIsChildOf(WeaponList[i].Class, TestWeapon) )
		{
			if ( AmmoStorage[i].Amount < TestWeapon.default.MaxAmmoCount )
				return true;
			else
				return false;
		}
	}

	return true;

}

/**
 * Called by the UTAmmoPickup classes, this function attempts to add ammo to a weapon.  If that
 * weapon exists, it adds it otherwise it tracks the ammo in an array for later.
 */

function AddAmmoToWeapon(int AmountToAdd, class<UTWeapon> WeaponClassToAddTo)
{
	local array<UTWeapon> WeaponList;
	local int i;

	// Get the list of weapons

	GetWeaponList(WeaponList);
	for (i=0;i<WeaponList.Length;i++)
	{
		if ( ClassIsChildOf(WeaponList[i].Class, WeaponClassToAddTo) )	// The Pawn has this weapon
		{
			WeaponList[i].AddAmmo(AmountToAdd);
			return;
		}
	}

	// Add to to our stores for later.

	for (i=0;i<AmmoStorage.Length;i++)
	{

		// We are already tracking this type of ammo, so just increment the ammount

		if (AmmoStorage[i].WeaponClass == WeaponClassToAddTo)
		{
			AmmoStorage[i].Amount += AmountToAdd;
			return;
		}
	}

	// Track a new type of ammo

	i = AmmoStorage.Length;
	AmmoStorage.Length = AmmoStorage.Length + 1;
	AmmoStorage[i].Amount = AmountToAdd;
	AmmoStorage[i].WeaponClass = WeaponClassToAddTo;

}


/**
 * Accessor for the server to begin a weapon switch on the client.
 *
 * @param	DesiredWeapon		The Weapon to switch to
 */

reliable client function ClientSetCurrentWeapon(Weapon DesiredWeapon)
{
	SetPendingWeapon(DesiredWeapon);
}

simulated function Inventory CreateInventory(class<Inventory> NewInventoryItemClass, optional bool bDoNotActivate)
{
	if (Role==ROLE_Authority)
	{
		return Super.CreateInventory(NewInventoryItemClass, bDoNotActivate);
	}
	return none;
}
/**
 * Handle AutoSwitching to a weapon
 */
simulated function bool AddInventory( Inventory NewItem, optional bool bDoNotActivate )
{
	local bool bResult;

	if (Role == ROLE_Authority)
	{
		bResult = super.AddInventory(NewItem, bDoNotActivate);
	}
	return bResult;
}


simulated function DiscardInventory()
{
	local Vehicle V;

	if (Role == ROLE_Authority)
	{
		Super.DiscardInventory();

		V = Vehicle(Owner);
		if (V != None && V.Driver != None && V.Driver.InvManager != None)
		{
			V.Driver.InvManager.DiscardInventory();
		}
	}
}

simulated function RemoveFromInventory(Inventory ItemToRemove)
{
	if (Role==ROLE_Authority)
	{
		Super.RemoveFromInventory(ItemToRemove);
	}
}
/**
 * Scans the inventory looking for any of type InvClass.  If it finds it it returns it, other
 * it returns none.
 */
function Inventory HasInventoryOfClass(class<Inventory> InvClass)
{
	local inventory inv;

	inv = InventoryChain;
	while(inv!=none)
	{
		if (Inv.Class==InvClass)
			return Inv;

		Inv = Inv.Inventory;
	}
	return none;
}

/**
 * Store the last used weapon for later
 */
simulated function ChangedWeapon()
{
	PreviousWeapon = Instigator.Weapon;
	Super.ChangedWeapon();
}




simulated function SwitchToPreviousWeapon()
{
	if ( PreviousWeapon!=none && PreviousWeapon != Pawn(Owner).Weapon )
	{
		PreviousWeapon.ClientWeaponSet(false);
	}
}

defaultproperties
{
	bInfiniteAmmo=false
        bMustHoldWeapon=true
	PendingFire(0)=0
	PendingFire(1)=0
}