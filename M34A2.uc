

class M34A2 extends AimingDemoWeaponClass placeable ;

var const editconst DynamicLightEnvironmentComponent LightEnvironment;

var int ShellCount, ShellCountOffset;
 	var int clips;
var SpotLightComponent Flashlight;

var SkeletalMeshComponent SKMesh;

var repnotify bool bIsFlashlightOn;

var bool bIsTurningonFlashlight;
        var bool bIsReloading  ;
var SoundCue FlashLightSound;



simulated function PostBeginPlay()
{
	SKMesh.AttachComponentToSocket(Flashlight, 'FlashlightSocket');
	FlashLight.SetEnabled(self.default.bIsFlashlightOn);

	super.PostBeginPlay();
}


 //FlashlightfnctionsEND
/**
 * Check on various replicated data and act accordingly.
 */
simulated event ReplicatedEvent(name VarName)
{
    `log(VarName @ "replicated");
    if (VarName == 'bIsFlashlightOn')
    {
    	FlashLightToggled();
    	`log("bIsFlashlightOn replicated");
    }
    else
    {
    	Super.ReplicatedEvent(VarName);
    }
}

function ToggleFlashLight()
{
 // PlayWeaponAnimation('WeaponToggleFlashLight',1.0);
  bIsTurningonFlashlight = true;
  setTimer(0.5,false, 'ToggleMainFlashLight');
}

simulated function ToggleMainFlashlight()
{
    bIsFlashlightOn = !bIsFlashlightOn;
    `log("ToggleFlashlight: " $ bIsFlashlightOn);
    PlaySound(FlashLightSound);
    FlashLightToggled();
    setTimer(0.4,false, 'OpenFire');

    // if we are a remote client, make sure the Server Set's toggles the flashlight
    `log("Role:" @ Role);
	if( Role < Role_Authority )
	{
		ServerToggleFlashlight();
	}
}

function OpenFire()
{
  bIsTurningonFlashlight = false;
}

