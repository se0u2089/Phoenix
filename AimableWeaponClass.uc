class AimableWeaponClass extends UTWeapon
	HideDropDown
	abstract;
 var repnotify int AmmoCount;
var enum EWeapAnimType
{
	EWAT_Default,
	EWAT_Pistol,
	EWAT_DualPistols,
	EWAT_ShoulderRocket,
	EWAT_Stinger
} WeapAnimType;

var(Animations)	array<name>	WeaponFireAnimZoom;
var(Animations) array<name> WeaponIdleAnimsZoom;
var(Animations)	array<name>	ArmFireAnimZoom;
var(Animations) array<name> ArmIdleAnimsZoom;
var float BaseGroundSpeed;
var float BaseAirSpeed;
var float BaseWaterSpeed;
var float BaseJumpZ;
var float ZoomGroundSpeed;
var float ZoomAirSpeed;
var float ZoomWaterSpeed;
var float ZoomJumpZ;
var float SpreadScoped;
var float SpreadNoScoped;
var bool AmIZoomed;
var bool bDisplayCrosshair;
var float ZoomedFOVSub;
var bool bAbortZoom;
var int ZoomCount;
  //var float FOVAngle;
replication
{
  if ( Role == ROLE_Authority )
	AmIZoomed;
}


server reliable function CheckMyZoom()
{
        Local Pawn P;
        P = Pawn(Owner);
	if (AmIZoomed == true)
	{
        	P.GroundSpeed = Default.ZoomGroundSpeed;
        	P.AirSpeed = Default.ZoomAirSpeed;
        	P.WaterSpeed = Default.ZoomWaterSpeed;
        	P.JumpZ = Default.ZoomJumpZ;
		Spread[CurrentFireMode] = Default.SpreadScoped;
		FireInterval[CurrentFireMode] = Default.FireInterval[CurrentFireMode]/1.25;

	}
	else
	{
        	P.GroundSpeed = Default.BaseGroundSpeed;
        	P.AirSpeed = Default.BaseAirSpeed;
        	P.WaterSpeed = Default.BaseWaterSpeed;
        	P.JumpZ = Default.BaseJumpZ;
		Spread[CurrentFireMode] = Default.SpreadNoScoped;
		FireInterval[CurrentFireMode] = Default.FireInterval[CurrentFireMode];
	}
}


simulated function Activate()
{
	CheckMyZoom();
	GetSetFOV();
	super.Activate();
}


simulated function DrawWeaponCrosshair( Hud HUD )
{
	local UTPlayerController PC;

	if( bDisplayCrosshair )
	{
		PC = UTPlayerController(Instigator.Controller);
		if ( (PC == None) || PC.bNoCrosshair )
		{
			return;
		}
		super.DrawWeaponCrosshair(HUD);
	}
}


simulated function GetSetFOV()
{
	local UTPlayerController PC;
	PC = UTPlayerController(Instigator.Controller);
	ZoomedTargetFOV = PC.DesiredFOV - ZoomedFOVSub;
}


simulated function StartZoom(UTPlayerController PC)
{
	ZoomCount++;
	if (ZoomCount == 1 && !IsTimerActive('Gotozoom')&& HasAmmo(0) && Instigator.IsFirstPerson())
	{
		bAbortZoom = false;
		bDisplayCrosshair = false;
		PlayWeaponAnimation('WeaponZoomIn',0.2);
		PlayArmAnimation('WeaponZoomIn',0.2);
		SetTimer(0.2, false, 'Gotozoom');
		SetTimer(0.2,false,'PlayMyZoomIdle');
		if( Role < Role_Authority )
		{
			// if we're a client, synchronize server
			SetTimer(0.2, false, 'ServerGotozoom');
		}
	}
}


simulated function Gotozoom()
{
	local UTPlayerController PC;

	PC = UTPlayerController(Instigator.Controller);
	if (GetZoomedState() == ZST_NotZoomed)
	{
		if (bAbortZoom) // stop the zoom after 1 tick
		{
			SetTimer(0.0001, false, 'StopZoom');
		}
		PC.DesiredFOV = ZoomedTargetFOV;
		PC.StartZoom(ZoomedTargetFOV, ZoomedRate);
	}
	AmIZoomed = true;
	CheckMyZoom();
}


reliable server function ServerGotoZoom()
{
	AmIZoomed = true;
	CheckMyZoom();
}


simulated function EndZoom(UTPlayerController PC)
{
	bAbortZoom = false;
	if (IsTimerActive('Gotozoom'))
	{
		ClearTimer('Gotozoom');
	}
	SetTimer(0.001,false,'LeaveZoom');
	if( Role < Role_Authority )
	{
		// if we're a client, synchronize server
		SetTimer(0.001,false,'ServerLeaveZoom');
	}
}


simulated function LeaveZoom()
{

	local UTPlayerController PC;
	PC = UTPlayerController(Instigator.Controller);
	if (PC != none)
	{
		PC.EndZoom();
	}
	ZoomCount = 0;
	PlayWeaponAnimation('WeaponZoomOut',0.3);
	PlayArmAnimation('WeaponZoomOut',0.3);
	SetTimer(0.3,false,'RestartCrosshair');
	AmIZoomed = false;
	bAbortZoom = false;
	CheckMyZoom();
}


reliable server function ServerLeaveZoom()
{
	AmIZoomed = false;
	CheckMyZoom();

}


