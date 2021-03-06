class DemoAIBasePawn extends DemoPawns
Placeable;




var bool bIsObjective;
var DemoPawn P; // Variable to hold the pawn we bump into  / Attack
var AdvKitPlayerController MPC;
var bool bIsCrawling;

var bool bIsLegMissing;
var bool bIsChasing;
var() bool HasArmor;
var() bool HasWeakness;
var bool bHeadShot;
var int TotalDamage;


//Level event to trigger
var() name LevelEvent;

var() string ZName;
// members for the custom mesh
var() SkeletalMesh defaultMesh;
var() MaterialInterface defaultMaterial0;
var() AnimTree defaultAnimTree;
var() array<AnimSet> defaultAnimSet;
var() AnimNodeSequence defaultAnimSeq;
var() PhysicsAsset defaultPhysicsAsset;
var DemoAIBaseController AI;

var() name		HeadShotSocket;
var() name              LegSocketLeft;
var() name              LegSocketRight;
var() name              TorsoSocket;


//Gore and Decapitation
var() EmitterSpawnable HeadGore;
var() EmitterSpawnable LegGore;
var() EmitterSpawnable TorsoGore;


var() class<ZomGibSkel> TorsoGibClass;
var() class<ZomGib> LegGibClass;
var() class<ZomGibHead> HeadGibClass;

var() float HearingRadius;
var() float SightDistance;
var() float BodyStayTime;
var() bool bRandomMovement;
var() float RandomInterval;       
var vector TargetLocation;
var vector NewLocation;
 var bool bDead;
var bool DontSpawnExtraLegLeft;
var bool DontSpawnExtraLegRight;
var bool DontSpawnExtraTorso;

var StaticMeshComponent BoneComponent;
var() string Information;



//var MaterialInstanceConstant ZombieMats;

simulated event Tick(float DeltaTime)
{
  LookAt();
}

simulated function MatForNightVision()
{

   //  ZombieMats = new(None) Class'MaterialInstanceConstant';
    // ZombieMats.SetParent(Mesh.GetMaterial(0));
    // Mesh.SetMaterial(0, ZombieMats);

    // ZombieMats.SetScalarParameterValue('NightVisionShow', 1.0);

}

simulated function MatForNightVisionOff()
{
  //   ZombieMats.SetScalarParameterValue('NightVisionShow', 0.0);
}


function Alert()
{
  DemoAIBaseController(Controller).Alert();
  Information = "Alerted";
}



simulated function SetDyingPhysics()
{
	if(bDead ==false){
		bDead =true;
	if (Physics == PHYS_RigidBody)
		{
			//@note: Falling instead of None so Velocity/Acceleration don't get cleared
			setPhysics(PHYS_Falling);
		}

		Mesh.SetRBChannel(RBCC_Pawn);
		Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
		// Ensure we are always updating kinematic
		Mesh.MinDistFactorForKinematicUpdate = 0.0;


		Mesh.ForceSkelUpdate();

		// Move into post so that we are hitting physics from last frame, rather than animated from this
		Mesh.SetTickGroup(TG_PostAsyncWork);

		

		PreRagdollCollisionComponent = CollisionComponent;
		CollisionComponent = Mesh;

		// Turn collision on for skelmeshcomp and off for cylinder
		CylinderComponent.SetActorCollision(false, false);
		Mesh.SetActorCollision(true, true);
		Mesh.SetTraceBlocking(true, true);

		SetPhysics(PHYS_RigidBody);
		Mesh.PhysicsWeight = 0.5;

		// If we had stopped updating kinematic bodies on this character due to distance from camera, force an update of bones now.
		if( Mesh.bNotUpdatingKinematicDueToDistance )
		{
			Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
		}

		Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
		Mesh.bUpdateKinematicBonesFromAnimation=FALSE;

		// Set all kinematic bodies to the current root velocity, since they may not have been updated during normal animation
		// and therefore have zero derived velocity (this happens in 1st person camera mode).
		Mesh.SetRBLinearVelocity(Velocity, false);


		// reset mesh translation since adjustment code isn't executed on the server
		// but the ragdoll code uses the translation so we need them to match up for the
		// most accurate simulation
		
		// we'll use the rigid body collision to check for falling damage
		
		Mesh.SetNotifyRigidBodyCollision(true);
		Mesh.WakeRigidBody();
	}
}

