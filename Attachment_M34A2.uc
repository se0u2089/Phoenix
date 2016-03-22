
class Attachment_M34A2 extends UTAttachment_LinkGun;

var AdvKitPlayerController PC;

var DemoPawn PawnOwner;
var Pawn P;
  var particleSystem BeamTemplates[2];
 var name EndPointParamName;
/** Holds the Emitter for the Beam */
 var ParticleSystemComponent	MuzzleFlashPSC;
var ParticleSystem			MuzzleFlashPSCTemplate, MuzzleFlashAltPSCTemplate;
var color					MuzzleFlashColor;
var bool					bMuzzleFlashPSCLoops;

/** dynamic light */
var class<UDKExplosionLight> MuzzleFlashLightClass;
var	UDKExplosionLight		MuzzleFlashLight;
var ParticleSystemComponent BeamEmitters[2];

/** Where to attach the Beam */
  var ParticleSystemComponent BeamEmitter[2];
var name BeamSockets[2];
var name ReloadANIM, ReloadANIMEMPTY;

simulated function HideEmitter(int Index, bool bHide)
{
	local color EffectColor;
	local LinearColor LinEffectColor;

//	Super.HideEmitter(Index, bHide);

	if (Index == 1 && bHide)
	{
		// reset material and muzzle flash to default color
	//	GetTeamBeamInfo(255, EffectColor);
	//	if (WeaponMaterialInstance != None)
	//	{
	//		LinEffectColor = ColorToLinearColor(EffectColor);
	//		WeaponMaterialInstance.SetVectorParameterValue('TeamColor', LinEffectColor);
	//	}
		if (MuzzleFlashPSC != None)
		{
			MuzzleFlashPSC.ClearParameter('Link_Beam_Color');
		}

	//	KillEndpointEffect();
	}
}


simulated function AttachTo(UTPawn OwnerPawn)
{
        local DemoPawn MP;

        MP = DemoPawn(Owner);
        SetWeaponOverlayFlags(OwnerPawn);

	if (OwnerPawn.Mesh != None)
	{
		// Attach Weapon mesh to player skelmesh
		if ( Mesh != None )
		{
			OwnerMesh = OwnerPawn.Mesh;
			AttachmentSocket = OwnerPawn.WeaponSocket;

			// Weapon Mesh Shadow
			Mesh.SetShadowParent(OwnerPawn.Mesh);
			Mesh.SetLightEnvironment(OwnerPawn.LightEnvironment);

			if (OwnerPawn.ReplicatedBodyMaterial != None)
			{
				SetSkin(OwnerPawn.ReplicatedBodyMaterial);
			}

			OwnerPawn.Mesh.AttachComponentToSocket(Mesh, OwnerPawn.WeaponSocket);
		}

		if (OverlayMesh != none)
		{
			OwnerPawn.Mesh.AttachComponentToSocket(OverlayMesh, OwnerPawn.WeaponSocket);
		}
	}

	if (MuzzleFlashSocket != '')
	{
		if (MuzzleFlashPSCTemplate != None || MuzzleFlashAltPSCTemplate != None)
		{
			MuzzleFlashPSC = new(self) class'UTParticleSystemComponent';
			MuzzleFlashPSC.bAutoActivate = false;
			MuzzleFlashPSC.SetOwnerNoSee(true);
			Mesh.AttachComponentToSocket(MuzzleFlashPSC, MuzzleFlashSocket);
		}
	}


      //  MP.M34AAnim();
      //  MP.WeaponEquip();
	GotoState('CurrentlyAttached');
}

simulated function AddBeamEmitter()
{
	local int i;

	for( i=0; i<2; ++i )
	{
		if( BeamTemplates[i] != none )
		{
			BeamEmitters[i] = new(self) class'UTParticleSystemComponent';
			BeamEmitters[i].SetTemplate(BeamTemplates[i]);
			BeamEmitters[i].bAutoActivate = false;
			BeamEmitters[i].SetTickGroup( TG_PostAsyncWork );
			BeamEmitters[i].bUpdateComponentInTick = true;
			BeamEmitters[i].SetOwnerNoSee(true);
			Mesh.AttachComponentToSocket(BeamEmitters[i], BeamSockets[i]);
		}
	}
}

simulated function UpdateBeam(byte FireModeNum)
{
	// Make sure the Emitter is visible
	if (BeamEmitter[FireModeNum] != None)
	{
		BeamEmitter[FireModeNum].SetVectorParameter(EndPointParamName , PawnOwner.FlashLocation);
	}

	HideEmitter(FireModeNum, false);
	HideEmitter(Abs(FireModeNum - 1), true);
}

  state CurrentlyAttached
{
	simulated function BeginState(Name PreviousStateName)
	{
		PawnOwner = DemoPawn(Owner);
		if( PawnOwner == none )
		{
			LogInternal("ERROR:"@self@"found without a valid UTPawn Owner");
			return;
		}

		AddBeamEmitter();
	}
	
	simulated function Tick(float DeltaTime)
	{
		// If we aren't firing or the owner and its not splitscreen, hide the emitter
		if((PawnOwner == None)
		|| (PawnOwner.IsFirstPerson() && !class'Engine'.static.IsSplitScreen())
		||  PawnOwner.FlashLocation == vect(0,0,0) )
		{
			SetBeamEmitterActive(0,false);
			SetBeamEmitterActive(1,false);
			return;
		}

		UpdateBeam(PawnOwner.FiringMode);
	}
}

