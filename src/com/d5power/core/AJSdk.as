package com.d5power.core
{
    import flash.filesystem.File;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;

    public class AJSdk
    {
        public function AJSdk()
        {

        }

        public function loadFile(path:String):String
        {
            var f:File = File.applicationDirectory.resolvePath('plugin/'+path);
            if(!f.exists) return null;
            
            var fs:FileStream = new FileStream();
            fs.open(f,FileMode.READ);
            var result:String = fs.readUTFBytes(fs.bytesAvailable);
            fs.close();

            return result;
        }

        public function writeFile(path:String,content:String,mode:String='w'):void
        {
            var f:File = File.applicationDirectory.resolvePath('plugin'+path);
        }
    }
}