reliable server function ServerToggleFlashlight()
{
    bIsFlashlightOn = !bIsFlashlightOn;
    `log("ServerToggleFlashlight: " $ bIsFlashlightOn);
    FlashLightToggled();
}

simulated function FlashLightToggled()
{
    if(bIsFlashlightOn)
    {
        FlashLight.SetEnabled(true);
    }
    else
    {
        FlashLight.SetEnabled(false);
    }
}
//FlashlightfnctionsEND


simulated function StartFire(byte FireModeNum)
{
	local PlayerController PLR;
	PLR = PlayerController(Instigator.Controller);

	if(PLR == none || bIsTurningonFlashlight == true) //You can't shoot while reloading
		return;


        super.StartFire(FireModeNum);
}

simulated function CheckEmpty()
{
  if (clips == 0 && AmmoCount == 0)
  {
    //WeaponPlaySound(SoundCue'GearWeapons.Sound.WeaponEmptyClick_Cue');
  }
 // super.CheckEmpty();

}

simulated function bool DoOverrideNextWeapon()
{
      if(Clips == 0 && AmmoCount == 0)
      {
        super.DoOverrideNextWeapon();
      }
      return false;

}

simulated function WeaponEmpty()
{

        if(clips > 0 && !bIsReloading)
	{
		bIsReloading = true;
                PlayWeaponAnimation('WeaponReload',2.5);
                playcameraanim();
		SetTimer(2.5, false, 'Reload');
		
		if(bIsReloading == true)

            {
               DoEmpty(); 

            }
	}

        GotoState('Active');




}

simulated function DoEmpty()
{

     local DemoPlayerController SPR;



     SPR = DemoPlayerController(Instigator.Controller);


     SPR.StopSprinting();
     SPR.PlayCameraAnim(CameraAnim'ZombieWeapons.Camera.M4A1Reload');
     SPR.WeaponEmptyM();
     WorldInfo.Game.Broadcast(self, SPR); //BroadCast Target to make sure one is aquired

}

function PlayCameraAnim()
{
        local DemoPlayerController PLR;
	PLR = DemoPlayerController(Instigator.Controller);

	PLR.PlayCameraAnim(CameraAnim'ZombieWeapons.Camera.M4A1Reload');
}

function Reload()
{
        bIsReloading = false;
	clips = clips - 1;
	AddAmmo(60);
	ClearTimer();

}

function byte BestMode()
{
	local byte Best;
	if ( IsFiring() )
		return CurrentFireMode;

	if ( FRand() < 1.0 )
		Best = 1;

	if ( Best < bZoomedFireMode.Length && bZoomedFireMode[Best] != 0 )
		return 0;
	else
		return Best;
}
//global variables






defaultproperties
{
	
        bIsReloading = false
	Clips = 4;
	ClipsMax = 4;
        bIsFlashlightOn=true
        bIsTurningonFlashlight=false

	AttachmentClass=class'Attachment_M34A2'
        
        Begin Object class=SpotLightComponent name=SpotLightComponent0
		LightColor=(R=255,G=255,B=255)
        	CastShadows=true
        	bEnabled=true
        	Radius=1024.000000
        	FalloffExponent=3.000000
        	Brightness=1.900000
        	CastStaticShadows=False
        	CastDynamicShadows=True
        	bCastCompositeShadow=True
        	bAffectCompositeShadowDirection=True
        	LightShadowMode=LightShadow_Normal
	End Object
	Flashlight=SpotLightComponent0
        SKMesh=FirstPersonMesh

        
        Begin Object class=AnimNodeSequence Name=MeshSequenceA
		bCauseActorAnimEnd=true
	End Object


        Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=TRUE
	End Object

        LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)

        Begin Object Name=FirstPersonMesh
				SkeletalMesh=SkeletalMesh'Characters.gun_low_poly_final'
		AnimSets(0)=none
		Animations=MeshSequenceA
		FOV=70.0
        End Object


	Begin Object Name=PickupMesh
				SkeletalMesh=SkeletalMesh'Characters.gun_low_poly_final'
	End Object

	WeaponFireTypes(0)=EWFT_InstantHit
	InstantHitDamage(0)=45
	InstantHitMomentum(0)=+10.0
	FireInterval(0)=+0.10
	InstantHitDamageTypes(0)=class'UTDmgType_ShockPrimary'

	//
	//This is a very large value for debug purposes

	//A silly amount of spread ingame would show that the code isn't setting the spread values correctly
	//
	
        WeaponReloading(0)=WeaponReload
	WeaponFireSnd[0]=SoundCue'GearWeapons.Sound.M4A1_fire'
	WeaponEquipSnd=none
	WeaponPutDownSnd=none
	PickupSound=none
	ReloadSound=none
	ReloadCameraAnim=none

	MaxDesireability=0.65
	AIRating=0.65
	CurrentRating=0.65
	bInstantHit=true
	bSplashJump=false
	bRecommendSplashDamage=false
	ShouldFireOnRelease(0)=1


	AmmoCount=30
	LockerAmmoCount=26
	MaxAmmoCount=30


	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'gaz661-darkarts3dweapons.Effects.asgMuzzleFlash'
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'Phoenix.Riflefirelight'

	IconCoordinates=(U=728,V=382,UL=162,VL=45)

	InventoryGroup=4
	GroupWeight=0.5

	IconX=400
	IconY=129
	IconWidth=5.5
	IconHeight=12
	EquipTime=+0.6
	PutDownTime=+0.33
        InstantHitDamage(0)=100
	InstantHitDamageTypes(0)=class'UTDmgType_LinkBeam'

	CrossHairCoordinates=(U=256,V=0,UL=64,VL=64)

	//
	//These are the values carried over from the AimingWeaponClass that have been configured for this specific weapon
	//

	bSniping=true

	SpreadScoped=0.001
	SpreadNoScoped=0.003
	shellcount=2
        shellcountoffset=2
        FlashLightSound = SoundCue'GearWeapons.Sound.WeaponEmptyClick_Cue'
        FireCamera = CameraAnim'ZombieWeapons.Camera.M4A1Fire'
        EquipCameraAnim = CameraAnim'ZombieWeapons.Camera.M4A1Equip'
        PutDownCameraAnim = CameraAnim'ZombieWeapons.Camera.M4A1PutDown'
        
        WeaponName = "M34A2"
}