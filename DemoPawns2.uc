
class DemoPawns2 extends  UDKPawn
	config(Game)
	notplaceable;
	
  var repnotify DemoPawn OwnerPawn;
var(DemoGame3) const Name WeaponSocketName;
var		bool	bFixedView;
var		bool	bSpawnDone;				// true when spawn protection has been deactivated
var		bool	bSpawnIn;
var		bool	bShieldAbsorb;			// set true when shield absorbs damage
var		bool	bDodging;				// true while in air after dodging
var		bool	bStopOnDoubleLanding;
var		bool	bIsInvulnerable;
var		bool	bJustDroppedOrb;		// if orb dropped because knocked off hoverboard

/** Holds the class type of the current weapon attachment.  Replicated to all clients. */
var	repnotify	class<DemoAttachmentClass>	CurrentWeaponAttachmentClass;

/** count of failed unfeign attempts - kill pawn if too many */
var int UnfeignFailedCount;

/** true when feign death activation forced (e.g. knocked off hoverboard) */
var bool bForcedFeignDeath;

/** The pawn's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;

/** anim node used for feign death recovery animations */
var AnimNodeBlend FeignDeathBlend;

/** Slot node used for playing full body anims. */
var AnimNodeSlot FullBodyAnimSlot;

/** Slot node used for playing animations only on the top half. */
var AnimNodeSlot TopHalfAnimSlot;

var(DeathAnim)	float	DeathHipLinSpring;
var(DeathAnim)	float	DeathHipLinDamp;
var(DeathAnim)	float	DeathHipAngSpring;
var(DeathAnim)	float	DeathHipAngDamp;

/** World time that we started the death animation */
var				float	StartDeathAnimTime;
/** Type of damage that started the death anim */
var				class<UTDamageType> DeathAnimDamageType;
/** Time that we took damage of type DeathAnimDamageType. */
var				float	TimeLastTookDeathAnimDamage;

var	globalconfig bool bWeaponBob;
var bool		bJustLanded;			/** used by eyeheight adjustment.  True if pawn recently landed from a fall */
var bool		bLandRecovery;			/** used by eyeheight adjustment. True if pawn recovering (eyeheight increasing) after lowering from a landing */

var		bool			bHasHoverboard;

/*********************************************************************************************
 Camera related properties
********************************************************************************************* */
var vector 	FixedViewLoc;
var rotator FixedViewRot;
var float CameraScale, CurrentCameraScale; /** multiplier to default camera distance */
var float CameraScaleMin, CameraScaleMax;

/** Stop death camera using OldCameraPosition if true */
var bool bStopDeathCamera;

/** OldCameraPosition saved when dead for use if fall below killz */
var vector OldCameraPosition;

/** used to smoothly adjust camera z offset in third person */
var float CameraZOffset;

/** If true, use end of match "Hero" camera */
var bool bWinnerCam;

/** Used for end of match "Hero" camera */
var(HeroCamera) float HeroCameraScale;

/** Used for end of match "Hero" camera */
var(HeroCamera) int HeroCameraPitch;

var		float	DodgeSpeed;
var		float	DodgeSpeedZ;
var		eDoubleClickDir CurrentDir;
var()	float	DoubleJumpEyeHeight;
var		float	DoubleJumpThreshold;
var		float	DefaultAirControl;

/** view bob properties */
var	globalconfig	float	Bob;
var					float	LandBob;
var					float	JumpBob;
var					float	AppliedBob;
var					float	bobtime;
var					vector	WalkBob;

/** when a body in feign death's velocity is less than this, it is considered to be at rest (allowing the player to get up) */
var float FeignDeathBodyAtRestSpeed;

/** when we entered feign death; used to increase FeignDeathBodyAtRestSpeed over time so we get up in a reasonable amount of time */
var float FeignDeathStartTime;

/** When feign death recovery started.  Used to pull feign death camera into body during recovery */
var float FeignDeathRecoveryStartTime;

var int  SuperHealthMax;					/** Maximum allowable boosted health */

var class<UTPawnSoundGroup> SoundGroupClass;

/** This pawn's current family/class info **/
var class<UTFamilyInfo> CurrCharClassInfo;

/** bones to set fixed when doing the physics take hit effects */
var array<name> TakeHitPhysicsFixedBones;

/** Array of bodies that should not have joint drive applied. */
var array<name> NoDriveBodies;

/** Controller vibration for taking falling damage. */
var ForceFeedbackWaveform FallingDamageWaveForm;


/*********************************************************************************************
  Gibs
********************************************************************************************* */

/** Track damage accumulated during a tick - used for gibbing determination */
var float AccumulateDamage;

/** Tick time for which damage is being accumulated */
var float AccumulationTime;

/** whether or not we have been gibbed already */
var bool bGibbed;

/** whether or not we have been decapitated already */
var bool bHeadGibbed;

/*********************************************************************************************
 Hoverboard
********************************************************************************************* */
var		float			LastHoverboardTime;
var		float			MinHoverboardInterval;

/** Node used for blending between driving and non-driving state. */
var		UTAnimBlendByDriving DrivingNode;

/** Node used for blending between different types of vehicle. */
var		UTAnimBlendByVehicle VehicleNode;

/** Node used for various hoverboarding actions. */
var		UTAnimBlendByHoverboarding HoverboardingNode;

