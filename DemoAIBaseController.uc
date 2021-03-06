

class DemoAIBaseController extends GameAIController;


var Actor Target;
var() Vector TempDest;

var int CreditWorth;

var DemoPawn Player1;
var DemoAIBasePawn P;

var DemoPlayerController PlayerCon;
var bool bheadshot;
var float HearingDistance;
var bool Seen1Player;

var float DistanceToPlayer;
var float AttackDistance;
// Zombie sound variables
var() SoundCue FollowSound; // Only heard in third person however there is no third person.
var() SoundCue AttackSound;
var Vector MTarget;
var int OffsetX;
var int OffsetY;
var bool Alerted;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
}


function CalculateFinalHealth()
{
   if(Pawn.Health <= 0)
   {
     ConsoleCommand("Suicide");
   }
}


//***************************************************************
// Possibly the most active state although he is idle
// Does a lot of the checking to see if player is initially there
// or if enemy zombies are around / Hated Zombies. Added to avoid accessed non errrors
//***************************************************************

auto state Idle
{
    event SeePlayer (Pawn Seen)
    {
         local float Distance;

        super.SeePlayer(Seen);

       

        Target = Seen;
        Seen1Player = true;

        Distance = Vsize(Target.Location - Pawn.Location);
        P = DemoAIBasePawn(Pawn);

        if(Distance < P.SightDistance )
        {
        GotoState('Follow');
        PlaySound(SoundCue'ZombiesSounds.Moan.zombiemoan_Cue');

        if(Alerted == false )
        {
           SetTimer(1.0, false ,'AlertNearbyZombies');
        }

         if(Pawn.Health <= 0)
                            {
                              Pawn.Destroy();
                              Destroy();
                            }
        }
    }
    



Begin:


  P = DemoAIBasePawn(Pawn);

  if (P.bRandomMovement == true) // If randome/active movement is set to true
  {
     //make a random offset, some distance away
     OffsetX = Rand(500)-Rand(500);
     OffsetY = Rand(500)-Rand(500);

       //some distance left or right and some distance in front or behind
     MTarget.X = Pawn.Location.X + OffsetX;
     MTarget.Y = Pawn.Location.Y + OffsetY;
       //so it doesnt fly up n down
       MTarget.Z = Pawn.Location.Z;

      GoToState('MoveAbout');
   }
}

 function AlertNearbyZombies( float DistanceToAlert)
 {
       local DemoAIBasePawn ZAI;
       
       foreach VisibleCollidingActors(class'DemoAIBasePawn', ZAI, 1200)
       {

           ZAI.Alert();

       }
}

function Alert()
{
  local DemoPawn PersonToKill;

  if(Alerted == false)
  {
    foreach AllActors(class'DemoPawn', PersonToKill)
    {
      Target = PersonToKill;
      GoToState('Follow');
      
      Alerted = true;
    }
  }
  else
  return;
}

state MoveAbout
{
   // If you see the player while randomly moving...
  event SeePlayer (Pawn Seen)
    {
         local float Distance;
        
        super.SeePlayer(Seen);
        Target = Seen;
        Seen1Player = true;
        


        Distance = Vsize(Target.Location - Pawn.Location);
        P = DemoAIBasePawn(Pawn);
        // Check how far away you are first....
        if(Distance < P.SightDistance )
        {
        GotoState('Follow');
        //Incase you died but you dont know it...
         if(Pawn.Health <= 0)
                            {
                              Pawn.Destroy();
                              Destroy();
                            }
        }
         
    }

Begin:

    P = DemoAIBasePawn(Pawn);

    MoveTo(MTarget);
    Sleep(P.RandomInterval);
    GoToState('Idle');
}


state Follow
{
    ignores SeePlayer;
    function bool FindNavMeshPath()
    {
        // Clear cache and constraints (ignore recycling for the moment)
        NavigationHandle.PathConstraintList = none;
        NavigationHandle.PathGoalList = none;

        // Create constraints
        class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle, Target );
        class'NavMeshGoal_At'.static.AtActor( NavigationHandle, Target,32 );

        // Find path
        return NavigationHandle.FindPath();
    }
