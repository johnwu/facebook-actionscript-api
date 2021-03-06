﻿/*
  Copyright (c) 2010, Adobe Systems Incorporated
  All rights reserved.

  Redistribution and use in source and binary forms, with or without 
  modification, are permitted provided that the following conditions are
  met:

  * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
  
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the 
    documentation and/or other materials provided with the distribution.
  
  * Neither the name of Adobe Systems Incorporated nor the names of its 
    contributors may be used to endorse or promote products derived from 
    this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


package  {		
		
	import com.facebook.graph.FacebookDesktop;
	import com.facebook.graph.controls.Distractor;
	import com.facebook.graph.net.FacebookRequest;
	import com.facebook.graph.utils.FacebookDataUtils;
	
	import fl.controls.ScrollBar;
	import fl.controls.TextArea;
	import fl.data.DataProvider;
	import fl.events.ListEvent;
	import fl.text.TLFTextField;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import flashx.textLayout.factory.TextLineFactoryBase;
	
	public class FriendList extends MovieClip {
				
		protected var dp:DataProvider;
		protected var win:NativeWindow;
		
		protected static const APP_ID:String = "YOUR_APP_ID"; //Place your application id here
		
		public function FriendList() {			
			dp = new DataProvider();
			
			loginBtn.label = 'Login';
			loginBtn.enabled = true;
			loginBtn.addEventListener(MouseEvent.CLICK, handleLoginClick, false, 0, true);
			
			detailsBtn.label = 'Show details';
			detailsBtn.setSize(100, 22);
			detailsBtn.addEventListener(MouseEvent.CLICK, handleDetailsClick, false, 0, true);
			
			friendList.dataProvider = dp;
			friendList.labelField = "name";
			friendList.addEventListener(ListEvent.ITEM_CLICK, handleListChange, false, 0, true);
			
			FacebookDesktop.manageSession = false;
			FacebookDesktop.init(APP_ID);
		}
		
		protected function handleLoginClick(event:MouseEvent):void {
			FacebookDesktop.login(handleLogin);
		}
		
		protected function handleLogin(response:Object, fail:Object):void {
			if (response) {
				loginBtn.label = 'You are logged in.';
				loginBtn.enabled = false;
				detailsBtn.enabled = false;
				loadFriends();
			}
		}
		
		protected function loadFriends():void {
			FacebookDesktop.api('/me/friends', handleFriendsLoad);
		}
		
		protected function handleFriendsLoad(response:Object, fail:Object):void {
			dp.removeAll();
			
			var friends:Array = response as Array;			
			var l:int = friends.length;
			for (var i:int=0; i < l; i++) {
				dp.addItem(friends[i]);
			}
			friendList.dataProvider = dp;
		}
		
		protected function handleListChange(event:ListEvent):void {
			detailsBtn.enabled = true;
			detailsBtn.label = 'Show details ' + event.item.name;
			var w:Number = 150 + (detailsBtn.label).length;
			detailsBtn.setSize(w, 22);
		}
		
		protected function handleDetailsClick(event:MouseEvent):void {
			if (!friendList.selectedItem) { return; }
			FacebookDesktop.api('/'+friendList.selectedItem.id, handleDetailsLoad);
		}
		
		protected function handleDetailsLoad(response:Object, fail:Object):void {
			var df:TextFormat = new TextFormat('_sans', 12);
			
			var tf:TextField = new TextField();			
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.defaultTextFormat = df;
			
			var textToDisplay:Array = [];
			var d:Object = response;
			for (var n:String in d) {
				var displayValue:Object = d[n];
				
				switch (n) {
					case 'updated_time':
						displayValue = FacebookDataUtils.stringToDate(displayValue as String); break;
					case 'work':
					case 'hometown':
					case 'location':
						displayValue = objectToString(displayValue); break;
					case 'education':
						displayValue = arrayToString(displayValue as Array); break;
				}
				textToDisplay.push(n + ': ' + displayValue);
			}
			
			tf.text = textToDisplay.join('\n');
			tf.x = 200;
			var init:NativeWindowInitOptions = new NativeWindowInitOptions();
			
			var img:Loader = new Loader();
			var imgURL:String = FacebookDesktop.getImageUrl(d.id, 'large');
			var distractor:Distractor = new Distractor();
			distractor.text = 'loading';
			
			img.load(new URLRequest(imgURL));
			img.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageReady, false, 0, true);
			
			win = new NativeWindow(init);
			win.width = 600;
			win.height = tf.textHeight + 120;
			win.stage.scaleMode = StageScaleMode.NO_SCALE;
			win.stage.align = StageAlign.TOP_LEFT;
			win.stage.addChild(tf);
			win.stage.addChild(img);
			win.stage.addChild(distractor);
			win.activate();
		}
		
		protected function onImageReady(event:Event):void {
			win.stage.removeChildAt(win.stage.numChildren-1);
		}
		
		protected function objectToString(value:Object):String {
			var arr:Array = [];
			for (var n:String in value) {
				arr.push(n + ': ' + value[n]);
			}
			return '\n\t' + arr.join('\n\t');
		}
		
		protected function arrayToString(value:Array):String {
			var arr:Array = [];
			var l:uint = value.length;
			for (var i:uint=0;i<l;i++) {
				arr.push(objectToString(value[i]));
			}
			
			return arr.join('\n');
		}
	}
	
}