/*********************************************************************************************
 Armor
********************************************************************************************* */
var float ShieldBeltArmor;
var float VestArmor;
var float ThighpadArmor;

/*********************************************************************************************
 Weapon / Firing
********************************************************************************************* */

var bool bArmsAttached;

/** This holds the local copy of the current attachment.  This "attachment" actor will exist independantly on all clients */
var				DemoAttachmentClass			CurrentWeaponAttachment;
/** client side flag indicating whether attachment should be visible - primarily used when spawning the initial weapon attachment
 * as events that change its visibility might have happened before we received a CurrentWeaponAttachmentClass
 * to spawn and call the visibility functions on
 */
var bool bWeaponAttachmentVisible;

/** WeaponSocket contains the name of the socket used for attaching weapons to this pawn. */
var name WeaponSocket, WeaponSocket2;

/** Socket to find the feet */
var name PawnEffectSockets[2];

/** These values are used for determining headshots */
var float			HeadOffset;
var float           HeadRadius;
var float           HeadHeight;
var name			HeadBone;
/** We need to save a reference to the headshot neck attachment for the case of:  Headshot then gibbed  so we can hide this **/
var protected StaticMeshComponent HeadshotNeckAttachment;

var class<Actor> TransInEffects[2];
var	LinearColor  TranslocateColor[2];
/** camera anim played when spawned/teleported */
var CameraAnim TransCameraAnim[3];

var SoundCue ArmorHitSound;
/** sound played when initially spawning in */
var SoundCue SpawnSound;
/** sound played when we teleport */
var SoundCue TeleportSound;

/** Set when pawn died on listen server, but was hidden rather than ragdolling (for replication purposes) */
var bool bHideOnListenServer;

/*********************************************************************************************
  Overlay system

  UTPawns support 2 separate overlay systems.   The first is a simple colorizer that can be used to
  apply a color to the pawn's skin.  This is accessed via the
********************************************************************************************* */

/** This is the color that will be applied when a pawn is first spawned in and is covered by protection */
var	LinearColor SpawnProtectionColor;

/*********************************************************************************************
* Team beacons
********************************************************************************************* */
var(TeamBeacon) float      TeamBeaconPlayerInfoMaxDist;
var(TeamBeacon) Texture    SpeakingBeaconTexture;

/** true is last trace test check for drawing postrender beacon succeeded */
var bool bPostRenderTraceSucceeded;

/*********************************************************************************************
* HUD Icon
********************************************************************************************* */
var float MapSize;
var TextureCoordinates IconCoords;	/** Coordiates of the icon associated with this object */
/*********************************************************************************************
* Pain
********************************************************************************************* */
const MINTIMEBETWEENPAINSOUNDS=0.35;
var			float		LastPainSound;
var float RagdollLifespan;
var UTProjectile AttachedProj;

/** Max distance from listener to play footstep sounds */
var float MaxFootstepDistSq;

/** Max distance from listener to play jump/land sounds */
var float MaxJumpSoundDistSq;

/*********************************************************************************************
* Skin swapping support
********************************************************************************************* */
/** type of vehicle spawned when activating the hoverboard */
var class<UTVehicle> HoverboardClass;

var DrivenWeaponPawnInfo LastDrivenWeaponPawn;
/** reference WeaponPawn spawned on non-owning clients for code that checks for DrivenVehicle */
var UTClientSideWeaponPawn ClientSideWeaponPawn;

/** set on client when valid team info is received; future changes are then ignored unless this gets reset first
 * this is used to prevent the problem where someone changes teams and their old dying pawn changes color
 * because the team change was received before the pawn's dying
 */
var bool bReceivedValidTeam;

/*********************************************************************************************
 * Hud Widgets
********************************************************************************************* */

/** The default overlay to use when not in a team game */
var MaterialInterface ShieldBeltMaterialInstance;
/** A collection of overlays to use in team games */
var MaterialInterface ShieldBeltTeamMaterialInstances[4];

/** If true, head size will change based on ratio of kills to deaths */
var bool bKillsAffectHead;

/** Mirrors the # of charges available to jump boots */
var int JumpBootCharge;

/** Mesh scaling default */
var float DefaultMeshScale;

var name TauntNames[6];

/** currently desired scale of the hero (switches between crouched and default) */
var float DesiredMeshScale;

/** Third person camera offset */
var vector CamOffset;

/** information on what gibs to spawn and where */
struct GibInfo
{
	/** the bone to spawn the gib at */
	var name BoneName;
	/** the gib class to spawn */
	var class<UTGib> GibClass;
	var bool bHighDetailOnly;
};

/** bio death effect - updates BioEffectName parameter in the mesh's materials from 0 to 10 over BioBurnAwayTime
 * activated BioBurnAway particle system on death, deactivates it when BioBurnAwayTime expires
 * could easily be overridden by a custom death effect to use other effects/materials, @see UTDmgType_BioGoo
 */
var bool bKilledByBio;
var ParticleSystemComponent BioBurnAway;
var float BioBurnAwayTime;
var name BioEffectName;

/** Time at which this pawn entered the dying state */
var float DeathTime;

enum EWeapAnimType
{
	EWAT_Default,
	EWAT_Pistol,
	EWAT_DualPistols,
	EWAT_ShoulderRocket,
	EWAT_Stinger
};

