//******************************************************************
//**  Copyright JonathanVGames 2011
//**  Jonathan "TheAgent" Vazquez
//**  jonathanvgames@hotmail.com
//**  ZombieGame FullSource
//**


class ZomGibHead extends KActorSpawnable abstract;




simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	AddSomeImpulse();
}

function AddSomeImpulse()
{
   local vector ImpulsePower;


   ImpulsePower.X = 5;
   ImpulsePower.Y = 0;
   ImpulsePower.Z = 5;
   

   StaticMeshComponent.AddImpulse(ImpulsePower);
   SetTimer(0.6, false, 'SpawnDecalBlood');
}

function SpawnDecalBlood()
{
        local Rotator DownRot;
	local Vector DLocation;
        local DecalMaterial BloodDecal;

        DLocation = self.Location;

	DownRot.Pitch=-9195.0;
	DownRot.Roll=0;
	DownRot.Yaw=0; 
        BloodDecal = new(self) class'DecalMaterial';
        BloodDecal = DecalMaterial'T_FX.DecalMaterials.M_FX_BloodDecal_FadeViaDissolving';
	`Log("Can I spawn decals in gameinfo1?"@WorldInfo.MyDecalManager.CanSpawnDecals()); //returns true
	
	WorldInfo.MyDecalManager.SpawnDecal(BloodDecal, DLocation, DownRot, 100, 100, 150, false);

}

defaultproperties
{
	  Begin Object Name=MyLightEnvironment
		  bEnabled=True
	  End Object

	  Begin Object Name=StaticMeshComponent0
//	StaticMesh = StaticMesh'ZombiesMonsters.ZombieGen.ZombieGenHead'
	Scale = 0.8
	bNotifyRigidBodyCollision = true
        End Object
        
        Components.Add(StaticMeshComponent0)
        CollisionComponent = StaticMeshComponent0
        
        bBounce = true
        bCollideWorld = true
        bCollideActors = true
        bBlockActors = false
        Physics = PHYS_RigidBody
        CollisionType=COLLIDE_BlockAll
        
        

      bWakeOnLevelStart = true;
      // bNoEncroachCheck MUST BE FALSE here for Touch event can work
      bNoEncroachCheck = false;
}