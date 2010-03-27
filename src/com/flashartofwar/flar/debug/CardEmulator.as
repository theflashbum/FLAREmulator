/** 
 * <p>Original Author:  Jesse Freeman</p>
 * <p>Class File: CardEmulator.as</p>
 * 
 * <p>Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:</p>
 * 
 * <p>The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.</p>
 * 
 * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.</p>
 * 
 * <p>Licensed under The MIT License</p>
 * <p>Licensed under The MIT License</p>
 * <p>Redistributions of files must retain the above copyright notice.</p>
 *
 * <p>Revisions<br/> 
 *      2.0  Initial version April 29, 2009</p>
 *
 */
 
 package com.flashartofwar.flar.debug
{
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.BitmapViewport3D;

	import flash.display.Sprite;

	/**
 	 *	The CardEmulator represent a simple system for testing an AR Marker with
 	 * needing to use a webcam as a source. This class creates an instance of a
 	 * Papervision 3D renderer, viewport and scene with a simple 3d plane skinned
 	 * with a texture of your marker. When render is called the mouse is tracked
 	 * and the plane is adjusted to test your pattern at different angles.

 	 * 
 	 * This since this class requires a reference to stage for the mouse
 	 * calculations you must attach it to the stage or another display object.
 	 * In cases when you don't want to see the viewport you can optionally toggle
 	 * addViewportToDisplay in the constructor.
 	 *  
 	 * @author Jesse Freeman
 	 * 
 	 */
 	public class CardEmulator extends Sprite
 	{
  		
  		protected var _width:Number = 0;
  		protected var _height:Number = 0;
  		protected var testMarkerURL:String;
  		protected var emulatorViewport:BitmapViewport3D;
  		protected var emulatorRenderer:BasicRenderEngine;
  		protected var emulatorScene:Scene3D;
        protected var emulatorCamera:Camera3D;
        protected var testCard : Plane;
  		protected var addViewportToDisplay:Boolean = false;
  		
          /**
           * Returns an instance of the viewport as a BitmapViewport3d object.
           * 
           * @return BitmapViewport3D and can be used to sample BitmapData from.
           * 
           */		
          public function get viewport():BitmapViewport3D
          {
           	return emulatorViewport;
           }
          
  		/**
  		 *  Constructs the emulator environment. We need a url to the test
  		 * marker, a width and a height.
  		 * 
  		 * @param testMarkerURL loads in a sample test marker image.
  		 * @param w width of the emulators display - default 320.
  		 * @param h height of the emulators display - default 240.
  		 * @param addViewportToDisplay tells the emulator if it should attach 
  		 * the viewport to the display or not. In most cases you would not want
  		 * to set this to true unless you are testing that the Emulator is 
  		 * actually displaying and working.
  		 * 
  		 */        
  		public function CardEmulator(testMarkerURL:String, w:Number = 320, h:Number = 240, addViewportToDisplay:Boolean = false)
  		{
   			this.testMarkerURL = testMarkerURL;
   			_width = w;
   			_height = h;
   			this.addViewportToDisplay = addViewportToDisplay;
   			init();
   		}
  		
  		/**
  		 * @private
  		 * 
  		 * On init we create the emulators viewport, render scene and camera.
  		 * We also attach a testCard (plane) to the scene to act as our sample
  		 * pattern.
  		 * 
  		 */		
  		protected function init():void
  		{
   			// Setup PV3D
   			emulatorViewport = new BitmapViewport3D(_width, _height);
              	emulatorRenderer = new BasicRenderEngine();
               emulatorScene = new Scene3D();
               emulatorCamera = new Camera3D();
   			
   			// Create test pattern plane
   			var bmpMaterial:BitmapFileMaterial = new BitmapFileMaterial(testMarkerURL, true);	
   				bmpMaterial.doubleSided = true;
   				
   			testCard = new Plane(bmpMaterial, 300, 300, 4, 4);
   			
   			// Make the camera face the testCard
   			emulatorCamera.target = testCard;
   			emulatorScene.addChild( testCard );
   			
   			// Make sure we should add this to the display
   			if(addViewportToDisplay)
   				addChild(emulatorViewport);
   		}
  		
  		/**
  		 * 
  		 * Here we take the mouse's movement and rotate the camera 
  		 * accordingly. This assumes that the CardEmulator instance has a 
  		 * reference to the stage.
  		 * 
  		 */		
  		protected function calculateMouseMovement():void
  		{
   			if(stage)
   			{
    				var rotY: Number = (mouseY-(stage.stageHeight/2))/(stage.height/2)*(2200);
    				var rotX: Number = (mouseX-(stage.stageWidth/2))/(stage.width/2)*(-2200);
    				emulatorCamera.x = emulatorCamera.x + (rotX - emulatorCamera.x) / 2;
    				emulatorCamera.y = emulatorCamera.y + (rotY - emulatorCamera.y) / 2;

    			}
   		}
  		
  		/**
  		 * 
  		 * When a render is called we calculate the mouseMovement then render
  		 * out the scene.
  		 * 
  		 */		
  		public function render():void
  		{
   			calculateMouseMovement();
   			emulatorRenderer.renderScene(emulatorScene, emulatorCamera, emulatorViewport);
   		}
   		
   		protected function updateMouseRotation() : void {

        }        

  	}
}