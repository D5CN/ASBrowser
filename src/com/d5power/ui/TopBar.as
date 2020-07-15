package com.d5power.ui
{
	import com.d5power.bitmapui.D5Bitmap;
	import com.d5power.bitmapui.D5Text;
	import com.d5power.bitmapui.D5Button;

	import com.d5power.bitmapui.D5Component;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import flash.events.Event;
	import views.Progress;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.desktop.NativeApplication;
	import com.d5power.FontLoader;
	import flash.net.URLRequest;

	/**
	 *	顶部UI 
	 */
	public class TopBar extends Sprite
	{
		protected var _uiSrc:String;
		
		public var _realWidth:uint=1280;
		public var _realHeight:uint=45;
		public var _flyX:Number=0;
		public var _flyY:Number=0;
		public var _autoFix:Boolean =false;
		// 编辑器绑定变量定义开始，请勿删除本行注释
		public var img_logo:D5Bitmap;
		public var txt_title:D5Text;
		public var btn_close:D5Button;

		// 编辑器绑定变量定义结束，请勿删除本行注释
		private var _progress:Progress;
		

		public var _drag_switch:Boolean = false;
		public const H:uint=45;
		
		public function TopBar(progressBar:Progress)
		{
			super();
			visible = false;
			graphics.beginFill(0,0);
			graphics.drawRect(0,0,_realWidth,_realHeight);
			graphics.endFill();
			_progress = progressBar;
			_uiSrc = "ui/conf/topbar.d5ui";
			startLoadUI();

			var loader:FontLoader = new FontLoader( new URLRequest( 'font.swf' ) );
		}

		private var _waitTitle:String;
		public function setTitle(txt:String):void
		{
			_waitTitle = txt;
			if(!this.txt_title) return;
			this.txt_title.text = txt;
			_waitTitle = null;
		}
		
		/**
		 * 请在此方法中编写释放功能，如果有关闭按钮，可以直接将关闭按钮的侦听设置在此
		 */
		public function dispose(e:MouseEvent=null):void
		{
			if(parent) parent.removeChild(this);
		}
		
		private function startLoadUI():void
		{
			D5Component.getComponentByURL(_uiSrc,this,onLoaded);
		}
		
		/**
		 * 此方法将在UI界面初始化完成后运行。可以在本方法中增加侦听，赋予初始值等
		 */
		private function onLoaded():void
		{
			graphics.clear();
			// 自动浮动
			if(stage)
			{
				flyPos();
			}else{
				addEventListener(Event.ADDED_TO_STAGE,flyPos);
			}
			
			addChild(_progress);
			_progress.x = 0;
			_progress.y = H - _progress.height;

			this.addEventListener(MouseEvent.MOUSE_DOWN,this.BeginDrag);
			this.btn_close.addEventListener(MouseEvent.CLICK,this.onClose);
			this.img_logo.addEventListener(MouseEvent.CLICK,backToIndex)
			
			_waitTitle && setTitle(_waitTitle);
		}

		private function backToIndex(e:MouseEvent):void
		{
			var asbrow:ASBrowser = parent as ASBrowser;
			asbrow && asbrow.onHome();
		}

		private function onClose(e:MouseEvent):void
		{
			var exitingEvent:Event = new Event(Event.EXITING, false, true); 
			NativeApplication.nativeApplication.dispatchEvent(exitingEvent); 
			if (!exitingEvent.isDefaultPrevented()) { 
				NativeApplication.nativeApplication.exit(); 
			} 

		}

		private function BeginDrag(e:MouseEvent):void
		{
			stage && e.localX<this.btn_close.x && stage.nativeWindow.startMove();
		}

		private function onKey(e:KeyboardEvent):void
		{
			if(e.ctrlKey)
			{
				var asbrow:ASBrowser = parent as ASBrowser;
				if(!asbrow) return;

				switch(e.keyCode)
				{
					case Keyboard.F5:
						asbrow.onRefresh();
						break;
					case Keyboard.F12:
						asbrow.onDevTools();
						break;
					case Keyboard.J:
						asbrow.onJS();
						break;
				}
			}
		}

		
		private function flyPos(e:Event=null):void
		{
			//if(x!=0 && y!=0) return;
			if(e!=null) removeEventListener(Event.ADDED_TO_STAGE,flyPos);
			visible = true;
			stage.addEventListener(KeyboardEvent.KEY_UP,this.onKey)
		}
		

		override public function get width():Number
		{
			return _realWidth;
		}
		
		override public function get height():Number
		{
			return _realHeight;
		}
		

	}
}