
/** 
 * <p>Original Author:  Jesse Freeman</p>
 * <p>Class File: FLAREmulator.as</p>
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
 * <p>Redistributions of files must retain the above copyright notice.</p>
 *
 * <p>Revisions<br/> 
 *      2.0  Initial version April 29, 2009</p>
 *
 */
 
 package
{
     import flash.events.MouseEvent;

     import flash.text.TextField;

     import flash.text.TextFormat;

     import org.papervision3d.view.stats.StatsView;

	import com.flashartofwar.flar.core.ARDetector;
	import com.flashartofwar.flar.debug.CardEmulator;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Video;

	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.libspark.flartoolkit.pv3d.FLARBaseNode;
	import org.libspark.flartoolkit.pv3d.FLARCamera3D;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;

	/**
	 * 
	 * @author Jesse Freeman
	 *  
	 */	
	public class FLAREmulator extends Sprite
	{
        protected static const defaultText:String = "Click to change to debug mode - Debug is currently to ";
		protected var scene:Scene3D;
		protected var camera:Camera3D;
		protected var viewport:Viewport3D;
		protected var renderer:BasicRenderEngine;
		protected var cardEmulator:CardEmulator;
		protected var arDetector:ARDetector;
		protected var capturedSrc:Bitmap;
		protected var resultMat:FLARTransMatResult = new FLARTransMatResult( );
		protected var isActive:Boolean = false;
		protected var baseNode:FLARBaseNode;
		protected var debug:Boolean = true;
		protected var webcam:Camera;
		protected var video:Video;
        protected var label:TextField;


		/**
		 * Main Constructor for the class.
		 * 
		 */		
		public function FLAREmulator()
		{
			configureStage( );
			createFlarDetector( );
		}

		/**
		 * Configures the stage and sets the scale mode to keep visuals from
		 * distorting when resizing the browser window.
		 * 
		 */			
		protected function configureStage():void  
		{  
			stage.quality = StageQuality.HIGH;
			stage.align = StageAlign.TOP_LEFT; 
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener( Event.RESIZE, onStageResize ); 
		}

		protected function onStageResize(event:Event = null):void
		{
			if(capturedSrc)
		 		resize( capturedSrc, stage.stageWidth, stage.stageHeight );
			if(viewport)
		 		resize( viewport, stage.stageWidth, stage.stageHeight );
		}

		/**
		 * A function to resize any DisplayObject.
		 *
		 * @param target
		 * @param areaWidth
		 * @param areaHeight
		 * @param aspectRatio
		 * 
		 */		
		public function resize(target:DisplayObject, areaWidth:Number, areaHeight:Number, aspectRatio:Boolean = true, autoCenter:Boolean = true):void 
		{
		 	
			if(aspectRatio) 
			{
		  		
				var sw:Number = areaWidth;
				var sh:Number = areaHeight;
				var tw:Number = target.width;
				var th:Number = target.height;
		  	
				var si:Number;
				//
				if(sw > sh) 
				{
					si = sw / tw;
					if(th * si > sh)
		   			si = sh / th;
				}
				else 
				{
					si = sh / th;
					if(tw * si > sw )
		   			si = sw / tw;
				}
		  	
				var wn:Number = tw * si;
				var hn:Number = th * si;
		  	
				target.width = wn;
				target.height = hn;
			}
			else 
			{
				target.width = areaWidth;
				target.height = areaHeight;
			}
		 	
			if(autoCenter)
			{
				target.x = ((areaWidth * .5) - (target.width * .5));
				target.y = ((areaHeight * .5) - (target.height * .5));
			}
		}

		/**
		 * Creates the AR Detector class and have it load in the camera.data
		 * and pattern.pat files.
		 * 
		 */        
		protected function createFlarDetector():void
		{
			arDetector = new ARDetector( );
			arDetector.addEventListener( Event.COMPLETE, onActivate );
			arDetector.setup( 'data/camera_para.dat', 'data/flarlogo.pat' );
		}

		/**
		 * 
		 */        
		protected function onActivate(event:Event):void
		{
			createCaptureSource( );
			init( );
		}

		/**
		 * Creates a Bitmap for us to scan for valid markers.
		 * 
		 */		
		protected function createCaptureSource():void
		{
			capturedSrc = new Bitmap( new BitmapData( arDetector.width, arDetector.height, false, 0 ), PixelSnapping.AUTO, true );
			arDetector.src = capturedSrc.bitmapData;
			addChild( capturedSrc );
			onStageResize( );
		}

		/**
		 * Called at the construction of the class. Calls the setup Papervision
		 * method and adds an event listener to the render the Viewport.
		 * 
		 */             
		protected function init():void 
		{
			createCaptureSource( );
			createCamera( );
			setupPapervision( );
			addEventListener( Event.ENTER_FRAME, renderViewport );
            createDebugDisplay( );
			stage.addEventListener( MouseEvent.CLICK, onClick );
		}

		/**
		 * Sets up and configures Papervision. This function can be overridden
		 * to accommodate any custom set ups you may need for your project.
		 * 
		 */			
		public function setupPapervision():void
		{
			scene = new Scene3D( );
			camera = new FLARCamera3D( arDetector.flarParam );
		 
			// Create the Viewport
			viewport = new Viewport3D( stage.stageWidth, stage.stageHeight, true );
			addChild( viewport );
		 	
			// The base node is where all PV3D object should be attached to.
			baseNode = new FLARBaseNode( );
			scene.addChild( baseNode );
		 	
			create3dObjects( );
		 	
			renderer = new BasicRenderEngine( );
		 	
			addChild( new StatsView( renderer ) );
		}

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

		/**
		 * Creates a camera or emulator to use as the src for the ARDetector
		 * to analyze for markers.
		 * 
		 */		
		protected function createCamera():void
		{
			if(debug || ! Camera.getCamera( ))
			{
				createEmulatorCard( );	
			}
			else
			{
				webcam = Camera.getCamera( );
				webcam.setMode( arDetector.width, arDetector.height, 30 );
				video = new Video( arDetector.width, arDetector.height );
				video.attachCamera( webcam );
		  		
				trace( "Camera" + Camera.names );
			}
		}

		/**
		 * Creates the emulator card to use in debug mode.
		 * 
		 */
		protected function createEmulatorCard():void
		{
			cardEmulator = new CardEmulator( "images/flarlogo.gif" );
			addChild( cardEmulator );
		}

		/**
		 * Renders the papervision scene.
		 * @param event
		 * 
		 */				
		public function renderViewport(event:Event = null):void
		{	
			updateCaptureBitmap( );
		 
			try
			{
				if (arDetector.detectMarker( )) 
				{
					arDetector.calculateTransformMatrix( resultMat );
					baseNode.setTransformMatrix( resultMat );
					active( );
				}
				else
				{
					inactive( );
				}
			}
		 	catch(errObject:Error) 
			{
				trace( errObject.message );
			}
		 	
			renderer.renderScene( scene, camera, viewport );
		}

		/**
		 * Displays the base node when a marker has been found.
		 */		
		protected function active():void
		{
			if(! isActive)
			{
				isActive = true;
				baseNode.visible = true;
			}
		}

		/**
		 * Hides the base node when a marker can't be found.
		 */		
		protected function inactive():void
		{
			if(isActive)
			{
				baseNode.visible = false;
				isActive = false;
			}
		}

		/**
		 * Updates the capturedSrc with new bitmap data.
		 * 
		 */		
		protected function updateCaptureBitmap():void
		{
			if(debug || ! video)
			{
				cardEmulator.render( );
				capturedSrc.bitmapData.draw( cardEmulator.viewport );
			}
			else
			{
				capturedSrc.bitmapData.draw( video );
			}
		}

        /**
		 * Switches the active source from the CardEmulator to the Webcam.
		 *
		 */
		public function switchSource():void
		{
			if(debug)
			{
				if(contains( cardEmulator ))
				{
					removeChild( cardEmulator );
					cardEmulator = null;
				}
			}
			else
			{
				video = null;
				webcam = null;
			}

			debug = ! debug;
			
			createCamera( );
		}


        /**
         * Sets up a display to let us know what mode we are in.
         *
         */
        protected function createDebugDisplay():void
        {
            label = new TextField( );
            label.defaultTextFormat = new TextFormat( "Arial", 12, 0x000000, true );
            label.autoSize = "right";
            label.selectable = false;
            label.background = true;
            label.text = defaultText + debug;

            label.x = stage.stageWidth - label.width;
            addChild( label );
        }

        /**
         * Class switch source when a click event is recieved.
         * @param event
         *
         */
        protected function onClick(event:MouseEvent):void
        {
            switchSource( );
            label.text = defaultText + debug;
        }
        
	}
}