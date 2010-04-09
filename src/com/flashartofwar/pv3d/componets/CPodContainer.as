
/** 
 * <p>Original Author:  Jesse Freeman</p>
 * <p>Class File: CPodContainer.as</p>
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
 
 package com.flashartofwar.pv3d.componets
{
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;

	/**
	 * The CPodContainer is a manger for a Papervision cube that represents
	 * the cPod. This container class simply sets up the cube, loads in the
	 * textures and attaches it to a supplied target DisplayObject3D.
	 * 
	 * This simple setup allows you to customize the logic behind creating
	 * a cPod instance while maintaining encapsulation and extensibility.
	 * 
	 * @author Jesse Freeman
	 * 
	 */	
	public class CPodContainer
	{

		protected var cube : Cube;
		private var baseURL : String;

		/**
		 * Main constructor. Calls init and begins creating the cPod 3d 
		 * Object.
		 * 
		 */		
		public function CPodContainer(baseURL:String = "")
		{
			this.baseURL = baseURL;
			init( );
		}

        /**
		 * This is similar to addChild except it will attach the cPod's 3d
		 * instance (a cube) onto a target DisplayObject3D.
		 *
		 * @param target
		 *
		 */
		public function attachTo(target:DisplayObject3D):void
		{
			target.addChild( cube );
		}
        
		/**
		 * @private
		 * 
		 */		
		protected function init():void
		{
			createCube( );
		}

		/**
		 * @private
		 * 
		 * Creates a simple cube primitive that will represent our cPod.
		 * 
		 */		
		protected function createCube():void
		{
			cube = new Cube( createSkins( ), 198, 29, 391, 10, 4, 10 );
			cube.roll( - 90 );
			cube.z = 20;
			cube.scale = .5;
		}

		/**
		 * @private
		 * 
		 * @return a MarterialsList with BitmapFileMaterials for each face: front,
		 * back, left, right, top and bottom.
		 * 
		 */		
		protected function createSkins():MaterialsList
		{
			var frontBFM:BitmapFileMaterial = new BitmapFileMaterial( baseURL + "images/skins/cpod-front.jpg" );
			var backBFM:BitmapFileMaterial = new BitmapFileMaterial( baseURL + "images/skins/cpod-back.jpg" );
			var rightBFM:BitmapFileMaterial = new BitmapFileMaterial( baseURL + "images/skins/cpod-left.jpg" );
			var leftBFM:BitmapFileMaterial = new BitmapFileMaterial( baseURL + "images/skins/cpod-right.jpg" );
			var topBFM:BitmapFileMaterial = new BitmapFileMaterial( baseURL + "images/skins/cpod-top.jpg" );
			var bottomBFM:BitmapFileMaterial = new BitmapFileMaterial( baseURL + "images/skins/cpod-bottom.jpg" );
   			
			return new MaterialsList( {front: frontBFM, back: backBFM, right: rightBFM, left: leftBFM, top: topBFM, bottom: bottomBFM} );
		}

	}
}