simulated function SetBeamEmitterActive(int Index, bool bActive)
{
	if( BeamEmitters[Index] != None )
	{
		BeamEmitters[Index].SetActive(bActive);
	}
}

simulated function DetachFrom( SkeletalMeshComponent MeshCpnt )
{

        local DemoPawn MP;
        MP = DemoPawn(Owner);
        SetSkin(None);

	// Weapon Mesh Shadow
	if ( Mesh != None )
	{
		Mesh.SetShadowParent(None);
		Mesh.SetLightEnvironment(None);
		// muzzle flash effects
		if (MuzzleFlashPSC != None)
		{
			Mesh.DetachComponent(MuzzleFlashPSC);
		}
		if (MuzzleFlashLight != None)
		{
			Mesh.DetachComponent(MuzzleFlashLight);
		}
	}
	if ( MeshCpnt != None )
	{
		// detach weapon mesh from player skelmesh
		if ( Mesh != None )
		{
			MeshCpnt.DetachComponent( mesh );
		}

		if ( OverlayMesh != none )
		{
			MeshCpnt.DetachComponent( OverlayMesh );
		}
	}
    //    MP.DefaultAnim();
     //   MP.WeaponChange();
	GotoState('');
}


simulated function ReloadANIMS()
{
     local DemoPawn MP;
     MP = DemoPawn(Owner);

   //  Mesh.PlayAnim('Reload',,, false);

     if(MP.EmptyWeapon == true)
     {
 //      Mesh.PlayAnim('ReloadEmpty',,, false);
     }

}
simulated function ThirdPersonFireEffects(vector HitLocation)
{
	local DemoPawn P;
	if ( EffectIsRelevant(Location,false,MaxFireEffectDistance) )
	{
		// Light it up
		CauseMuzzleFlash();
	}

	// Have pawn play firing anim
	P = DemoPawn(Instigator);
	if (P != None && P.GunRecoilNode != None)
	{
		// Use recoil node to move arms when we fire
		P.GunRecoilNode.bPlayRecoil = true;
	}

	if (Instigator.FiringMode == 1 && AltFireAnim != 'None')
	{
		Mesh.PlayAnim(AltFireAnim,,, false);
	}
	else if (FireAnim != 'None')
	{
		Mesh.PlayAnim(FireAnim,,, false);
	}
}

simulated event StopThirdPersonFireEffects()
{
	StopMuzzleFlash();
}

defaultproperties
{
        WeaponClass=class'M34A2'
        WeapAnimType=EWAT_Stinger
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'Characters.gun_low_poly_final'
		//AnimSets(0)=AnimSet'ZombieWeapons.Mesh.M34A_Anims'
	//	Animations=MeshSequenceA
		Scale=1
	End Object
	BulletWhip=none
	bMakeSplash=true


       	BeamTemplate[1]=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam'
	BeamSockets[1]=MuzzleFlashSocket02
	EndPointParamName=LinkBeamEnd

	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Gun_MuzzleFlash'
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'Phoenix.Riflefirelight'
	DefaultImpactEffect=(DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact',Sound=SoundCue'GearWeapon_Impact.Sounds_Bullet.WP_BulletImpact_Concrete')
	
    ImpactEffects(0)=(MaterialType="Dirt",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(1)=(MaterialType="Gravel",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(2)=(MaterialType="Sand",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(3)=(MaterialType="Dirt_Wet",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(4)=(MaterialType="Energy",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(5)=(MaterialType="WorldBoundary",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(6)=(MaterialType="Flesh",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(7)=(MaterialType="Flesh_Human",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(8)=(MaterialType="Lava",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(9)=(MaterialType="NecrisVehicle",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(11)=(MaterialType="Foliage",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact',Sound=SoundCue'GearWeapon_Impact.Sounds_Bullet.WP_BulletImpact_Concrete')
    ImpactEffects(12)=(MaterialType="Glass",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MI_Bullet_Wood'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(13)=(MaterialType="Liquid",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(14)=(MaterialType="Water",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'Envy_Effects.Particles.P_WP_Water_Splash_Small')
    ImpactEffects(15)=(MaterialType="ShallowWater",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'Envy_Effects.Particles.P_WP_Water_Splash_Small')
    ImpactEffects(17)=(MaterialType="Slime",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(18)=(MaterialType="Metal",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MI_Bullet_Metal'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact',Sound=SoundCue'GearWeapon_Impact.Sounds_Bullet.WP_BulletImpact_Metal')
    ImpactEffects(19)=(MaterialType="Snow",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MIl_Bullet_Concrete'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact')
    ImpactEffects(20)=(MaterialType="Wood",DecalMaterials=(MaterialInstanceConstant'GearWeapon_Impact.Bullet.MI_Bullet_Wood'),DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000,ParticleTemplate=ParticleSystem'GearWeapon_Impact.Effects.P_WP_Pistol_MuzzleFlash_Impact',Sound=SoundCue'GearWeapon_Impact.Sounds_Bullet.WP_BulletImpact_Wood')

    ProjExplosionTemplate=ParticleSystem'ZombiesMonsters.Effects.Bloodhit'
	

}