function PlayHit(float Damage, Controller InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, TraceHitInfo HitInfo)
{
	local DemoPlayerController Hearer;
	local class<UTDamageType> UTDamage;

	if ( InstigatedBy != None && (class<UTDamageType>(DamageType) != None) && class<UTDamageType>(DamageType).default.bDirectDamage )
	{
		Hearer = DemoPlayerController(InstigatedBy);
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

	if (Damage > 0 )
	{
		CheckHitInfo( HitInfo, Mesh, Normal(Momentum), HitLocation );


		 if (UTDamage != None && UTDamage.default.DamageOverlayTime > 0.0 && UTDamage.default.XRayEffectTime <= 0.0)
		{
			SetBodyMatColor(UTDamage.default.DamageBodyMatColor, UTDamage.default.DamageOverlayTime);
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


simulated function ApplyDamageImpulse(vector Impulse, name BoneHit )
{
      local   SkelControl_TwistBone   SpineControl;
      local float TwistPower;

      //Convert Impulse Vector to Float
      TwistPower =  Vsize(Impulse);

      SpineControl = SkelControl_TwistBone(Mesh.FindSkelControl('HitImpulseTorso'));
      SpineControl.SetSkelControlStrength(1.0, 0.5);
      SpineControl.BlendInTime = 5.0;
      
      if(  BoneHit == 'b_RightShoulderPad'
        || BoneHit == 'b_RightForeArm'
        || BoneHit == 'b_RightClav' )
      {
         SpineControl.TwistAngleScale = - TwistPower - 25.0;
         SetTimer (0.5, false, 'ReturnFromImpulse');
      }
      else
      {
        SpineControl.TwistAngleScale =  TwistPower + 25.0;
        SetTimer (0.5, false, 'ReturnFromImpulse');
      }

}


function HeadShot(int Damage)
{

   local vector	 HeadLoc;
   local AdvKitPlayerController MP;

   MP = AdvKitPlayerController(Controller);

   foreach AllActors (class'DemoPawn', P)
   {
      if ( P != None )
      {
       bHeadShot = true;
       KilledBy(P);

           if(Damage > 40)
           {
             Mesh.HideBoneByName('b_Neck', PBO_Disable );
             Mesh.GetSocketWorldLocationAndRotation(HeadShotSocket, HeadLoc,);
             Spawn(HeadGibClass,,,HeadLoc);
             HeadGore = Spawn(class'EmitterSpawnable',,,HeadLoc);
             HeadGore.SetBase(self, , self.Mesh, HeadShotSocket);
             HeadGore.SetTemplate(ParticleSystem'ZombiesMonsters.Effects.HeadShot');
             MPC = AdvKitPlayerController(Controller);
            // MP.KillStreak++;
             ResetCharPhysState();
           }
           else
           {
         //    MP.KillStreak++;
           }
      }

   }

}


event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	// ** Check where the Zombie was hit.
        local Name boneName;
	local Vector whereDidHeGetHit;
        local Vector LeftLocLeg;
        local Vector RightlocLeg;
        local Vector TorsoLoc;
        local ZomGibSkel Torso;
        local int GibLocationRandom;

        LeaveABloodSplatterDecal(HitLocation, Momentum);


        TotalDamage = Damage;

        AI = DemoAIBaseController(Controller);
        AI.CalculateFinalHealth();

        boneName = Mesh.FindClosestBone(HitLocation, whereDidHeGetHit);
        whereDidHeGetHit= Mesh.GetBoneLocation(boneName);

        ApplyDamageImpulse(Momentum, boneName );

        if(boneName == 'b_head'
        || boneName == 'b_jawpivot'
        || boneName == 'b_leftcheek'
        || boneName == 'b_rightcheek'
        || boneName == 'b_rightmouth'
        || boneName == 'b_leftmouth'
        || boneName == 'b_lefteyebrow'
        || boneName == 'b_righteyebrow')
        {
           HeadShot(Damage);
    //       WorldInfo.Game.Broadcast(self,"HitHead");
        }
        else if (Damage >= 40 && boneName == 'b_RightLeg' || boneName =='b_LeftLeg')
        {
           bIsLegMissing = true; // missing leg bool must be true in order to have the above if's work.

           if (DontSpawnextralegleft == false && boneName == 'b_LeftLeg')
             {
                GroundSpeed = 50;
                bIsCrawling = true;
                DontSpawnExtralegleft = true;
                Mesh.GetSocketWorldLocationAndRotation(LegSocketLeft, LeftLocLeg);
                Spawn(LegGibClass,,,LeftLocLeg);
                LegGore = Spawn(class'EmitterSpawnable',,,LeftLocLeg);
                LegGore.SetBase(self, , self.Mesh, LegSocketLeft);
                LegGore.SetTemplate(ParticleSystem'ZombiesMonsters.Effects.HeadShot');
                Mesh.HideBoneByName('b_LeftLeg', PBO_Disable );
                Information = "Crawl";

                BoneComponent = new class'StaticMeshComponent';
	        BoneComponent.setStaticMesh(StaticMesh'ZombiesMonsters.ZombieGen.bone');
	        BoneComponent.setScale( 0.157);
	        Mesh.AttachComponentToSocket( BoneComponent, LegSocketLeft );
	         ResetCharPhysState()   ;
             }
             else if (DontSpawnExtralegright == false && boneName == 'b_RightLeg')
             {
                GroundSpeed = 50;
                bIsCrawling = true;
                DontSpawnExtralegright = true;
                Mesh.GetSocketWorldLocationAndRotation(LegSocketRight, RightLocLeg);
                Spawn(LegGibClass,,,RightLocLeg);
                LegGore = Spawn(class'EmitterSpawnable',,,RightLocLeg);
                LegGore.SetBase(self, , self.Mesh, LegSocketRight);
                LegGore.SetTemplate(ParticleSystem'ZombiesMonsters.Effects.HeadShot');
                Mesh.HideBoneByName('b_RightLeg', PBO_Disable );
	        Information = "Crawl";

                BoneComponent = new class'StaticMeshComponent';
	        BoneComponent.setStaticMesh(StaticMesh'ZombiesMonsters.ZombieGen.bone');
	        BoneComponent.setScale( 0.157);

	        Mesh.AttachComponentToSocket( BoneComponent, LegSocketRight );
	        ResetCharPhysState() ;
             }


        }
        else if (DontSpawnExtraTorso == false && (boneName == 'b_Spine1' || boneName == 'b_Spine2' || boneName == 'b_Spine3' || boneName == 'b_Hips' || boneName == 'b_LeftClav' || boneName == 'b_RightClav' && Damage >= 10 ))
        {
         Mesh.GetSocketWorldLocationAndRotation(TorsoSocket, TorsoLoc);
         Mesh.HideBoneByName('b_Spine2', PBO_Disable );
         Torso = Spawn(TorsoGibClass,,,TorsoLoc);
         Torso.HideSpecificBone ('b_LeftLeg');
         Torso.HideSpecificBone ('b_RightLeg');
         TorsoGore = Spawn(class'EmitterSpawnable',,,TorsoLoc);
         TorsoGore.SetBase(self, , self.Mesh, TorsoSocket);
         TorsoGore.SetTemplate(ParticleSystem'ZombiesMonsters.Effects.TorsoDismemeber');

         GibLocationRandom = RandRange(5,10);

         TorsoLoc.X = TorsoLoc.X + GibLocationRandom + RandRange(1,5);
         TorsoLoc.Y = TorsoLoc.Y + GibLocationRandom + RandRange(1,5);
         TorsoLoc.Z = TorsoLoc.Z + GibLocationRandom + RandRange(1,5);

         Spawn(class'FleshGib',,,TorsoLoc);
         Spawn(class'LiverGib',,,TorsoLoc);
         Spawn(class'KidneyGib',,,TorsoLoc);
           ResetCharPhysState()    ;
         DontSpawnExtraTorso = true;
         //Spawn Innards and  the upper part of torso.
        }
      //  WorldInfo.Game.Broadcast(self,"Where Hit:"@boneName);

        if(Damage <=30 && AI.Seen1Player == false)
        {
          AI.GoToState('SuprisedState');
        }
        // If the damage amount totals greater than 60 at once eg: a shotgun blast, then blow off te corresponding
        //leg must calculate hit location.
        super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

 //dont want the ut gib system
simulated function UTGib SpawnGib(class<UTGib> GibClass, name BoneName, class<UTDamageType> UTDamageType, vector HitLocation, bool bSpinGib){}
/** dont want the UTgib system */
simulated function SpawnGibs(class<UTDamageType> UTDamageType, vector HitLocation){}

simulated State Dying
{
ignores OnAnimEnd, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, StartFeignDeathRecoveryAnim, ForceRagdoll, FellOutOfWorld;

	exec simulated function FeignDeath();
	reliable server function ServerFeignDeath();




        event bool EncroachingOn(Actor Other)
	{
		// don't abort moves in ragdoll
		return false;
	}

	event Timer()
	{




		// let the dead bodies stay if the game is over
		if (WorldInfo.GRI != None && WorldInfo.GRI.bMatchIsOver)
		{
			LifeSpan = 0.0;
			return;
		}


	}



	simulated event Landed(vector HitNormal, Actor FloorActor)
	{
		local vector BounceDir;

		if( Velocity.Z < -500 )
		{
			BounceDir = 0.5 * (Velocity - 2.0*HitNormal*(Velocity dot HitNormal));
			TakeDamage( (1-Velocity.Z/30), Controller, Location, BounceDir, class'DmgType_Crushed');
		}
	}

	simulated event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		local Vector shotDir, ApplyImpulse,BloodMomentum;
		local class<UTDamageType> UTDamage;
		local UTEmit_HitEffect HitEffect;


		// When playing death anim, we keep track of how long since we took that kind of damage.
		if(DeathAnimDamageType != None)
		{
			if(DamageType == DeathAnimDamageType)
			{
				TimeLastTookDeathAnimDamage = WorldInfo.TimeSeconds;
			}
		}

		if (!bGibbed && (InstigatedBy != None || EffectIsRelevant(Location, true, 0)))
		{
			UTDamage = class<UTDamageType>(DamageType);

			// accumulate damage taken in a single tick
			if ( AccumulationTime != WorldInfo.TimeSeconds )
			{
				AccumulateDamage = 0;
				AccumulationTime = WorldInfo.TimeSeconds;
			}
			AccumulateDamage += Damage;

			Health -= Damage;
			if ( UTDamage != None )
			{
				if ( ShouldGib(UTDamage) )
				{
					if ( bHideOnListenServer || (WorldInfo.NetMode == NM_DedicatedServer) )
					{
						bTearOffGibs = true;
						bGibbed = true;
						return;
					}
					SpawnGibs(UTDamage, HitLocation);
				}
				else if ( !bHideOnListenServer && (WorldInfo.NetMode != NM_DedicatedServer) )
				{
					CheckHitInfo( HitInfo, Mesh, Normal(Momentum), HitLocation );
					UTDamage.Static.SpawnHitEffect(self, Damage, Momentum, HitInfo.BoneName, HitLocation);

					if ( UTDamage.default.bCausesBlood && !class'UTGame'.Static.UseLowGore(WorldInfo)
						&& ((PlayerController(Controller) == None) || (WorldInfo.NetMode != NM_Standalone)) )
					{
						BloodMomentum = Momentum;
						if ( BloodMomentum.Z > 0 )
							BloodMomentum.Z *= 0.5;
						HitEffect = Spawn(GetFamilyInfo().default.BloodEmitterClass,self,, HitLocation, rotator(BloodMomentum));
						HitEffect.AttachTo(Self,HitInfo.BoneName);
					}

					if ( (UTDamage.default.DamageOverlayTime > 0) && (UTDamage.default.DamageBodyMatColor != class'UTDamageType'.default.DamageBodyMatColor) )
					{
						SetBodyMatColor(UTDamage.default.DamageBodyMatColor, UTDamage.default.DamageOverlayTime);
					}

					if( (Physics != PHYS_RigidBody) || (Momentum == vect(0,0,0)) || (HitInfo.BoneName == '') )
						return;

					shotDir = Normal(Momentum);
					ApplyImpulse = (DamageType.Default.KDamageImpulse * shotDir);

					if( UTDamage.Default.bThrowRagdoll && (Velocity.Z > -10) )
					{
						ApplyImpulse += Vect(0,0,1)*DamageType.default.KDeathUpKick;
					}
					// AddImpulse() will only wake up the body for the bone we hit, so force the others to wake up
					Mesh.WakeRigidBody();
					Mesh.AddImpulse(ApplyImpulse, HitLocation, HitInfo.BoneName, true);
				}
			}
		}
	}

	simulated function BeginState(Name PreviousStateName)
	{


        	Super.BeginState(PreviousStateName);
		CustomGravityScaling = 1.0;
		DeathTime = WorldInfo.TimeSeconds;
		CylinderComponent.SetActorCollision(false, false);

		if ( bTearOff && (bHideOnListenServer || (WorldInfo.NetMode == NM_DedicatedServer)) )
			LifeSpan = 1.0;
		else
		{
			if ( Mesh != None )
			{
				Mesh.SetTraceBlocking(true, true);
				Mesh.SetActorCollision(true, false);

				// Move into post so that we are hitting physics from last frame, rather than animated from this
				Mesh.SetTickGroup(TG_PostAsyncWork);
			}
			SetTimer(2.0, false);
			LifeSpan = BodyStayTime;
			Mesh.PhysicsAssetInstance.SetAllMotorsAngularPositionDrive(false, false);
			SetPawnRBChannels(TRUE);
		}
             Information = "Dead";
            SetTimer(0.8, false, 'SpawnDeathBlood');

	}
}

function LookAt()
{
    local   SkelControlLookAt   HeadControl;
    local   SkelControlLookAt   BodyControl;
    local   DemoAIBaseController ZPC;



    ZPC = DemoAIBaseController(Controller);
    BodyControl = SkelControlLookAt(Mesh.FindSkelControl('BodyControl'));
    HeadControl = SkelControlLookAt(Mesh.FindSkelControl('HeadControl'));



      TargetLocation = ZPC.Target.Location;

      BodyControl.MaxAngle = 49;
      HeadControl.SetSkelControlStrength(1.0, 0.5);
      HeadControl.BlendInTime = 5.0;
      HeadControl.TargetLocation = TargetLocation;


}

simulated event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
 `Log("Bump");

     Super.Bump( Other, OtherComp, HitNormal );

	if ( (Other == None) || Other.bStatic )
		return;

  P = DemoPawn(Other); //the pawn we might have bumped into

	if ( P != None)  //if we hit a pawn
	{
            if (P.Health >1) //as long as pawns health is more than 1
	   {
             P.Health --; // eat brains! mmmmm
           }
        }
}



//Query all remote events in level.
function TriggerRemoteKismetEvent( name EventName )
{
    local array<SequenceObject> AllSeqEvents;
    local Sequence GameSeq;
    local int i;

    GameSeq = WorldInfo.GetGameSequence();
    if (GameSeq != None)
    {
        // find any Level Reset events that exist
        GameSeq.FindSeqObjectsByClass(class'SeqEvent_RemoteEvent', true, AllSeqEvents);

        // activate them
        for (i = 0; i < AllSeqEvents.Length; i++)
        {
	    if(SeqEvent_RemoteEvent(AllSeqEvents[i]).EventName == EventName)
	    SeqEvent_RemoteEvent(AllSeqEvents[i]).CheckActivate(WorldInfo, None);
	}
    }
}
simulated function SpawnDeathBlood()
{
        local Rotator DownRot;
        local DecalMaterial    BloodDecal;
        local Vector DLocation;

        DLocation = self.Location;

	DownRot.Pitch=-11195.0;
	DownRot.Roll=0;
	DownRot.Yaw=0;

	`Log("Can I spawn decals in gameinfo1?"@WorldInfo.MyDecalManager.CanSpawnDecals()); //returns true
	BloodDecal = new(self) class'DecalMaterial';
	BloodDecal = DecalMaterial'T_FX.DecalMaterials.M_FX_BloodDecal_FadeViaDissolving';
	WorldInfo.MyDecalManager.SpawnDecal(BloodDecal, DLocation, DownRot, 200, 200, 150, false);
	
	//Trigger the kismet event while we are at it.
//	TriggerRemoteKismetEvent(LevelEvent);
}


    simulated function LeaveABloodSplatterDecal( vector HitLoc, vector HitNorm )
{
	local Actor TraceActor;
	local vector out_HitLocation;
	local vector out_HitNormal;
	local vector TraceDest;
	local vector TraceStart;
	local vector TraceExtent;
	local TraceHitInfo HitInfo;
	local DecalMaterial MITV_Decal;

	TraceStart = HitLoc;
	HitNorm.Z = 0;
	TraceDest =  HitLoc  + ( HitNorm * 305 );

	TraceActor = Trace( out_HitLocation, out_HitNormal, TraceDest, TraceStart, false, TraceExtent, HitInfo, TRACEFLAG_PhysicsVolumes );

	if (TraceActor != None)
	{
		// we might want to move this to the UTFamilyInfo
		MITV_Decal = new(self) class'DecalMaterial';
		MITV_Decal = DecalMaterial'T_FX.DecalMaterials.M_FX_BloodDecal_FadeViaDissolving';

		WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal, out_HitLocation, rotator(-out_HitNormal), 100, 100, 50, false,, HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex);

	}
}



 simulated function SetPawnRBChannels(bool bRagdollMode)
{
	Mesh.SetRBChannel((bRagdollMode) ? RBCC_Pawn : RBCC_Untitled3);
	Mesh.SetRBCollidesWithChannel(RBCC_Default, bRagdollMode);
	Mesh.SetRBCollidesWithChannel(RBCC_Pawn, bRagdollMode);
	Mesh.SetRBCollidesWithChannel(RBCC_Vehicle, bRagdollMode);
	Mesh.SetRBCollidesWithChannel(RBCC_Untitled3, !bRagdollMode);
	Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume, bRagdollMode);
}




simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local DroppedPickup DroppedPickup;

	Mesh.MinDistFactorForKinematicUpdate = 0.0;
	Mesh.ForceSkelUpdate();
	Mesh.SetTickGroup(TG_PostAsyncWork);
	CollisionComponent = Mesh;
	CylinderComponent.SetActorCollision(false, false);
	Mesh.SetActorCollision(true, false);
	Mesh.SetTraceBlocking(true, true);
	SetPawnRBChannels(true);
	SetPhysics(PHYS_RigidBody);
	Mesh.PhysicsWeight = 1.f;

	if (Mesh.bNotUpdatingKinematicDueToDistance)
	{
		Mesh.UpdateRBBonesFromSpaceBases(true, true);
	}

	Mesh.PhysicsAssetInstance.SetAllBodiesFixed(false);
	Mesh.bUpdateKinematicBonesFromAnimation = false;
	Mesh.WakeRigidBody();

	// Set the actor to automatically destroy in ten seconds.
	LifeSpan = 20.f;


}
 defaultproperties
{
  	Begin Object Name=WPawnSkeletalMeshComponent
		AnimTreeTemplate=AnimTree'PhoenixGamesDonal.Crano.KazaliteAnimationTree'
		SkeletalMesh=SkeletalMesh'Main_characters_Backup.main_characters_skmesh.Kazalite_main_SKMESH'
		AnimSets(0)=AnimSet'Main_characters_Backup.main_characters_anim.Kazalite_main_Animsets'
		PhysicsAsset=PhysicsAsset'PhoenixGamesDonal.main_characters_physicsassets.Kazalite_main_SKMESH_Physics'
		Scale=0.7
	End Object
        Begin Object Name=CollisionCylinder
      CollisionRadius=+0021.000000
      CollisionHeight=+0042.000000
   End Object
   CylinderComponent=CollisionCylinder
	RagdollLifespan=480.0 //how long the dead body will hang around for


	AirSpeed=200
	GroundSpeed=200

	
	bDontPossess=false
                 HeadShotSocket="HeadShotSocket"
        LegSocketLeft = "LegSocketLeft"
        LegSocketRight = "LegSocketRight"
        TorsoSocket = "TorsoSocket"
        TorsoGibClass = class'ZomGibSkel'
        LegGibClass = class 'ZomGib'
        HeadGibClass = class 'ZomGib'
        Information = "Idle"
	DamageAmount=1

}