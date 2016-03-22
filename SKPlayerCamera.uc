/**
 * Camera that provides third person functionality for the "classic" third person view
 * 
 * Thanks a bunch to Psilocybe for this tutorial:
 * http://forums.epicgames.com/threads/726985-Tutorial-Third-Person-Game-with-GOW-camera
 * Note that I only use the basic functionality explained in the tutorial, 
 * take a look to find out more!
 *
 * 2013 by FreetimeCoder
 * www.freetimestudio.net
 */
class SKPlayerCamera extends GamePlayerCamera;




protected function GameCameraBase FindBestCameraType(Actor CameraTarget)
{
	return ThirdPersonCam; // could have other camera options
}



DefaultProperties
{
    ThirdPersonCameraClass=class'SKThirdPersonCamera'
    ThirdPersonCamOffset=(x=0, y=0, z=0) 
}