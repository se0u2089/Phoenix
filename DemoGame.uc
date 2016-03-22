
class DemoGame extends UTGame config(Game);


event PreBeginPlay()
{
	super.PreBeginPlay();
}

  event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	local PlayerController PC;
	PC = super.Login(Portal, Options, UniqueID, ErrorMessage);
	ChangeName(PC, "Ulari", true);
    return PC;
}





function AddDefaultInventory( pawn PlayerPawn )
{
	local int i;
	//-may give the physics gun to non-bots
	if(PlayerPawn.IsHumanControlled() )
	{
		PlayerPawn.CreateInventory(class'TommyGun2',true);
	}


	`Log("Adding inventory");
	PlayerPawn.AddDefaultInventory();

}




defaultproperties
{
    Acronym="DG"
  
        InventoryClass=class'Phoenix.DemoInventory'
                    InventoryManagerClass=class'Phoenix.DemoInventoryManager'
                 //  DefaultInventory(0)=class'Phoenix.Weap_AS50_TestForMaxForumsMub'
    MapPrefixes.Empty

   DefaultInventory(0)=class'Phoenix.UTWeap_RocketLauncher_ContentPhysX'

    MapPrefixes(0)="DG"

   // bGivePhysicsGun=true
    DefaultMapPrefixes.Empty
	//DefaultMapPrefixes(0)=(Prefix="DG",GameType="Phoenix.DemoGame")


    bUseClassicHUD=True
    bDelayedStart=false

  DefaultPawnClass = class'Phoenix.DemoPawn'

        PlayerControllerClass = class'Phoenix.AdvKitPlayerController'

               HUDType = class'Phoenix.GameHUD'
    Name="Default__demogame"
}