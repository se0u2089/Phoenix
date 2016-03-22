
class DemoGame2 extends UTGame;



event PreBeginPlay()
{
	super.PreBeginPlay();
}

static function string StripPlayOnPrefix( String MapName )
{
	if (Left(MapName, 6) ~= "UEDPIE")
	{
		return Right(MapName, Len(MapName) - 6);
	}
	else if ( Left(MapName, 5) ~= "UEDPC" )
	{
		return Right(MapName, Len(MapName) - 5);
	}
	else if (Left(MapName, 6) ~= "UEDPS3")
	{
		return Right(MapName, Len(MapName) - 6);
	}
	else if (Left(MapName, 6) ~= "UED360")
	{
		return Right(MapName, Len(MapName) - 6);
	}
	else if (Left(MapName, 6) ~= "UEDIOS")
	{
		return Right(MapName, Len(MapName) - 6);
	}

	return MapName;
}

  event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	local PlayerController PC;
	PC = super.Login(Portal, Options, UniqueID, ErrorMessage);
	ChangeName(PC, "Ulari", true);
    return PC;
}

 static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	local string NewMapName,GameTypeName,ThisMapPrefix,GameOption;
	local int PrefixIndex, MapPrefixPos,GameTypePrefixPos;
	local class<GameInfo> UTGameType;

	// Let UTGame decide the mode for UT entry maps.
	if (Left(MapName, 9) ~= "EnvyEntry" || Left(MapName, 14) ~= "UDKFrontEndMap" )
	{
		UTGameType = class<GameInfo>(DynamicLoadObject("UTGame.UTGame",class'Class'));
		if( UTGameType != None )
		{
			return UTGameType.static.SetGameType( MapName, Options, Portal );
		}
	}

	// allow commandline to override game type setting
	GameOption = ParseOption( Options, "Game");
	if ( GameOption != "" )
	{
		return Default.class;
	}

	// strip the "play on" prefixes from the filename, if it exists (meaning this is a Play in Editor game)
	NewMapName = StripPlayOnPrefix( MapName );

	// Get the prefix for this map
	MapPrefixPos = InStr(NewMapName,"-");
	ThisMapPrefix = left(NewMapName,MapPrefixPos);

	// Change game type 
	for ( PrefixIndex=0; PrefixIndex<Default.DefaultMapPrefixes.Length; PrefixIndex++ )
	{
		GameTypePrefixPos = InStr(Default.DefaultMapPrefixes[PrefixIndex].GameType ,".");
		GameTypeName = left(Default.DefaultMapPrefixes[PrefixIndex].GameType,GameTypePrefixPos);
		if ( Default.DefaultMapPrefixes[PrefixIndex].Prefix ~= ThisMapPrefix && ( GameTypeName ~= "UTGame" || GameTypeName ~= "UTGameContent" ) )
		{
			// If this is a UTGame type, let UTGame figure out the name
			UTGameType = class<GameInfo>(DynamicLoadObject("UTGame.UTGame",class'Class'));
			if( UTGameType != None )
			{
				return UTGameType.static.SetGameType( MapName, Options, Portal );
			}
		}
	}

	return Default.class;
}








defaultproperties
{
    Acronym="DG"
    DefaultInventory(0)=class'Phoenix.M34A2'
           DefaultInventory(1)=class'Phoenix.TommyGun2'
             DefaultInventory(2)=class'Phoenix.FlashWeap'
        InventoryClass=class'Phoenix.DemoInventory'
                     InventoryManagerClass=class'Phoenix.DemoInventoryManager'

    MapPrefixes.Empty
    MapPrefixes(0)="DG"

    bGivePhysicsGun=true
    DefaultMapPrefixes.Empty
	//DefaultMapPrefixes(0)=(Prefix="DG",GameType="Phoenix.DemoGame")


    bUseClassicHUD=true
    bDelayedStart=false

 //DefaultPawnClass = class'Phoenix.Human'
      //               DefaultPawnClass = class'Phoenix.Kazalite'
         DefaultPawnClass = class'Phoenix.DemoPawn2'

   PlayerControllerClass = class'Phoenix.AdvKitPlayerController'
    HUDType = class'Phoenix.GameHUD'
 

    Name="Default__demogame"
}