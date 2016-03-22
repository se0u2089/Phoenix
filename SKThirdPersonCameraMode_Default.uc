class SKThirdPersonCameraMode_Default extends GameThirdPersonCameraMode_Default;

/** Returns FOV that this camera mode desires. */
function float GetDesiredFOV( Pawn ViewedPawn )
{
	return 70.0;
}

defaultproperties
{
    ViewOffset={(

       OffsetLow=(X=-400,Y=98,Z=156),
       OffsetMid=(X=-400,Y=98,Z=136),
        OffsetHigh=(X=-576,Y=96,Z=130),
    )}




}