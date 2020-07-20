package {
import com.greensock.TweenLite;
import com.tuarua.BackBtn;
import com.tuarua.CancelBtn;
import com.tuarua.CaptureBtn;
import com.tuarua.DevToolsBtn;
import com.tuarua.ForwardBtn;
import com.tuarua.FreSharp;
import com.tuarua.FreSwift;
import com.tuarua.FullscreenBtn;
import com.tuarua.JsBtn;
import com.tuarua.RefreshBtn;
import com.tuarua.WebBtn;
import com.tuarua.WebView;
import com.tuarua.ZoominBtn;
import com.tuarua.ZoomoutBtn;
import com.tuarua.fre.ANEError;
import com.tuarua.utils.os;
import com.tuarua.webview.ActionscriptCallback;
import com.tuarua.webview.DownloadProgress;
import com.tuarua.webview.JavascriptResult;
import com.tuarua.webview.LogSeverity;
import com.tuarua.webview.Settings;
import com.tuarua.webview.WebEngine;
import com.tuarua.webview.WebViewEvent;
import com.tuarua.webview.popup.Behaviour;

import events.TabEvent;

import flash.desktop.NativeApplication;
import flash.display.BitmapData;
import flash.display.NativeWindowDisplayState;
import flash.display.PNGEncoderOptions;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.system.Capabilities;
import flash.text.Font;
import flash.utils.ByteArray;
import flash.utils.setTimeout;


import views.Progress;

import com.d5power.ui.TopBar;
import com.d5power.loader.ResLibParser;
import com.d5power.bitmapui.D5Style;
import com.d5power.core.AJSdk;
import com.d5power.FontLoader;

[SWF(width="1280", height="800", frameRate="60", backgroundColor="#d9dde2")]
public class ASBrowser extends Sprite {
    public static const FONT:Font = new FiraSansSemiBold();
    private var freSharpANE:FreSharp = new FreSharp(); // must create before all others
    private var freSwiftANE:FreSwift = new FreSwift(); // must create before all others
    private var webView:WebView;

    private var progress:Progress = new Progress();
    private var topBar:TopBar = new TopBar(progress);
    
    private var hasActivated:Boolean;
    private var _appWidth:uint = 1280;
    private var _appHeight:uint = 800;
    private var _ajsdk:AJSdk = new AJSdk();

    public function ASBrowser() {
        super();
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        this.addEventListener(Event.ACTIVATE, onActivated);
        NativeApplication.nativeApplication.executeInBackground = true;
    }

    protected function onActivated(event:Event):void {
        if (hasActivated) return;
         // this is handle the HARMAN splash screen
        hasActivated = true;
        new ResLibParser('d5ui.res',function():void{
            D5Style.initUI('ui/uiresource',function():void{setTimeout(init, 0);});
        });
    }

    
    protected function init():void {
        stage.addEventListener(Event.RESIZE, onResize);
        stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEvent);
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);

        NativeApplication.nativeApplication.activeWindow.addEventListener(
                NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowMiniMaxi);

        webView = WebView.shared();
        webView.addCallback("callAs", jsToAsCallback);
        webView.addCallback("forceWebViewFocus", forceWebViewFocus); //for Windows touch - see jsTest.html

        webView.addEventListener(WebViewEvent.ON_PROPERTY_CHANGE, onPropertyChange);
        webView.addEventListener(WebViewEvent.ON_FAIL, onFail);
        webView.addEventListener(WebViewEvent.ON_DOWNLOAD_PROGRESS, onDownloadProgress);
        webView.addEventListener(WebViewEvent.ON_DOWNLOAD_COMPLETE, onDownloadComplete);
        webView.addEventListener(WebViewEvent.ON_URL_BLOCKED, onUrlBlocked);
        webView.addEventListener(WebViewEvent.ON_POPUP_BLOCKED, onPopupBlocked);
        webView.addEventListener(WebViewEvent.ON_PDF_PRINTED, onPdfPrinted); //webView.printToPdf("C:\\path\\to\file.pdf");


        /*webView.addEventListener(KeyboardEvent.KEY_UP, onKeyUp); //KeyboardEvent of webview captured
        webView.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown); //KeyboardEvent of webview captured*/

        var settings:Settings = new Settings();
        settings.popup.behaviour = Behaviour.NEW_WINDOW;  //Behaviour.BLOCK //Behaviour.SAME_WINDOW //Behaviour.REPLACE
        settings.popup.dimensions.width = 600;
        settings.popup.dimensions.height = 800;
        settings.persistRequestHeaders = true;
        settings.webkit.custom.push({
            key:"allowFileAccessFromFileURLs",
            value:true
        });

        //only use settings.userAgent if you are running your own site.
        //google.com for eg displays different sites based on user agent
        //settings.userAgent = "WebViewANE";

        settings.cacheEnabled = true;

        // enable Edge View on Windows if available

        /*settings.engine = (os.isWindows && os.majorVersion >= 10 && os.buildVersion >= 17134)
                ? WebEngine.EDGE
                : WebEngine.DEFAULT;*/

        settings.enableDownloads = true;
        settings.contextMenu.enabled = true; //enable/disable right click
        settings.useTransparentBackground = true;

        // See https://github.com/cefsharp/CefSharp/blob/master/CefSharp.Example/CefExample.cs#L37 for more examples
        settings.cef.commandLineArgs.push({
            key: "disable-direct-write",
            value: "1"
        });
        settings.cef.enablePrintPreview = true;
        settings.cef.userDataPath = File.applicationStorageDirectory.nativePath;
        settings.cef.logSeverity = LogSeverity.DISABLE;

        // settings.urlWhiteList.push("html5test.com", "macromedia.","google.", "YouTUBE.", "adobe.com", "chrome-devtools://"); //to restrict urls - simple string matching
        // settings.urlBlackList.push(".pdf");

        var viewPort:Rectangle = new Rectangle(0, topBar.H, _appWidth, _appHeight - topBar.H);

        // trace(os.isWindows, os.majorVersion, os.minorVersion, os.buildVersion);
        
        webView.init(stage, viewPort, null, settings, 1.0, 0xFFF1F1F1);
        //webView.init(stage, viewPort, null, settings, 1.0, 0xFFF1F1F1); // when using loadHTMLString
        webView.visible = true;
        webView.injectScript("function testInject(){console.log('yo yo')}");

        onHome();
        /*trace("loading html");
         webView.loadHTMLString('<!DOCTYPE html>' +
         '<html>' +
         '<head><meta charset="UTF-8">' +
         '<title>Mocked HTML file 1</title>' +
         '</head>' +
         '<body bgColor="#33FF00">' + //must give the body a bg color otherwise it loads black
         '<p>with UTF-8: Björk Guðmundsdóttir Sinéad O’Connor 久保田  利伸 Михаил Горбачёв Садриддин Айнӣ Tor Åge Bringsværd 章子怡 €</p>' +
         '</body>' +
         '</html>', new URLRequest("http://rendering/"));*/

        this.addChild(topBar);
    }

    public function onHome():void
    {
        this.openLocal('basic/index.html')
    }

    private function onEvalJsBtn(event:MouseEvent):void {
        //this is without a callback
        webView.evaluateJavascript('document.getElementsByTagName("body")[0].style.backgroundColor = "yellow";');

        //this is with a callback
        //webView.evaluateJavascript("document.getElementById('output').innerHTML;", onJsEvaluated)
    }

    private function onAsJsAsBtn(event:MouseEvent):void {
        webView.callJavascriptFunction("as_to_js", asToJsCallback, 1, "é", 77);

        // this is how to use without a callback
        // webView.callJavascriptFunction("console.log",null,"hello console. The is AIR");
    }

    /**
     * 打开Url
     * @param   url     要打开的地址
     */
    public function openUrl(url:String = 'http://www.d5power.com'):void
    {
        webView.load(new URLRequest(url));
    }

    /**
     * 打开本地H5驱动
     * 本方法只允许读取App内部plugin目录下的文件，并具有读取权限，可引用js等文件
     * @param   path    文件路径，基于App安装目录下的plugin的相对地址
     */
    public function openLocal(path:String):void
    {
        trace(File.applicationDirectory.resolvePath('plugin/').nativePath);
        webView.loadFileURL(File.applicationDirectory.resolvePath('plugin/'+path).nativePath,File.applicationDirectory.resolvePath('plugin/').nativePath);
    }

    private function onCapture(event:MouseEvent):void {
        webView.capture(function (bitmapData:BitmapData):void {
            if (bitmapData) {
                var ba:ByteArray = new ByteArray();
                var encodingOptions:PNGEncoderOptions = new PNGEncoderOptions(true);
                bitmapData.encode(new Rectangle(0, 0, bitmapData.width, bitmapData.height), encodingOptions, ba);
                var file:File = File.desktopDirectory.resolvePath("webViewANE_capture.png");
                var fs:FileStream = new FileStream();
                fs.open(file, FileMode.WRITE);
                fs.writeBytes(ba);
                fs.close();
                trace("webViewANE_capture.png written to desktop")
            }

        }, new Rectangle(100, 100, 400, 200));
    }

    private function onWeb(event:MouseEvent):void {
        webView.load(new URLRequest("http://www.adobe.com"));
    }

    public function onJS():void {
        var localHTML:File = File.applicationDirectory.resolvePath("jsTest.html");
        if (localHTML.exists) {
            webView.loadFileURL(localHTML.nativePath, File.applicationDirectory.nativePath);
        }
    }

    public function onDevTools():void {
        webView.showDevTools(); //webView.closeDevTools();
    }

    private function onFullScreen(event:MouseEvent):void {
        onFullScreenApp();
    }

    private function onZoomOut(event:MouseEvent):void {
        webView.zoomOut();
    }

    private function onZoomIn(event:MouseEvent):void {
        webView.zoomIn();
    }

    private function onCancel(event:MouseEvent):void {
        webView.stopLoading();
    }

    public function onRefresh():void {
        webView.reload();
    }

    private function loadWithRequestHeaders(event:MouseEvent):void {
        var req:URLRequest = new URLRequest("http://www.google.com");
        req.requestHeaders.push(new URLRequestHeader("Cookie", "BROWSER=WebViewANE;"));
        webView.load(req);
    }

    private function onForward(event:MouseEvent):void {
        webView.goForward();

        /*var obj:BackForwardList = webView.backForwardList();
        trace("back list length",obj.backList.length)
        trace("forward list length",obj.forwardList.length)*/
    }

    private function onBack(event:MouseEvent):void {
        webView.goBack();
    }

    private function onPdfPrinted(event:WebViewEvent):void {
        trace(event);
    }

    private function onKeyDown(event:KeyboardEvent):void {
        trace(event);
    }

    private function onKeyUp(event:KeyboardEvent):void {
        trace(event);
    }

    private function onPopupBlocked(event:WebViewEvent):void {
        stage.dispatchEvent(new MouseEvent(MouseEvent.CLICK)); //this prevents touch getting trapped on Windows
    }

    private function onPropertyChange(event:WebViewEvent):void {
        // read list of tabs and their details like this:
        /*var tabList:Vector.<TabDetails> = webView.tabDetails;
        if (tabList && tabList.length > 0) {
            trace(tabList[webView.currentTab].index, tabList[webView.currentTab].title, tabList[webView.currentTab].url);
        }*/
        switch (event.params.propertyName) {
            case "url":
                if (event.params.tab == webView.currentTab) {

                }
                break;
            case "title":
                topBar.setTitle(event.params.value);
                break;
            case "isLoading":
                if (event.params.tab == webView.currentTab) {

                }
                break;
            case "canGoBack":
                if (event.params.tab == webView.currentTab) {

                }
                break;
            case "canGoForward":
                if (event.params.tab == webView.currentTab) {

                }
                break;
            case "estimatedProgress":
                var p:Number = event.params.value;
                if (event.params.tab == webView.currentTab) {
                    progress.scaleX = p;
                    if (p > 0.99) {
                        TweenLite.to(progress, 0.5, {alpha: 0});
                    } else {
                        progress.alpha = 1;
                    }
                }
                break;
            case "statusMessage":
                if (event.params.tab == webView.currentTab) {

                }
                break;
        }
    }

    private function onNewTab(event:TabEvent):void {
        progress.scaleX = 0.0;
    }

    private function onSwitchTab(event:TabEvent):void {

    }

    private function onCloseTab(event:TabEvent):void {

    }

    private static function onUrlBlocked(event:WebViewEvent):void {
        trace(event.params.url, "does not match our urlWhiteList or is on urlBlackList", "tab is:", event.params.tab);
    }

    private function onWindowMiniMaxi(event:NativeWindowDisplayStateEvent):void {
        if (event.afterDisplayState != NativeWindowDisplayState.MINIMIZED) {
            webView.viewPort = new Rectangle(0, 90, _appWidth, _appHeight - 140);
        }
    }

    private static function onDownloadComplete(event:WebViewEvent):void {
        trace(event.params, "complete");
    }

    private static function onDownloadProgress(event:WebViewEvent):void {
        var progress:DownloadProgress = event.params as DownloadProgress;
        trace("progress.id", progress.id);
        trace("progress.url", progress.url);
        trace("progress.percent", progress.percent);
        trace("progress.speed", progress.speed);
        trace("progress.bytesLoaded", progress.bytesLoaded);
        trace("progress.bytesTotal", progress.bytesTotal);
    }

    private function onJsEvaluated(jsResult:JavascriptResult):void {
        trace("Evaluate JS -> AS reached WebViewANESample.as");
        trace("jsResult.error:", jsResult.error);
        trace("jsResult.result:", jsResult.result);
        trace("jsResult.message:", jsResult.message);
        trace("jsResult.success:", jsResult.success);
    }

    public function forceWebViewFocus(asCallback:ActionscriptCallback):void {
        webView.focus();
    }

    public function jsToAsCallback(asCallback:ActionscriptCallback):void {
        trace("JS -> AS reached WebViewANESample.as");
        trace("asCallback.args", asCallback.args);
        trace("asCallback.functionName", asCallback.functionName);
        trace("asCallback.callbackName", asCallback.callbackName);

        if (asCallback.args && asCallback.args.length > 0) {
            var paramA:int = asCallback.args[0] + 33;
            var paramB:String = asCallback.args[1].replace("I am", "You are");
            var paramC:Boolean = !asCallback.args[2];

            trace("paramA", paramA);
            trace("paramB", paramB);
            trace("paramC", paramC);
            trace("we have a callbackName")
        }

        var args:Array = asCallback.args;
        var index:int = args[0];
        var command:String = args[1];
        args.splice(0,2);
        try
        {
            var result:Object = _ajsdk.hasOwnProperty(command) ? _ajsdk[command].apply(this,args) : null;
        }catch(e:Error){
            webView.callJavascriptFunction('AJtrace', null, e.getStackTrace());
        }
        

        if (index!=-1) { //if we have a callbackName it means we have a further js call to make
            webView.callJavascriptFunction('AJCallBack', null, index,result);
        }

    }

    public static function asToJsCallback(jsResult:JavascriptResult):void {
        trace("asToJsCallback");
        trace("jsResult.error", jsResult.error);
        trace("jsResult.result", jsResult.result);
        trace("jsResult.message", jsResult.message);
        trace("jsResult.success", jsResult.success);
        var testObject:Object = JSON.parse(jsResult.result);
        trace(testObject);
    }

    private static function onFail(event:WebViewEvent):void {
        trace(event.params.url);
        trace(event.params.errorCode);
        trace(event.params.errorText);
        if (event.params.hasOwnProperty("tab")) {
            trace(event.params.tab);
        }
    }

    public function onFullScreenApp():void {
        if (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
            stage.displayState = StageDisplayState.NORMAL;
            _appWidth = 1280;
            _appHeight = 800;
        } else {
            _appWidth = Capabilities.screenResolutionX;
            _appHeight = Capabilities.screenResolutionY;
            stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
        }
    }

    private function onFullScreenEvent(event:FullScreenEvent):void {
        if (webView) {
            webView.viewPort = new Rectangle(0, 90, _appWidth, _appHeight - 140);
        }
    }

    public function updateWebViewOnResize():void {
        if (webView) {
            webView.viewPort = new Rectangle(0, 90, _appWidth, _appHeight - 140);
        }
    }

    private function onResize(e:Event):void {
        _appWidth = this.stage.stageWidth;
        _appHeight = this.stage.stageHeight;
        updateWebViewOnResize();
    }

    /**
     * It's very important to call WebView.dispose(); when the app is exiting.
     */
    private function onExiting(event:Event):void {
        WebView.dispose();
        FreSwift.dispose();
        FreSharp.dispose();
    }


}
}