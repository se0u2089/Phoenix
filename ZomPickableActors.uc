class ZomPickableActors extends Trigger;

var() const editconst DynamicLightEnvironmentComponent LightEnvironment;

var() const string Prompt;
var bool IsInInteractionRange;

var()		SoundCue			PickupSound;
var             AdvKitPlayerController            PC;

var () StaticMesh                       GfxMesh;
var () vector		                TranslationOffset;
var () array<MaterialInterface>         Materials;
var () TextureRenderTarget2D            RenderTexture;
//var UIMesh                 UIMesh;

var GFxProjectedItemUI MovieUI;

var() SwfMovie Movie;

 simulated event PostBeginPlay()
{

  Super.PostBeginPlay();

}


function bool UsedBy(Pawn User)
{
    local bool used;
    used = super.UsedBy(User);
    if (IsInInteractionRange)
    {
        PickedUp();
      //  UIMesh.Destroy();
        self.Destroy();
        return true;
    }
    return used;
}

function PickedUp(){ /*PickUp function modified from extending classes*/ }


DefaultProperties
{

    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bEnabled=TRUE
    End Object

     LightEnvironment=MyLightEnvironment
    Components.Add(MyLightEnvironment)


    Begin Object class=StaticMeshComponent Name=MyMesh
        CollideActors = False
        BlockActors = false
        BlockRigidBody = False
        StaticMesh=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy__BASE_SHORT'
        Scale = 1
    End Object

    bStatic = false
    bHidden = false
    bNoDelete=false
    CollisionComponent=MyMesh
    Components.Add(MyMesh)
    Components.Remove(Sprite)

    PickUpSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_RocketLoaded_Cue'
}