replication
{
	if ( bNetOwner && bNetDirty )
		bHasHoverboard, ShieldBeltArmor, VestArmor, ThighpadArmor;
	if ( bNetDirty )
		CurrentWeaponAttachmentClass;
}

simulated function AdjustPPEffects(UTPlayerController PC, bool bRemove);





/** Accessor to make sure we always get a valid UTPRI */
simulated function UTPlayerReplicationInfo GetUTPlayerReplicationInfo()
{
	local UTPlayerReplicationInfo UTPRI;

	UTPRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
	if (UTPRI == None)
	{
		if (DrivenVehicle != None)
		{
			UTPRI = UTPlayerReplicationInfo(DrivenVehicle.PlayerReplicationInfo);
		}
	}

	return UTPRI;
}

 simulated function PostBeginPlay()
{
	local rotator R;
	local PlayerController PC;

	StartedFallingTime = WorldInfo.TimeSeconds;

	Super.PostBeginPlay();

	if (!bDeleteMe)
	{
		if (Mesh != None)
		{
			BaseTranslationOffset = Mesh.Translation.Z;
			CrouchTranslationOffset = Mesh.Translation.Z + CylinderComponent.CollisionHeight - CrouchHeight;
			OverlayMesh.SetParentAnimComponent(Mesh);
		}

	//	bCanDoubleJump = CanMultiJump();

		// Zero out Pitch and Roll
		R.Yaw = Rotation.Yaw;
		SetRotation(R);

		// add to local HUD's post-rendered list
		ForEach LocalPlayerControllers(class'PlayerController', PC)
		{
			if ( PC.MyHUD != None )
			{
				PC.MyHUD.AddPostRenderedActor(self);
			}
		}

		if ( WorldInfo.NetMode != NM_DedicatedServer )
		{
			UpdateShadowSettings(class'UTPlayerController'.default.PawnShadowMode == SHADOW_All);
		}

		// create a blob shadow on mobile platforms that don't support real shadows
		if (WorldInfo.IsConsoleBuild(CONSOLE_Mobile))
		{
			BlobShadow = new(self) class'StaticMeshComponent';
			BlobShadow.SetStaticMesh(StaticMesh'BlobShadow.ShadowMesh');
			BlobShadow.SetActorCollision(FALSE, FALSE);
			BlobShadow.SetScale(0.2);
			BlobShadow.SetRotation(rot(16384, 0, 0));
			BlobShadow.SetTranslation(vect(0.0, 0.0, -44.0));
			AttachComponent(BlobShadow);
		}
	}
}



simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	local UTPlayerReplicationInfo PRI;
	local int i;
	local int TeamNum;
	local MaterialInterface TeamMaterialHead, TeamMaterialBody, TeamMaterialArms;

	PRI = GetUTPlayerReplicationInfo();

	if (Info != CurrCharClassInfo)
	{
		// Set Family Info
		CurrCharClassInfo = Info;

		// get the team number (0 red, 1 blue, 255 no team)
		TeamNum = GetTeamNum();

		// AnimSets
		Mesh.AnimSets = Info.default.AnimSets;

		//Apply the team skins if necessary
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			Info.static.GetTeamMaterials(TeamNum, TeamMaterialHead, TeamMaterialBody);
		}

		// 3P Mesh and materials
		SetCharacterMeshInfo(Info.default.CharacterMesh, TeamMaterialHead, TeamMaterialBody);

		// First person arms mesh/material (if necessary)
		if (WorldInfo.NetMode != NM_DedicatedServer && IsHumanControlled() && IsLocallyControlled())
		{
			TeamMaterialArms = Info.static.GetFirstPersonArmsMaterial(TeamNum);
	//		SetFirstPersonArmsInfo(Info.static.GetFirstPersonArms(), TeamMaterialArms);
		}

		// PhysicsAsset
		// Force it to re-initialise if the skeletal mesh has changed (might be flappy bones etc).
		Mesh.SetPhysicsAsset(Info.default.PhysAsset, true);

		// Make sure bEnableFullAnimWeightBodies is only TRUE if it needs to be (PhysicsAsset has flappy bits)
		Mesh.bEnableFullAnimWeightBodies = FALSE;
		for(i=0; i<Mesh.PhysicsAsset.BodySetup.length && !Mesh.bEnableFullAnimWeightBodies; i++)
		{
			// See if a bone has bAlwaysFullAnimWeight set and also
			if( Mesh.PhysicsAsset.BodySetup[i].bAlwaysFullAnimWeight &&
				Mesh.MatchRefBone(Mesh.PhysicsAsset.BodySetup[i].BoneName) != INDEX_NONE)
			{
				Mesh.bEnableFullAnimWeightBodies = TRUE;
			}
		}

		//Overlay mesh for effects
		if (OverlayMesh != None)
		{
			OverlayMesh.SetSkeletalMesh(Info.default.CharacterMesh);
		}

		//Set some properties on the PRI
		if (PRI != None)
		{
			PRI.bIsFemale = Info.default.bIsFemale;
			PRI.VoiceClass = Info.static.GetVoiceClass();

			// Assign fallback portrait.
			PRI.CharPortrait = Info.static.GetCharPortrait(TeamNum);

			// a little hacky, relies on presumption that enum vals 0-3 are male, 4-8 are female
			if ( PRI.bIsFemale )
			{
				PRI.TTSSpeaker = ETTSSpeaker(Rand(4));
			}
			else
			{
				PRI. TTSSpeaker = ETTSSpeaker(Rand(5) + 4);
			}
		}

		// Bone names
		LeftFootBone = Info.default.LeftFootBone;
		RightFootBone = Info.default.RightFootBone;
		TakeHitPhysicsFixedBones = Info.default.TakeHitPhysicsFixedBones;

		// sounds
		SoundGroupClass = Info.default.SoundGroupClass;

		DefaultMeshScale = Info.Default.DefaultMeshScale;
		Mesh.SetScale(DefaultMeshScale);
		BaseTranslationOffset = CurrCharClassInfo.Default.BaseTranslationOffset;
		CrouchTranslationOffset = BaseTranslationOffset + CylinderComponent.Default.CollisionHeight - CrouchHeight;
	}
}

 simulated function SetCharacterMeshInfo(SkeletalMesh SkelMesh, MaterialInterface HeadMaterial, MaterialInterface BodyMaterial)
{
    Mesh.SetSkeletalMesh(SkelMesh);


}


