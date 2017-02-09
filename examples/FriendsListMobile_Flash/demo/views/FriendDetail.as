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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import com.facebook.graph.controls.Distractor;
	import com.facebook.graph.FacebookMobile;
	
	import demo.controls.Image;
	import demo.events.FacebookDemoEvent;
	import demo.controls.GraphicButton;

	
	public class FriendDetail extends MovieClip {
		public var img:Image;
		public var close:GraphicButton;
		public var closeX:GraphicButton;
		public var textContainer:MovieClip;
		public var distractor:Distractor;
		public var bg:MovieClip
		
		protected var _data:Object = {};
		protected var padding:Number = 20;
		
		public function FriendDetail() {
			// constructor code
			configUI();
		}
		
		public function get data():Object { return _data; }
		public function set data(value:Object):void {
			_data = value;
			updateUI();
		}
		
		protected function updateUI():void {
			distractor.visible = true;
			var url:String = FacebookMobile.getImageUrl(data.id, 'large');
			
			var img:Image = new Image();
			img.name = 'img';
			img.addEventListener(FacebookDemoEvent.IMAGE_COMPLETE, onImageComplete, false, 0, true);
			img.load(url);
			addChild(img);
			
			img.visible = false;
			textContainer.visible = false;
			
			var index:Number = 0;
			var tf:TextFormat = new TextFormat();
			tf.font = '_sans';
			for(var n in data) {
				switch(n) {
					case 'id':
					case 'birthday_date':
					case 'sex':
					case 'name':
					var txt:TextField = new TextField();
					txt.text = n + ' : ' + data[n];
					tf.size = 22;
					txt.width = 300;
					txt.height = 30;
					txt.mouseEnabled = false;
					txt.selectable = false;
					
					txt.y = txt.height * index;
					txt.setTextFormat(tf);
					textContainer.addChild(txt);
					index++;
						break;
				}
			}
			
		}
		protected function onImageComplete(event:FacebookDemoEvent):void {
			var img:Image = event.target as Image;
			img.x = bg.width - img.width >> 1;
			img.y = padding;
			
			textContainer.x = bg.width - textContainer.width >> 1;
			textContainer.y = (img.height + img.y) + padding*2;
			
			distractor.visible = false;
			textContainer.visible = true;
			img.visible = true;
			
			this.setChildIndex(close, this.numChildren - 1);
		}
		
		protected function configUI():void {
			
			textContainer = new MovieClip();
			addChild(textContainer);
			
			close.addEventListener(MouseEvent.MOUSE_DOWN, onClose, false, 0, true);
			closeX.addEventListener(MouseEvent.MOUSE_DOWN, onClose, false, 0, true);
			
			closeX.x = 350
			
			close.setSize(405, 60);
			closeX.setSize(60, 60);
			
			close.label = 'Close';
			closeX.label = 'X';
			
			this.setChildIndex(closeX, this.numChildren - 1);
			
			distractor = new Distractor();
			distractor.x = 100;
			distractor.y = 100;
			addChild(distractor);
		}
		
		protected function onClose(event:MouseEvent):void {
			this.removeChild(this.getChildByName('img'));
			while(textContainer.numChildren) { textContainer.removeChildAt(0); }
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
	
}