Begin:

    

    if( NavigationHandle.ActorReachable( Target) )
    {
        FlushPersistentDebugLines();
        //Direct move
        MoveToward( target,target );
        
        if(Pawn.Health <= 0 || P == None)
                            {
                              Destroy();
                              P.Destroy();
                            }
    }
    else if( FindNavMeshPath() )
    {


        NavigationHandle.SetFinalDestination(Target.Location);
        FlushPersistentDebugLines();
        //NavigationHandle.DrawPathCache(,TRUE);
        
        // move to the first node on the path
        if(!NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()))
        {
          GoToState('Begin');
        }
        else if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
        {
            if ( !NavigationHandle.GetNextMoveLocation ( TempDest, Pawn.GetCollisionRadius()))
            {
              MoveToward( target,target );
              GoTo('Begin');
            }
            else
            {
               //DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
               //DrawDebugSphere(TempDest,16,20,255,0,0,true);
               MoveTo( TempDest);
            }
        }
    }

    else
    {
        //We can't follow, so get the hell out of this state, otherwise we'll enter an infinite loop.
        GotoState('Idle');
        Seen1Player = false;
    }  //Check Attack distance...
    if (VSize(Pawn.Location - target.Location) <= 106)
{
    GotoState('Attacking'); //Start attacking when close enough to the player.
}
else
{
    goto 'Begin';
}

}

state SuprisedState
{
   function Suprise()
{

   local DemoAIBasePawn ZG;

   ZG = DemoAIBasePawn(Pawn);


   WorldInfo.Game.Broadcast(self,"Suprised!!!");

   //ZG.FullBodyAnimSlot.PlayCustomAnim('SupriseLook', 1.0, 0.2, 0.2, false, TRUE);

   foreach VisibleCollidingActors(class'DemoPawn', Player1, 845)
   //** Search for pawn within a certain radius and turn around to where the shot
   //** originated from.
   {

       if(Player1 != None)//** Continually check to make sure the Player is still connected.
       {
          Pawn.SetDesiredRotation(Rotator(Normal(Player1.Location)));
          GotoState('Idle');//** Going to state idle will allow for the pawn to "SEE" the player when the zombie turns around.
       }
   }
}
   Begin:

   Suprise();

}

state HeardNoise //Hearing Treshhold is generally 1000 can be edited in the editor...

{


      function CheckNoise()
      {
         local DemoAIBasePawn ZG;

         ZG = DemoAIBasePawn(Pawn);

         if(Seen1Player == true)
         {
         }
         else
         {
              foreach AllActors(class'DemoPlayerController', PlayerCon)
              {

               if (PlayerCon.MadeNoise == true)
               {
                                                                            //doubling hearing treshhold. Seems more realistic
                   foreach VisibleCollidingActors (class'DemoPawn',Player1, 2000)
                        {
                            Pawn.SetDesiredRotation(Rotator(Normal(Player1.Location)));
                            PlayerCon.MadeNoise = false;

                            //** Going to state idle will allow for the pawn to "SEE" the player when the zombie turns around.
                        }

               }

               } // Play that awesome suprised look.. like huh what... who there?
 //  ZG.TopHalfAnimSlot.PlayCustomAnim('SupriseLook', 1.0, 0.2, 0.2, false, TRUE);
         }
      }


      Begin:
         Sleep(0.f);
         CheckNoise();
         GoToState('Idle');
         // Again if we dont know we are dead... kill ourselves
         if(Pawn.Health <= 0)
                            {
                              ConsoleCommand("Suicide");
                            }



}

state Attacking
{

    function TakePlayerDamage()
    {
       local DemoAIBasePawn ZG;

       ZG = DemoAIBasePawn(Pawn);


       if (Target != None) //** Continualy check if player is still alive
       {

                 `log("IM HURTING YOU!!!!");// 10 damage should be enough, because 20 zombies attacking you may get pretty bad.
                 Target.TakeDamage(10, self, Location, vect(0,0,0), class'DmgType_Crushed');
                 PlaySound(AttackSound);
     ZG.TopHalfAnimSlot.PlayCustomAnim('KazaliteAxeAttack_CorrectedFBX01', 1.0, 0.2, 0.2, false, true); //Play attack animation

       }
       else
       {
         //Nothing
       }
    }
    Begin:
        Sleep(0.5);
        TakePlayerDamage();
        GoToState('Idle');
}

defaultproperties
{
  AttackDistance = 200
  FollowSound = SoundCue'ZombiesSounds.Moan.zombiemoan_Cue'
  AttackSound = SoundCue'ZombiesSounds.ATTACK.AttackSnarl_Cue'
  CreditWorth = 200
  Seen1Player = false
  bheadshot = false
  Alerted = false
}