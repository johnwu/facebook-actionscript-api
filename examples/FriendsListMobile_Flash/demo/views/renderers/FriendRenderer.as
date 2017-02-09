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

package demo.views.renderers {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import com.facebook.graph.FacebookMobile;
	
	import demo.controls.Image;
	import demo.events.FacebookDemoEvent;

	public class FriendRenderer extends MovieClip{

		public var img:Image;
		public var displayUsername:TextField;
		public var highlight:MovieClip;
		
		protected var _selected:Boolean = false;
		protected var _data:Object;
		protected var _over:Boolean;

		public function FriendRenderer() {
			super();
			
			highlight.visible = false;
			
			this.addEventListener(MouseEvent.CLICK, onSelected, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OVER, onOver, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, onOut, false, 0, true);
		}

		public function get data():Object { return _data; }
		public function set data(value:Object):void {
			_data = value;
			updateUI();
		}
		
		public function get selected():Boolean { return _selected; }
		public function set selected(value:Boolean):void {
			_selected = value;
			drawLayout();
		}
		
		public function updateUI():void {
			displayUsername.text = data.name;
			
			var url:String = FacebookMobile.getImageUrl(data.id, 'square');
			img.load(url);
		}
		
		protected function onOver(event:MouseEvent):void {
			_over = true;
			drawLayout();
		}
		
		protected function onOut(event:MouseEvent):void {
			_over = false;
			drawLayout();
		}
		
		protected function drawLayout():void {
			highlight.visible = (_selected || _over) ? true : false;
		}
		
		protected function onSelected(event:MouseEvent):void {
			dispatchEvent(new FacebookDemoEvent(FacebookDemoEvent.FRIEND_SELECTED, data));
		}
	}
}