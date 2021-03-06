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
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import com.facebook.graph.FacebookMobile;
	
	import demo.events.FacebookDemoEvent;
	import demo.views.renderers.FriendRenderer;
	import demo.controls.GraphicButton;

	public class FriendsList extends MovieClip {
		
		protected var _data:Array = [];
		public var friendContainer:MovieClip;
		public var nextBtn:GraphicButton;
		public var prevBtn:GraphicButton;
		
		protected var index:Number = 0;
		protected var offset:Number = 72;
		protected var oldSelectedItem:FriendRenderer;
		
		public function FriendsList() {
			// constructor code
			friendContainer.scrollRect = new Rectangle(0, 0, friendContainer.width, friendContainer.height);
		
			nextBtn.addEventListener(MouseEvent.MOUSE_DOWN, onClick, false, 0, true);
			prevBtn.addEventListener(MouseEvent.MOUSE_DOWN, onClick, false, 0, true);
			
			nextBtn.label = '+';
			prevBtn.label = '-';
			
			nextBtn.setSize(440, 60);
			prevBtn.setSize(440, 60);
			
			nextBtn.setStyle('icon', new DownArrowIcon());
			prevBtn.setStyle('icon', new UpArrowIcon());
		}
		
		protected function onClick(event:MouseEvent):void {
			
			index = (event.currentTarget == nextBtn) ? index+offset: index-offset;
			index = Math.max(0, Math.min(dataProvider.length*offset-friendContainer.height,index));
			
			handleScroll();
		}
		
		protected function handleScroll():void {
			
			var r:Rectangle = friendContainer.scrollRect;
			r.y = index;
			
			friendContainer.scrollRect = r;
		}
		
		public function get dataProvider():Array { return _data; }
		public function set dataProvider(value:Array):void {
			_data = value;	
			updateUI();
		}
		
		protected function onSelected(event:FacebookDemoEvent):void {
			
			if (oldSelectedItem) { oldSelectedItem.selected = false };
			
			var item:FriendRenderer = event.target as FriendRenderer;
			item.selected = true;
			
			oldSelectedItem = item;
			
			dispatchEvent(event.clone() as FacebookDemoEvent);
		}
		
		public function clear():void {
			
			while(friendContainer.numChildren) { friendContainer.removeChildAt(0); }
			
			dataProvider = [];
			
			nextBtn.enabled = false;
			prevBtn.enabled = false;
		}
		
		protected function updateUI():void {
			
			nextBtn.enabled = prevBtn.enabled = (dataProvider.length < 6) ? false : true;
			
			for(var l:int=dataProvider.length, i=0;i<l;i++) {
				var item:FriendRenderer = new FriendRenderer();
				item.data = dataProvider[i];
				item.x = 7;
				item.y = (i*offset);
				item.addEventListener(FacebookDemoEvent.FRIEND_SELECTED, onSelected, false, 0, true);
				friendContainer.addChild(item);
			}
		}
	}
	
}
