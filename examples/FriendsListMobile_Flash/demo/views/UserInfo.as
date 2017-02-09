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

package demo.views {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import com.facebook.graph.FacebookMobile;
	import com.facebook.graph.data.FacebookSession;
	
	import demo.controls.Image;
	import demo.events.FacebookDemoEvent;

	
	public class UserInfo extends MovieClip {
		
		public var img:Image;
		
		protected var _data:Object;
		public var id:String;
		public var textContainer:MovieClip;
		
		public function UserInfo() {
			// constructor code
		}
		
		public function get data():Object { return _data; }
		public function set data(value:Object):void {
			_data = value;
			updateUI();
		}
		
		public function clear():void {
			while(textContainer.numChildren) { textContainer.removeChildAt(0); }
			img.visible = false;
			id = '';
		}
		
		protected function updateUI():void {
			if (data is FacebookSession) {
				FacebookMobile.api('/me', loadUserDetails);
			} else {
				layout();
			}
		}
		
		protected function layout(response:Object=null):void {
			trace('',id);
			trace('',response)
			
			var url:String = FacebookMobile.getImageUrl((!response) ? id : response.id, 'square');
			img.load(url);
			img.visible = true;
			
			textContainer = new MovieClip();
			var space:Number=1;
			var w:Number = 150;
			var h:Number = 22;
			var cols:Number = 1;
			var index:Number=0;
			var tf:TextFormat = new TextFormat();
			
			var tmp:Object = (response) ? response : data;
			
			for(var n:String in tmp) {
				switch(n) {
					case 'name':
					case 'gender':
					case 'id':
						var detail = n + ' : ' + tmp[n];
						var txt:TextField = new TextField();
						
						txt.text = detail.toUpperCase();
						tf.size = 20;
						tf.color = 0x000000;
						tf.font = '_sans';
						h = txt.textHeight + 10;
						txt.width = 480;
						txt.x = (space+w) * (index%cols);
						txt.y = Math.floor(index/cols) * (space+h);
						txt.selectable = false;
						txt.mouseEnabled = false;
						txt.setTextFormat(tf);
						index++;
						textContainer.addChild(txt);
						break;
				}
			}
			textContainer.x = (img.x + img.width) + 10;
			textContainer.y = img.y;
			if (!this.contains(textContainer)) {  addChild(textContainer); }
		
			dispatchEvent(new FacebookDemoEvent(FacebookDemoEvent.USER_COMPLETE));
		}
		
		protected function loadUserDetails(response:Object, fail:Object):void {
			trace(response, fail);
			if (response) { layout(response); }
		}
	}
	
}