simulated function Vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
{
	return GetPawnViewLocation();
}

function ClearWeaponOverlayFlag(byte FlagToClear)
{
//	ApplyWeaponOverlayFlags(WeaponOverlayFlags & ( 0xFF ^ (1 << FlagToClear)) );
}

exec function FixedView(string VisibleMeshes)
{
	local bool bVisibleMeshes;
	local float fov;

	if (WorldInfo.NetMode == NM_Standalone)
	{
		if (VisibleMeshes != "")
		{
			bVisibleMeshes = ( VisibleMeshes ~= "yes" || VisibleMeshes~="true" || VisibleMeshes~="1" );

			if (VisibleMeshes ~= "default")
				bVisibleMeshes = !IsFirstPerson();

			SetMeshVisibility(bVisibleMeshes);
		}

		if (!bFixedView)
			CalcCamera( 0.0f, FixedViewLoc, FixedViewRot, fov );

		bFixedView = !bFixedView;
		`Log("FixedView:" @ bFixedView);
	}
}

simulated function float GetEyeHeight()
{
	if ( !IsLocallyControlled() )
		return BaseEyeHeight;
	else
		return EyeHeight;
}


simulated function bool CalcThirdPersonCam( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local vector CamStart, HitLocation, HitNormal, CamDirX, CamDirY, CamDirZ, CurrentCamOffset;
	local float DesiredCameraZOffset;

//	ModifyRotForDebugFreeCam(out_CamRot);

	CamStart = Location;
	CurrentCamOffset = CamOffset;

	if ( bWinnerCam )
	{
		// use "hero" cam
	//	SetHeroCam(out_CamRot);
		CurrentCamOffset = vect(0,0,0);
		CurrentCamOffset.X = GetCollisionRadius();
	}
	else
	{
		DesiredCameraZOffset = (Health > 0) ? 1.2 * GetCollisionHeight() + Mesh.Translation.Z : 0.f;
		CameraZOffset = (fDeltaTime < 0.2) ? DesiredCameraZOffset * 5 * fDeltaTime + (1 - 5*fDeltaTime) * CameraZOffset : DesiredCameraZOffset;
		if ( Health <= 0 )
		{
			CurrentCamOffset = vect(0,0,0);
			CurrentCamOffset.X = GetCollisionRadius();
		}
	}
	CamStart.Z += CameraZOffset;
	GetAxes(out_CamRot, CamDirX, CamDirY, CamDirZ);
	CamDirX *= CurrentCameraScale;

	if ( (Health <= 0) || bFeigningDeath )
	{
		// adjust camera position to make sure it's not clipping into world
		// @todo fixmesteve.  Note that you can still get clipping if FindSpot fails (happens rarely)
		FindSpot(GetCollisionExtent(),CamStart);
	}
	if (CurrentCameraScale < CameraScale)
	{
		CurrentCameraScale = FMin(CameraScale, CurrentCameraScale + 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
	}
	else if (CurrentCameraScale > CameraScale)
	{
		CurrentCameraScale = FMax(CameraScale, CurrentCameraScale - 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
	}
	if (CamDirX.Z > GetCollisionHeight())
	{
		CamDirX *= square(cos(out_CamRot.Pitch * 0.0000958738)); // 0.0000958738 = 2*PI/65536
	}
	out_CamLoc = CamStart - CamDirX*CurrentCamOffset.X + CurrentCamOffset.Y*CamDirY + CurrentCamOffset.Z*CamDirZ;
	if (Trace(HitLocation, HitNormal, out_CamLoc, CamStart, false, vect(12,12,12)) != None)
	{
		out_CamLoc = HitLocation;
		return false;
	}
	return true;
}



  simulated event BecomeViewTarget( PlayerController PC )
{
	local DemoPlayerController2 UTPC;
	local UTWeapon UTWeap;

	Super.BecomeViewTarget(PC);

	if (LocalPlayer(PC.Player) != None)
	{
		PawnAmbientSound.bAllowSpatialization = false;
		WeaponAmbientSound.bAllowSpatialization = false;

		bArmsAttached = true;
		AttachComponent(ArmsMesh[0]);
		UTWeap = UTWeapon(Weapon);
		if (UTWeap != None)
		{
			if (UTWeap.bUsesOffhand)
			{
				AttachComponent(ArmsMesh[1]);
			}
		}

		UTPC = DemoPlayerController2(PC);
		if (UTPC != None)
		{
			SetMeshVisibility(UTPC.bBehindView);
		}
		else
		{
			SetMeshVisibility(true);
		}
		bUpdateEyeHeight = true;
	}
}

 simulated function Vector GetPawnViewLocation()
{
	if ( bUpdateEyeHeight )
		return Location + EyeHeight * vect(0,0,1) + WalkBob;
	else
		return Location + BaseEyeHeight * vect(0,0,1);
}

 simulated function bool IsFirstPerson()
{
	local PlayerController PC;

	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( (PC.ViewTarget == self) && PC.UsingFirstPersonCamera() )
			return true;
	}
	return false;
}

/** moves the camera in or out one */
simulated function AdjustCameraScale(bool bMoveCameraIn)
{
	if ( !IsFirstPerson() )
	{
		CameraScale = FClamp(CameraScale + (bMoveCameraIn ? -1.0 : 1.0), CameraScaleMin, CameraScaleMax);
	}
}




simulated event rotator GetViewRotation()
{
	local rotator Result;

	//@FIXME: eventually bot Rotation.Pitch will be nonzero?
	if (UTBot(Controller) != None)
	{
		Result = Controller.Rotation;
		Result.Pitch = rotator(Controller.GetFocalPoint() - Location).Pitch;
		return Result;
	}
	else
	{
		return Super.GetViewRotation();
	}
}



simulated function SetWeaponVisibility(bool bWeaponVisible)
{
	local UTWeapon Weap;
	local AnimNodeSequence WeaponAnimNode, ArmAnimNode;
	local int i;

	Weap = UTWeapon(Weapon);
	if (Weap != None)
	{
		Weap.ChangeVisibility(bWeaponVisible);

		// make the arm animations copy the current weapon anim
		WeaponAnimNode = Weap.GetWeaponAnimNodeSeq();
		if (WeaponAnimNode != None)
		{
			for (i = 0; i < ArrayCount(ArmsMesh); i++)
			{
				if (ArmsMesh[i].bAttached)
				{
					ArmAnimNode = AnimNodeSequence(ArmsMesh[i].Animations);
					if (ArmAnimNode != None)
					{
						ArmAnimNode.SetAnim(WeaponAnimNode.AnimSeqName);
						ArmAnimNode.PlayAnim(WeaponAnimNode.bLooping, WeaponAnimNode.Rate, WeaponAnimNode.CurrentTime);
					}
				}
			}
		}
	}
}

simulated function SetWeaponAttachmentVisibility(bool bAttachmentVisible)
{
	bWeaponAttachmentVisible = bAttachmentVisible;
	if (CurrentWeaponAttachment != None )
	{
		CurrentWeaponAttachment.ChangeVisibility(bAttachmentVisible);
	}
}

/** sets whether or not the owner of this pawn can see it */
simulated function SetMeshVisibility(bool bVisible)
{
	local UTCarriedObject Flag;

	// Handle the main player mesh
	if (Mesh != None)
	{
		Mesh.SetOwnerNoSee(!bVisible);
	}

//	SetOverlayVisibility(bVisible);

	// Handle any weapons they might have
	SetWeaponVisibility(!bVisible);

	// realign any attached flags
	foreach BasedActors(class'UTCarriedObject', Flag)
	{
		HoldGameObject(Flag);
	}
}

 function SpawnDefaultController()
{
	local UTGame Game;
	local UTBot Bot;
	local CharacterInfo EmptyBotInfo;

	Super.SpawnDefaultController();

	Game = UTGame(WorldInfo.Game);
	Bot = UTBot(Controller);
	if (Game != None && Bot != None)
	{
		Game.InitializeBot(Bot, Game.GetBotTeam(), EmptyBotInfo);
	}
}
simulated function StartFire(byte FireModeNum)
{
	// firing cancels feign death
	if (bFeigningDeath)
	{
//		FeignDeath();
	}
	else
	{
		Super.StartFire(FireModeNum);
	}
}

   function bool StopWeaponFiring()
{
	local int i;
	local bool bResult;
	local UTWeapon UTWeap;

	UTWeap = UTWeapon(Weapon);
	if (UTWeap != None)
	{
		UTWeap.ClientEndFire(0);
		UTWeap.ClientEndFire(1);
		UTWeap.ServerStopFire(0);
		UTWeap.ServerStopFire(1);
		bResult = true;
	}

	if (InvManager != None)
	{
		for (i = 0; i < InvManager.GetPendingFireLength(Weapon); i++)
		{
			if( InvManager.IsPendingFire(Weapon, i) )
			{
				bResult = true;
				InvManager.ClearPendingFire(Weapon, i);
			}
		}
	}

	return bResult;
}


function bool StopFiring()
{
	return StopWeaponFiring();
}

simulated function SetThirdPersonCamera(bool bNewBehindView)
{
	if ( bNewBehindView )
	{
		CurrentCameraScale = 1.0;
		CameraZOffset = GetCollisionHeight() + Mesh.Translation.Z;
	}
	SetMeshVisibility(bNewBehindView);
}

event SetWalking( bool bNewIsWalking )
{
}

simulated function SwitchWeapon(byte NewGroup)
{
	if (NewGroup == 0 && bHasHoverboard && DrivenVehicle == None)
	{
		if ( WorldInfo.TimeSeconds - LastHoverboardTime > MinHoverboardInterval )
		{
	//		ServerHoverboard();
			LastHoverboardTime = WorldInfo.TimeSeconds;
		}
		return;
	}

	if (UTInventoryManager(InvManager) != None)
	{
		UTInventoryManager(InvManager).SwitchWeapon(NewGroup);
	}
}

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int OldHealth;

	// Attached Bio glob instigator always gets kill credit
	if (AttachedProj != None && !AttachedProj.bDeleteMe && AttachedProj.InstigatorController != None)
	{
		EventInstigator = AttachedProj.InstigatorController;
	}

	// reduce rocket jumping
	if (EventInstigator == Controller)
	{
		momentum *= 0.6;
	}

	// accumulate damage taken in a single tick
	if ( AccumulationTime != WorldInfo.TimeSeconds )
	{
		AccumulateDamage = 0;
		AccumulationTime = WorldInfo.TimeSeconds;
	}
    OldHealth = Health;
	AccumulateDamage += Damage;
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	AccumulateDamage = AccumulateDamage + OldHealth - Health - Damage;

}

 simulated function UpdateShadowSettings(bool bWantShadow)
{
	local bool bNewCastShadow, bNewCastDynamicShadow;

	if (Mesh != None)
	{
		bNewCastShadow = default.Mesh.CastShadow && bWantShadow;
		bNewCastDynamicShadow = default.Mesh.bCastDynamicShadow && bWantShadow;
		if (bNewCastShadow != Mesh.CastShadow || bNewCastDynamicShadow != Mesh.bCastDynamicShadow)
		{
			// if there is a pending Attach then this will set the shadow immediately as the flags have changed an a reattached has occurred
			Mesh.CastShadow = bNewCastShadow;
			Mesh.bCastDynamicShadow = bNewCastDynamicShadow;

			// defer if we can do so without it being noticeable
			if (LastRenderTime < WorldInfo.TimeSeconds - 1.0)
			{
				SetTimer(0.1 + FRand() * 0.5, false, 'ReattachMesh');
			}
			else
			{
				ReattachMesh();
			}
		}
	}
}

/** sets the value of bPuttingDownWeapon and plays any appropriate animations for the change */
simulated function SetPuttingDownWeapon(bool bNowPuttingDownWeapon)
{
	if (bPuttingDownWeapon != bNowPuttingDownWeapon || Role < ROLE_Authority)
	{
		bPuttingDownWeapon = bNowPuttingDownWeapon;
		if (CurrentWeaponAttachment != None)
		{
			CurrentWeaponAttachment.SetPuttingDownWeapon(bPuttingDownWeapon);
		}
	}
}

/** @return the value of bPuttingDownWeapon */
simulated function bool GetPuttingDownWeapon()
{
	return bPuttingDownWeapon;
}



/**
 * Called when a pawn's weapon has fired and is responsibile for
 * delegating the creation off all of the different effects.
 *
 * bViaReplication denotes if this call in as the result of the
 * flashcount/flashlocation being replicated.  It's used filter out
 * when to make the effects.
 */
simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	if (CurrentWeaponAttachment != None)
	{
		if ( !IsFirstPerson() )
		{
			CurrentWeaponAttachment.ThirdPersonFireEffects(HitLocation);
		}
		else
		{
			CurrentWeaponAttachment.FirstPersonFireEffects(Weapon, HitLocation);
	                if ( class'Engine'.static.IsSplitScreen() && CurrentWeaponAttachment.EffectIsRelevant(CurrentWeaponAttachment.Location,false,CurrentWeaponAttachment.MaxFireEffectDistance) )
	                {
		                // third person muzzle flash
		                CurrentWeaponAttachment.CauseMuzzleFlash();
	                }
		}

		if ( HitLocation != Vect(0,0,0) && (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || bViaReplication) )
		{
			CurrentWeaponAttachment.PlayImpactEffects(HitLocation);
		}
	}
}

simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	if (CurrentWeaponAttachment != None)
	{
		// always call function for both viewpoints, as during the delay between calling EndFire() on the weapon
		// and it actually stopping, we might have switched viewpoints (e.g. this commonly happens when entering a vehicle)
		CurrentWeaponAttachment.StopThirdPersonFireEffects();
		CurrentWeaponAttachment.StopFirstPersonFireEffects(Weapon);
	}
}

/**
 * Called when a weapon is changed and is responsible for making sure
 * the new weapon respects the current pawn's states/etc.
 */

simulated function WeaponChanged(UTWeapon NewWeapon)
{
	local UDKSkeletalMeshComponent UTSkel;

	// Make sure the new weapon respects behindview
	if (NewWeapon.Mesh != None)
	{
		NewWeapon.Mesh.SetHidden(!IsFirstPerson());
		UTSkel = UDKSkeletalMeshComponent(NewWeapon.Mesh);
		if (UTSkel != none)
		{
			ArmsMesh[0].SetFOV(UTSkel.FOV);
			ArmsMesh[1].SetFOV(UTSkel.FOV);
			ArmsMesh[0].SetScale(UTSkel.Scale);
			ArmsMesh[1].SetScale(UTSkel.Scale);
			NewWeapon.PlayWeaponEquip();
		}
	}                                                                       
}

/**
 * Called when there is a need to change the weapon attachment (either via
 * replication or locally if controlled.
 */
simulated function WeaponAttachmentChanged()
{
	if ((CurrentWeaponAttachment == None || CurrentWeaponAttachment.Class != CurrentWeaponAttachmentClass) && Mesh.SkeletalMesh != None)
	{
		// Detach/Destroy the current attachment if we have one
		if (CurrentWeaponAttachment!=None)
		{
			CurrentWeaponAttachment.DetachFrom(Mesh);
			CurrentWeaponAttachment.Destroy();
		}

		// Create the new Attachment.
		if (CurrentWeaponAttachmentClass!=None)
		{
			CurrentWeaponAttachment = Spawn(CurrentWeaponAttachmentClass,self);
			CurrentWeaponAttachment.Instigator = self;
		}
		else
			CurrentWeaponAttachment = none;

		// If all is good, attach it to the Pawn's Mesh.
		if (CurrentWeaponAttachment != None)
		{

            //   	CurrentWeaponAttachment.AttachTo(self);
            OwnerPawn.Mesh.AttachComponentToSocket(Mesh, OwnerPawn.WeaponSocket);
			CurrentWeaponAttachment.SetSkin(ReplicatedBodyMaterial);
			CurrentWeaponAttachment.ChangeVisibility(bWeaponAttachmentVisible);
		}
	}
}

function PlayHit(float Damage, Controller InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, TraceHitInfo HitInfo)
{
	local UTPlayerController Hearer;
	local class<UTDamageType> UTDamage;

	if ( InstigatedBy != None && (class<UTDamageType>(DamageType) != None) && class<UTDamageType>(DamageType).default.bDirectDamage )
	{
		Hearer = UTPlayerController(InstigatedBy);
		if (Hearer != None)
		{
			Hearer.bAcuteHearing = true;
		}
	}

	if (WorldInfo.TimeSeconds - LastPainSound >= MinTimeBetweenPainSounds)
	{
		LastPainSound = WorldInfo.TimeSeconds;

		if (Damage > 0 && Health > 0)
		{

			if ( DamageType == class'UTDmgType_Drowned' )
			{
				SoundGroupClass.static.PlayDrownSound(self);
			}
			else
			{
				SoundGroupClass.static.PlayTakeHitSound(self, Damage);
			}
		}
	}

	if ( Health <= 0 && PhysicsVolume.bDestructive && (WaterVolume(PhysicsVolume) != None) && (WaterVolume(PhysicsVolume).ExitActor != None) )
	{
		Spawn(WaterVolume(PhysicsVolume).ExitActor);
	}

	Super.PlayHit(Damage, InstigatedBy, HitLocation, DamageType, Momentum, HitInfo);

	if (Hearer != None)
	{
		Hearer.bAcuteHearing = false;
	}

	UTDamage = class<UTDamageType>(DamageType);

	if (Damage > 0 || (Controller != None && Controller.bGodMode))
	{
		CheckHitInfo( HitInfo, Mesh, Normal(Momentum), HitLocation );

		// play serverside effects
		if (bShieldAbsorb)
		{
	//		SetBodyMatColor(SpawnProtectionColor, 1.0);
			PlaySound(ArmorHitSound);
			bShieldAbsorb = false;
			return;
		}
		else if (UTDamage != None && UTDamage.default.DamageOverlayTime > 0.0 && UTDamage.default.XRayEffectTime <= 0.0)
		{
	//		SetBodyMatColor(UTDamage.default.DamageBodyMatColor, UTDamage.default.DamageOverlayTime);
		}

		LastTakeHitInfo.Damage = Damage;
		LastTakeHitInfo.HitLocation = HitLocation;
		LastTakeHitInfo.Momentum = Momentum;
		LastTakeHitInfo.DamageType = DamageType;
		LastTakeHitInfo.HitBone = HitInfo.BoneName;
		LastTakeHitTimeout = WorldInfo.TimeSeconds + ( (UTDamage != None) ? UTDamage.static.GetHitEffectDuration(self, Damage)
									: class'UTDamageType'.static.GetHitEffectDuration(self, Damage) );

		// play clientside effects
		PlayTakeHitEffects();
	}
}

/** plays clientside hit effects using the data in LastTakeHitInfo */
simulated function PlayTakeHitEffects()
{
	local class<UTDamageType> UTDamage;
	local vector BloodMomentum;
	local UTEmit_HitEffect HitEffect;
	local ParticleSystem BloodTemplate;

	if (EffectIsRelevant(Location, false))
	{
		UTDamage = class<UTDamageType>(LastTakeHitInfo.DamageType);
		if ( UTDamage != None )
		{
			if (UTDamage.default.bCausesBloodSplatterDecals && !IsZero(LastTakeHitInfo.Momentum) && !class'UTGame'.Static.UseLowGore(WorldInfo))
			{
	//			LeaveABloodSplatterDecal(LastTakeHitInfo.HitLocation, LastTakeHitInfo.Momentum);
			}

			if (!IsFirstPerson() || class'Engine'.static.IsSplitScreen())
			{
				if ( UTDamage.default.bCausesBlood && !class'UTGame'.Static.UseLowGore(WorldInfo) )
				{
					BloodTemplate = class'UTEmitter'.static.GetTemplateForDistance(GetFamilyInfo().default.BloodEffects, LastTakeHitInfo.HitLocation, WorldInfo);
					if (BloodTemplate != None)
					{
						BloodMomentum = Normal(-1.0 * LastTakeHitInfo.Momentum) + (0.5 * VRand());
						HitEffect = Spawn(GetFamilyInfo().default.BloodEmitterClass, self,, LastTakeHitInfo.HitLocation, rotator(BloodMomentum));
						HitEffect.SetTemplate(BloodTemplate, true);
						HitEffect.AttachTo(self, LastTakeHitInfo.HitBone);
					}
				}

				if ( !Mesh.bNotUpdatingKinematicDueToDistance )
				{
					// physics based takehit animations
					if (UTDamage != None)
					{
						//@todo: apply impulse when in full ragdoll too (that also needs to happen on the server)
						if ( !class'Engine'.static.IsSplitScreen() && Health > 0 && DrivenVehicle == None && Physics != PHYS_RigidBody &&
							VSize(LastTakeHitInfo.Momentum) > UTDamage.default.PhysicsTakeHitMomentumThreshold )
						{
							if (Mesh.PhysicsAssetInstance != None)
							{
								// just add an impulse to the asset that's already there
								Mesh.AddImpulse(LastTakeHitInfo.Momentum, LastTakeHitInfo.HitLocation);
								// if we were already playing a take hit effect, restart it
								if (bBlendOutTakeHitPhysics)
								{
									Mesh.PhysicsWeight = 0.5;
								}
							}
							else if (Mesh.PhysicsAsset != None)
							{
								Mesh.PhysicsWeight = 0.5;
								if (Mesh.PhysicsAssetInstance != None)
								{
									Mesh.PhysicsAssetInstance.SetNamedBodiesFixed(true, TakeHitPhysicsFixedBones, Mesh, true);
									}
								Mesh.AddImpulse(LastTakeHitInfo.Momentum, LastTakeHitInfo.HitLocation);
								bBlendOutTakeHitPhysics = true;
							}
						}
						UTDamage.static.SpawnHitEffect(self, LastTakeHitInfo.Damage, LastTakeHitInfo.Momentum, LastTakeHitInfo.HitBone, LastTakeHitInfo.HitLocation);
					}
				}
			}
		}
	}
}

simulated function class<UTFamilyInfo> GetFamilyInfo()
{
	local UTPlayerReplicationInfo UTPRI;

	UTPRI = GetUTPlayerReplicationInfo();
	if (UTPRI != None)
	{
		return UTPRI.CharClassInfo;
	}

	return CurrCharClassInfo;
}

/** reattaches the mesh component, because settings were updated */
simulated function ReattachMesh()
{
	DetachComponent(Mesh);
	AttachComponent(Mesh);
	EnsureOverlayComponentLast();
}
 defaultproperties
{


	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
		InvisibleUpdateTime=1
		MinTimeBetweenFullUpdates=.2
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment

	Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponent
		bCacheAnimSequenceNodes=FALSE
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bOwnerNoSee=true
		CastShadow=true
		BlockRigidBody=TRUE
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		Translation=(Z=8.0)
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		LightEnvironment=MyLightEnvironment
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE

SkeletalMesh=SkeletalMesh'PhoenixGamesDonal.main_characters_skmesh.Ulari_main_SKMESH'
	AnimTreeTemplate=AnimTree'PhoenixGamesDonal.Crano.UlariAnimationTree'
AnimSets(0)=AnimSet'Main_characters_Backup.main_characters_anim.Ulari_main_Animsets'

PhysicsAsset=PhysicsAsset'PhoenixGamesDonal.main_characters_skmesh.Ulari_main_SKMESH_Physics'



		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2
		bChartDistanceFactor=true
		//bSkipAllUpdateWhenPhysicsAsleep=TRUE
		RBDominanceGroup=20
		Scale=4.075
		// Nice lighting for hair
		bUseOnePassLightingOnTranslucency=TRUE
		bPerBoneMotionBlur=true
	End Object
	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)

	DefaultMeshScale=1.075
	BaseTranslationOffset=6.0

	Begin Object Name=OverlayMeshComponent0 Class=SkeletalMeshComponent
		Scale=1.015
		bAcceptsDynamicDecals=FALSE
		CastShadow=false
		bOwnerNoSee=true
		bUpdateSkelWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=true
		TickGroup=TG_PostAsyncWork
		bPerBoneMotionBlur=true
	End Object
	OverlayMesh=OverlayMeshComponent0
	
	
	

	


Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
        BlockRigidBody=true
        CollideActors=true
        BlockZeroExtent=true


SkeletalMesh=SkeletalMesh'PhoenixGamesDonal.main_characters_skmesh.Ulari_main_SKMESH'
	AnimTreeTemplate=AnimTree'PhoenixGamesDonal.Crano.UlariAnimationTree'
AnimSets(0)=AnimSet'Main_characters_Backup.main_characters_anim.Ulari_main_Animsets'

PhysicsAsset=PhysicsAsset'PhoenixGamesDonal.main_characters_skmesh.Ulari_main_SKMESH_Physics'

                      
                      DepthPriorityGroup=SDPG_Foreground
                      WeaponSocketName=WeaponPoint
	End Object
	

	CylinderComponent=CollisionCylinder
	CollisionComponent=CollisionCylinder
}
