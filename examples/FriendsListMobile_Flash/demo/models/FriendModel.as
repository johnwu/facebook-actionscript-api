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


package demo.models {

	import com.facebook.graph.FacebookMobile;
	import com.facebook.graph.net.FacebookRequest;

	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	public class FriendModel extends EventDispatcher {

		protected var friendsHash:Object;
		protected var friendsArrayList:Array;

		public function FriendModel() {
			super();
			friendsHash = {};
			friendsArrayList = [];
		}

		public function get dataProvider():Array {
			return friendsArrayList;
		}

		public function load():void {
			FacebookMobile.api('/me/friends', handleFriendsLoad);
		}

		protected function handleFriendsLoad(response:Object, fail:Object):void {
			friendsArrayList = [];
			
			if (fail) { return }
			var friendsIds:Array = [];

			var friends:Array = response as Array;

			var l:uint=friends.length;
			for (var i:uint=0;i<l;i++) {
				var friend:Object = friends[i];
				friendsArrayList.push(friend);
				friendsHash[friend.id] = friend;

				friendsIds.push(friend.id);
			}

			//To keep down on requests, load some details about your friends via fql.
			var friendsFQL:String = 'SELECT uid, profile_update_time, birthday_date,pic_square, pic, hometown_location, sex FROM user WHERE uid IN (' + friendsIds.join(',') + ')';
			FacebookMobile.fqlQuery(friendsFQL, handleFriendsDataLoad);
		}

		protected function handleFriendsDataLoad(response:Object, fail:Object):void {
			
			if (fail) { return; }
			var friendDetails:Array = response as Array;
			
			var l:uint = friendDetails.length;
			
			for (var i:uint=0;i<l;i++) {
				var detailsObj:Object = friendDetails[i];
				var friendObj:Object = friendsHash[detailsObj.uid];
				for (var n:String in detailsObj) {
					friendObj[n] = detailsObj[n];
				}
			}
			
			updateArray();
		}
		
		protected function updateArray():void {
			for(var l:Number = dataProvider.length,i=0;i<l;i++) {
				var item:Object = dataProvider[i];
				if (item.id == friendsHash.uid) {
					item[i] = friendsHash[item.id];
				}
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}