simulated function StopZoom()
{
	local UTPlayerController PC;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		PC = UTPlayerController(Instigator.Controller);
		if (PC != None && LocalPlayer(PC.Player) != none)
		{
			PC.StopZoom();
		}
	}
}


simulated function RestartCrosshair()
{
	bDisplayCrosshair = true;
}


simulated function PutDownWeapon()
{
	LeaveZoom();
	Super.PutDownWeapon();
}


simulated function bool DenyClientWeaponSet()
{
	// don't autoswitch while zoomed
	return (GetZoomedState() != ZST_NotZoomed);
}


simulated function HolderEnteredVehicle()
{
	local UTPawn UTP;

	PlayWeaponAnimation('WeaponZoomOut', 0.3);

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		UTP = UTPawn(Instigator);
		if (UTP != None)
		{
			// Check we have access to mesh and animations
			if (UTP.ArmsMesh[0] != None && ArmsAnimSet != None && GetArmAnimNodeSeq() != None)
			{
				UTP.ArmsMesh[0].PlayAnim('WeaponZoomOut', 0.3, false);
			}
		}
	}
}


simulated function PlayWeaponPutDown()
{
	ClearTimer('GotoZoom');
	ClearTimer('StopZoom');
	if(UTPlayerController(Instigator.Controller) != none)
	{
		UTPlayerController(Instigator.Controller).EndZoom();
	}
	super.PlayWeaponPutDown();
}


simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	if (AmIZoomed == true)
	{
	if ( FireModeNum < WeaponFireAnim.Length && WeaponFireAnim[FireModeNum] != '' )
		PlayWeaponAnimation( WeaponFireAnimZoom[FireModeNum], GetFireInterval(FireModeNum) );
	if ( FireModeNum < ArmFireAnim.Length && ArmFireAnim[FireModeNum] != '' && ArmsAnimSet != none)
		PlayArmAnimation( ArmFireAnimZoom[FireModeNum], GetFireInterval(FireModeNum) );
	}
	else
	{
	if ( FireModeNum < WeaponFireAnim.Length && WeaponFireAnim[FireModeNum] != '' )
		PlayWeaponAnimation( WeaponFireAnim[FireModeNum], GetFireInterval(FireModeNum) );
	if ( FireModeNum < ArmFireAnim.Length && ArmFireAnim[FireModeNum] != '' && ArmsAnimSet != none)
		PlayArmAnimation( ArmFireAnim[FireModeNum], GetFireInterval(FireModeNum) );
	}
	// Start muzzle flash effect
	CauseMuzzleFlash();

	ShakeView();
}


simulated state Active
{
	simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
	{
		local int IdleIndex;

		if ( WorldInfo.NetMode != NM_DedicatedServer && WeaponIdleAnims.Length > 0 )
		{
	if (AmIZoomed == true)
	{
			IdleIndex = Rand(WeaponIdleAnimsZoom.Length);
			PlayWeaponAnimation(WeaponIdleAnimsZoom[IdleIndex], 0.0, true);
			if(ArmIdleAnims.Length > IdleIndex && ArmsAnimSet != none)
			{
				PlayArmAnimation(ArmIdleAnimsZoom[IdleIndex], 0.0,, true);
			}
	}
	else
	{
			IdleIndex = Rand(WeaponIdleAnims.Length);
			PlayWeaponAnimation(WeaponIdleAnims[IdleIndex], 0.0, true);
			if(ArmIdleAnims.Length > IdleIndex && ArmsAnimSet != none)
			{
				PlayArmAnimation(ArmIdleAnims[IdleIndex], 0.0,, true);
			}
	}
		}
	}
}
simulated function CheckEmpty()
{
 // if (clips == 0 && AmmoCount == 0)
  //{
 //   WeaponPlaySound(SoundCue'GearWeapons.Sound.WeaponEmptyClick_Cue');
//  }

}

simulated function PlayMyZoomIdle()
{
		local int IdleIndex;
		IdleIndex = Rand(WeaponIdleAnims.Length);
		PlayWeaponAnimation(WeaponIdleAnimsZoom[IdleIndex], 0.0, true);
		if(ArmIdleAnims.Length > IdleIndex && ArmsAnimSet != none)
		{
			PlayArmAnimation(ArmIdleAnimsZoom[IdleIndex], 0.0,, true);
		}
}

defaultproperties
{

	InstantHitDamageTypes(1)=None
	FiringStatesArray(1)=Active
	FireInterval(1)=+0.00001
	WeaponFireAnimZoom(0)=WeaponZoomFire
	WeaponIdleAnimsZoom(0)=WeaponZoomIdle
	ArmFireAnimZoom(0)=WeaponZoomFire
	ArmIdleAnimsZoom(0)=WeaponZoomIdle
	bZoomedFireMode(0)=0
	bZoomedFireMode(1)=1
	bDisplaycrosshair = true;
	JumpDamping=0.1
	MaxPitchLag=40
	MaxYawLag=50
	BaseGroundSpeed=440.0
	BaseAirSpeed=440.0
	BaseWaterSpeed=220.0
	BaseJumpZ=322.0
	AmIZoomed=false
	ZoomedRate=300000.0
	ZoomedFOVSub=60.0
	SpreadScoped=0.0025
	SpreadNoScoped=0.045
	ZoomGroundSpeed=210.0
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=110.0
	ZoomJumpZ=256.0
}