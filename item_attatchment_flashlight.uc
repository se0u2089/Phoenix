class item_attatchment_flashlight extends UTWeaponAttachment;

defaultproperties
{
	WeaponClass=class'Phoenix.FlashLight'

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'Main_characters.main_characters_weapons_skmesh.Ulari_main_rifle_Skmesh'
		//AnimSets(0)=AnimSet'ZombieWeapons.Mesh.M34A_Anims'
		Scale=0.9
	End Object


	//DefaultImpactEffect=(ParticleTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Impact',DecalMaterials=(),DecalWidth=36.0,DecalHeight=36.0,Sound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue')

//	BulletWhip=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_WhipCue'

	bMakeSplash=true
	MaxFireEffectDistance=55000.0
	MuzzleFlashSocket=MF


        
        //	MuzzleFlashPSCTemplate=ParticleSystem'gaz661-darkarts3dweapons.Effects.asgMuzzleFlash'
	MuzzleFlashDuration=0.66
	MuzzleFlashLightClass=class'Phoenix.TorchMF'

//	WeapAnimType=EWAT_default


}