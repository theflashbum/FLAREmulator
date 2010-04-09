
/** 
 * <p>Original Author:  Jesse Freeman</p>
 * <p>Class File: ARDetector.as</p>
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
 
package com.flashartofwar.flar.core {
	import org.libspark.flartoolkit.core.FLARCode;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.libspark.flartoolkit.detector.FLARSingleMarkerDetector;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	/**
	 * The ARDetector is a manager for the FLARToolKit and helps facilitate
	 * the setup, configuration, and detection of markers while using the 
	 * FLARToolKit's underlining core classes.
	 * 
	 * This class is a modification of an example on 
	 * http://saqoosha.net/en/flartoolkit/start-up-guide
	 * 
	 * 
	 * @author Jesse Freeman
	 * 
	 */	
	public class ARDetector extends EventDispatcher implements IARDetector
	{

		protected var cameraURL:String;
		protected var markerURL:String;
		protected var codeWidth:int;
		protected var _flarParam:FLARParam;
		protected var code:FLARCode;
		protected var raster:FLARRgbRaster_BitmapData;
		protected var detector:FLARSingleMarkerDetector;

        public var width:int;
		public var height:int;
		public var markerWidth:Number = 16;
		public var markerHeight:Number = 16;

		/**
		 * 
		 * This is the ARDetector consturctor. By default we set the width and
		 * height to 320 x 240 to match our video source.
		 * 
		 * @param canvasWidth set to 320 by default
		 * @param canvasHeight set to 240 by default
		 * @param codeWidth set to 80 by default. This represents the width of the marker.
		 * 
		 */		 				
		public function ARDetector(canvasWidth:int = 320, canvasHeight:int = 240, codeWidth:int = 80) 
		{
			width = canvasWidth;
			height = canvasHeight;
			this.codeWidth = codeWidth;
		}

		/**
		 * This will return an instance of the FLARParam.
		 * 
		 */		
		public function get flarParam():FLARParam
		{
			return _flarParam;	
		}

		/**
		 * This sets the BitmapData src to be monitored for patterns.
		 * 
		 */		
		public function set src(target:BitmapData):void
		{
			// setup ARToolkit
			raster = new FLARRgbRaster_BitmapData( target );
			detector = new FLARSingleMarkerDetector( _flarParam, code, codeWidth );
		}

		/**
		 * @private
		 * 
		 * Loads in the camera.dat file. This file contains information about
		 * the webcam.
		 *  
		 * @param url path to camera.dat file.
		 * 
		 */		 	
		protected function loadCameraFile(url:String):void
		{
			var camLoader:URLLoader = new URLLoader( );
			camLoader.dataFormat = URLLoaderDataFormat.BINARY;
   			
			camLoader.addEventListener( Event.COMPLETE, onCameraFileLoad, false, 0, true );
			addErrorListeners( camLoader );
   			
			camLoader.load( new URLRequest( url ) );	
		}

		/**
		 * @private
		 * 
		 * Triggered on a successful camera.dat file load. Once a complete 
		 * event is received we remove the listeners, create a new FLARParam,
		 * and set it's screen size. Finally we load the marker.
		 * 
		 * @param event
		 * 
		 */		 	
		protected function onCameraFileLoad(event:Event):void
		{
			event.stopImmediatePropagation( );
   			
			var target:URLLoader = event.target as URLLoader;
   			
			target.removeEventListener( Event.COMPLETE, onCameraFileLoad );
			removeErrorListeners( target );
   			
			_flarParam = new FLARParam( );
			_flarParam.loadARParam( target.data );
			_flarParam.changeScreenSize( width, height );
   			
			loadMarkerFile( markerURL );
		}

		/**
		 * @private
		 * 
		 * This loads the marker.pat file. The marker represents the image we
		 * look for from the src BitmapData.
		 * 
		 */		
		protected function loadMarkerFile(url:String):void
		{
			var patLoader:URLLoader = new URLLoader( );
			patLoader.dataFormat = URLLoaderDataFormat.TEXT;
   				
			patLoader.addEventListener( Event.COMPLETE, onMarkerFileLoad, false, 0, true );
			addErrorListeners( patLoader );
   			
			patLoader.load( new URLRequest( url ) );
		}

		/**
		 * @private
		 * 
		 * Triggered when a marker.pat file is loaded. We remove the listeners
		 * create a new 16x16 FLARCode instance, and pass in the pattern. This
		 * represents the resolution of your marker. By default 16x16 works for
		 * lower detailed patterns. After this the ARDetector is configured and 
		 * dispatches a Complete event.
		 * 
		 * @param event
		 * 
		 */		 	
		protected function onMarkerFileLoad(event:Event):void
		{
			event.stopImmediatePropagation( );
   			
			var target:URLLoader = event.target as URLLoader;
   			
			target.removeEventListener( Event.COMPLETE, onCameraFileLoad );
			removeErrorListeners( target );
   			
			code = new FLARCode( markerWidth, markerHeight );
			code.loadARPatt( target.data );
   
			dispatchEvent( new Event( Event.COMPLETE, true, true ) );
		}

		/**
		 * @private
		 * 
		 * Adds error event listeners and re-dispatches them once received.
		 * 
		 */		
		protected function addErrorListeners(target:IEventDispatcher):void
		{
			target.addEventListener( IOErrorEvent.IO_ERROR, dispatchEvent );
			target.addEventListener( SecurityErrorEvent.SECURITY_ERROR, dispatchEvent );
		}

		/**
		 * @private
		 * 
		 * Removes error event listeners.
		 * 
		 */		
		protected function removeErrorListeners(target:IEventDispatcher):void
		{
			target.removeEventListener( IOErrorEvent.IO_ERROR, dispatchEvent );
			target.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, dispatchEvent );
		}

		/**
		 * In order to set up the FLARDetector we will need two things: the 
		 * camera.dat and the marker.pat files. The camera.dat
		 *  
		 * @param cameraURL this is the path to the camera.dat file.
		 * @param markerURL this is the path to the marker.pat file.
		 * 
		 */		 		    
		public function setup(cameraURL:String, markerURL:String):void 
		{
			this.cameraURL = cameraURL;
			this.markerURL = markerURL;
			loadCameraFile( cameraURL );
		}

		/**
		 * 
		 * This calculates the transformation Matrix to match the found
		 * marker's coordinates.
		 * 
		 * @param resultMat - a type of matrix that can be used to store values 
		 * of the detected marker's orientation.
		 * 
		 */		 	
		public function calculateTransformMatrix(resultMat:FLARTransMatResult):void
		{
			detector.getTransformMatrix( resultMat );
		}

		/**
		 * 
		 * This validates if we have found a marker from the set src (raster).
		 * It returns a true/false based on the supplied values. You must supply 
		 * a source for this to work correctly.
		 * 
		 * @param threshold The threshold value to be used for detecting the marker.
		 * @param confidence This is how confident the detector is that it found
		 * a marker.
		 * 
		 */		
		public function detectMarker(threshold:int = 90, confidence:Number = .5):Boolean
		{
			return (detector.detectMarkerLite( raster, threshold ) && detector.getConfidence( ) > confidence);
		}
	}
}