There is a lot of buzz around Augmented Reality in Flash and it looks like everywhere 
you turn another person is writing a tutorial about it. I decided to make a tool 
to prototype my Flash AR ideas. The FLAREmulator is a set of classes that encapsulate 
the setup of the FLARToolKit as well as offering a debug mode for you to test your 
markers with or without a webcam. Getting started with Flash Augmented Reality may 
seem daunting but this library is a great way to jump in and see immediate results 
without the fuss of setting up the FlarToolKit or Papervision.

Getting Started

1) Download the source code from GitHub http://github.com/theflashbum/FLAREmulator

2) Link your project to the FLARToolKit.swc and Papervision.swc in the build/libs 
directory.

3) Create a new class and extend FLAREmulator.as

4) Override protected function create3dObjects() and add you PV3d container 
to baseNode:

/**
 * This default function is where 3d Objects should be added to PV3D's
 * scenes. 
 * 
 */			
protected function create3dObjects():void
{
	var plane:Plane = new Plane( new WireframeMaterial( 0xff0000 ), 80, 80 );
	plane.rotationX = 180;
	baseNode.addChild( plane );
}

5) Compile and begin testing!