class FlashLight extends AimableWeaponClass;



var float LightAttachmentInterval;
var float LightOnInterval;
 var SkeletalMeshComponent SKMesh;
var SpotLightComponent LightAttachment; // The actual light

var name Light_Socket; //the name of the socket to attach to


var bool IsLightOn; // boolean to turn light on and off


simulated function PostBeginPlay()
{

SKMesh.AttachComponentToSocket(LightAttachment, 'LightSocket');

}


exec function TurnOnLight()
{

 if (IsLightOn)
               LightAnimOff();
      else
           LightAnimOn() ;
}



function    LightAnimOn()
{
SetTimer(LightOnInterval, false, 'LightIsOn');
}



function LightAnimOff()
   {
   SetTimer(LightOnInterval, false, 'LightIsOff');
   }


function LightIsOn()
{
IsLightOn = true;
//SkeletalMeshComponent(Mesh).AttachComponentToSocket(LightAttachment,LightSocket);
SKMesh.AttachComponentToSocket(LightAttachment, 'LightSocket');
SetTimer(2.0,false);
}


function LightIsOff()
{
IsLightOn = false;
//SkeletalMeshComponent(Mesh).DetatchComponent(LightAttachment);
SKMesh.DetachComponent(LightAttachment);
SetTimer(LightAttachmentInterval,false,'Inactive');
}








defaultproperties
{
AttachmentClass=class'item_attatchment_flashlight'
 //MuzzleFlashLightClass=class'TorchMF'
 	MuzzleFlashLightClass=class'Phoenix.MyGameFlashlight'
 InstantHitDamageTypes(0)=class'TorchDmgType


Begin Object class=SpotLightComponent Name=TorchLightComponent

End Object


LightAttachment=TorchLightComponent
//get a reference to the object
//Flashlight=MyLightComponent

//the name of the socket
Light_Socket="LightSocket"

 SKMesh=FirstPersonMesh

// Weapon SkeletalMesh
Begin Object Name=FirstPersonMesh
	SkeletalMesh=SkeletalMesh'Main_characters_Backup.main_characters_weapons_skmesh.Ulari_main_rifle_Skmesh'
AnimSets(0)=none
Animations=none
Rotation=(Yaw=-16384)
FOV=60.0
End Object


Begin Object Name=PickupMesh
	SkeletalMesh=SkeletalMesh'Main_characters_Backup.main_characters_weapons_skmesh.Ulari_main_rifle_Skmesh'
	//	WeaponSocketName=WeaponPoint
	AttachmentClass=class'item_attatchment_flashlight'
Components.Add(MyLightEnvironment)
End Object


 	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'WP_ShockRifle_PhysX.Particles.P_WP_ShockRifle_Beam_Impact', Sound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue')


}