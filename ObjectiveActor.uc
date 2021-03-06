class ObjectiveActor extends ZomPickableActors placeable;

var() bool bActive;
var() bool bIsObjective;

var() string ObjectiveTag;
var() string NextObjectiveTag;

//Activate a specific KismetLevelEvent
var() name KismetEventToActivate;
var() float Height;

//Mostly a reference to level designers to see which one is to be done first.
var() int ObjectivePriority;
//Message to Display when completed.
var() string MessageToDisplay;
var() string MissionObjectiveInfo;

//If the current objective is one that must be reached not used.
var() bool bTouchObjective;
var() bool bDestroyObjective;

var() float Health;
var() float MaxHealth;
var() bool bDangerous;
var(Dangerous) float DamageRadius;
var(Dangerous) float BaseDamage;


var() int ScoreToGive;

event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);

  if(bTouchObjective == true)
  {

    PC = AdvKitPlayerController(DemoPawn(Other).Controller);
    if (Pawn(Other) != none)
    {
        DisplayHUDText();
        ObjectiveCompleted();
        PlaySound(PickUpSound);
        self.Destroy();
	IsInInteractionRange = true;
    }
  }
  else
  {
  }
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    local ObjectiveActor OA;
    super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

   if(bActive == true)
   {
     if(bDestroyObjective == false )
     return;
      Health = FMax(Health-Damage,0);

       if (Health <= 0)
        {
           if(bDangerous == true)
           {
              HurtRadius (BaseDamage,DamageRadius,DamageType,9900,Location,None,InstigatedBy,false);
           }
           
           PC.CurrentObjective += 1;
           PC.ShowCredits(ScoreToGive);
           PC.Credits += ScoreToGive;
           PlaySound(PickUpSound);

           TriggerRemoteKismetEvent(KismetEventToActivate);
           foreach AllActors(class'ObjectiveActor', OA)
           {
           if(OA.ObjectiveTag == NextObjectiveTag )
           {
           OA.bActive = true;
           }
           }

           DisplayHUDText();
           self.Destroy();
        }

   }
}


function bool UsedBy(Pawn User)
{
   local bool used;

  if(bActive == false)
  {

  }
  else
  {

    used = super.UsedBy(User);
    if(bDestroyObjective == true )
    {
    }
    else
    {
       if (IsInInteractionRange)
       {
          PickedUp();
          PlaySound(PickUpSound);
          DisplayHUDText();
          ObjectiveCompleted();
        //  UIMesh.Destroy();
          self.Destroy();
          return true;
       }

     return used;
    }
  }
}

function DisplayHUDText()
{
  //PC.DebugHUD(MessageToDisplay);
}

function ObjectiveCompleted()
{
   local ObjectiveActor OA;
   PC.CurrentObjective += 1;
   PC.ShowCredits(ScoreToGive);
   PC.Credits += ScoreToGive;


   TriggerRemoteKismetEvent(KismetEventToActivate);
   foreach AllActors(class'ObjectiveActor', OA)
   {
      if(OA.ObjectiveTag == NextObjectiveTag )
      {
         OA.bActive = true;
      }
   }
   self.Destroy();
}

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

defaultproperties
{
    bBlockActors=true
    bHidden=false
    bActive = true
    bIsObjective = true
    bNoDelete=false
    bTouchObjective = false
}
//SimpleObjective marker looked for in the HUD.