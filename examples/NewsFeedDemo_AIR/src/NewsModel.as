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


package {
	import com.chewtinfoil.utils.StringUtils;
	import com.facebook.graph.FacebookDesktop;
	import com.facebook.graph.net.FacebookRequest;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;


	public class NewsModel extends EventDispatcher {
		
		protected static var instance:NewsModel;
		
		/**
		 * The dataprovider for the news list.
		 * Populated from the inital load, or from a search
		 * 
		 */
		protected var newsFeedDp:ArrayList;
		
		/**
		 * All the current news posts indexed by post_id
		 * 
		 */
		protected var newsFeedCache:Object;
		
		protected var commentsDp:ArrayList;
		protected var commentsCache:Object;
		
		public function NewsModel(se:SingletonEnforcer) {			
			super();
			newsFeedDp = new ArrayList();
			newsFeedCache = {};
			commentsDp = new ArrayList();
			commentsCache = {};
		}
		
		protected static function getInstance():NewsModel {
			if (instance == null) { instance = new NewsModel(new SingletonEnforcer()); }
			return instance;
		}  
		
		/**
		 * 
		 * @return Returns the news feed dataprovider as ArrayList
		 * 
		 */		
		public static function get newsFeedDp():ArrayList {
			return getInstance().newsFeedDp;
		} 
		
		/**
		 * Makes a request to load the logged in user's home feed
		 * 
		 */		
		public static function loadHomeFeed():void { getInstance().loadHomeFeed(); }
		protected function loadHomeFeed():void {
			FacebookDesktop.api('/me/home', handleHomePageLoad);
		}
		
		/**
		 * 
		 * @param query The search string
		 * @param date The date to seach since
		 * 
		 */		
		public static function searchNewsFeed(query:String, date:Date):void { getInstance().searchNewsFeed(query, date); }
		protected function searchNewsFeed(query:String, date:Date):void {
			var opts:Object = StringUtils.isEmpty(query) ? {since:date} : {q:query, since:date};
			FacebookDesktop.api('/me/home', handleSearchComplete ,opts); 
		}
		
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void {
			getInstance().addEventListener(type, listener, useCapture, priority, useWeakReference);	
		}
		
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			getInstance().removeEventListener(type, listener, useCapture);
		}
		
		protected function handleHomePageLoad(response:Object, fail:Object):void {
			if (response) {
				handleNewsFeedLoad(response as Array);
			} else {
				dispatchEvent(new NewsEvent(NewsEvent.LOAD_ERROR, 'Error Loading Home Feed'));
			}
		}
		
		/**
		 * Parses the post data and populates the dataprovider and cache
		 * 
		 * @param values The collection of data for each post
		 * 
		 */		
		protected function handleNewsFeedLoad(values:Array):void {
			newsFeedDp = new ArrayList();
			if (values == null) {
				dispatchEvent(new NewsEvent(NewsEvent.HOME_LOADED));
				return;
			}
			
			var l:uint = values.length;
			for (var i:uint = 0;i<l;i++) {
				var item:Object = values[i];
				newsFeedCache[item.id] = item;
				newsFeedDp.addItem(item);
			}
			
			loadRelatedData();
		}
	
		protected function handleSearchComplete(response:Object, fail:Object):void {
			if (response) {
				handleNewsFeedLoad(response as Array);
			} else {				
				var msg:String = fail.error.message != null ? fail.error.message : "Search Error";				
				dispatchEvent(new NewsEvent(NewsEvent.LOAD_ERROR, msg));
			}
		}
		
		/**
		 * After the news feed is loaded, we need to load some related information, that the initial call doesn't give us.
		 * We load all the likes information for each post, by using an FQLQuery, so we can retrieve all the information in one call.
		 * 
		 */
		protected function loadRelatedData():void {
			var l:uint = newsFeedDp.length;
			
			//If we have no items, just clear the UI.
			if (l == 0) {
				dispatchEvent(new NewsEvent(NewsEvent.HOME_LOADED)); //populateUI();
				return;
			}
			
			//If we do have news items, grab all the id's.
			var postIds:Array = [];
			for (var i:uint=0;i<l;i++) {
				postIds.push(newsFeedDp.getItemAt(i).id);
			}
			
			//Format a FQL query, using all the above id's.
			FacebookDesktop.fqlQuery('SELECT likes, post_id FROM stream WHERE post_id IN ("' + postIds.join('", "') + '")', handleRelatedDataLoad);
			
		}
		
		/**
		 * Once all the likes are loaded, update our local data stucture using the new data.
		 * 
		 */
		protected function handleRelatedDataLoad(response:Object, fail:Object):void {
			
			var likes:Array = response as Array;
			
			if (likes != null) {
				var l:uint = likes.length;
				for (var i:uint=0;i<l;i++) {
					var o:Object = likes[i];
					newsFeedCache[o.post_id].likes = o.likes.count;
					newsFeedCache[o.post_id].user_likes = o.likes.user_likes;
					newsFeedCache[o.post_id].can_like = o.likes.can_like;
				}
			}
			
			dispatchEvent(new NewsEvent(NewsEvent.HOME_LOADED));
		}
	}
}

class SingletonEnforcer {}