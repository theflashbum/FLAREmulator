package com.flashartofwar.flar.core {
    import flash.display.BitmapData;

    import org.libspark.flartoolkit.core.param.FLARParam;
    import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;

    public interface IARDetector {

        function get flarParam():FLARParam;

        function set src(target:BitmapData):void;

        function setup(cameraURL:String, markerURL:String):void;

        function calculateTransformMatrix(resultMat:FLARTransMatResult):void;

        function detectMarker(threshold:int = 90, confidence:Number = .5):Boolean;
    }
}