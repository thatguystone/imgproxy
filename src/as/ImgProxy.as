/*
 *	Copyright (c) 2011 Andrew Stone
 *	This file is part of flowplayer-ima.
 *
 *	flowplayer-streamtheworld is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	flowplayer-streamtheworld is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with flowplayer-streamtheworld.  If not, see <http://www.gnu.org/licenses/>.
 */
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	public class ImgProxy extends Sprite {
		public static const ERROR:String = 'onError';
		public static const LOAD:String = 'onLoad';
		public static const SUCCESS:String = 'onSuccess';
		
		public function ImgProxy() {
			if (!ExternalInterface.available) {
				throw new Error("ExternalInterface must be enabled.")
			}
			
			ExternalInterface.addCallback('load', load);
			dispatch(LOAD, 0, null);
		}
		
		public function load(id:int, url:String):void {
			var imageLoader:Loader = new Loader();
			
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
				try {
					var bd:BitmapData = (e.target.content as Bitmap).bitmapData;
					dispatch(SUCCESS, id, Base64.encode(PNGEncoder.encode(bd)));
				} catch (e:SecurityError) {
					dispatch(ERROR, id, 'Security Error');
				}
			});
			
			imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function():void {
				dispatch(ERROR, id, 'IO Error');
			});
			
			imageLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function():void {
				dispatch(ERROR, id, 'Security Error');
			});
			
			imageLoader.load(new URLRequest(url), new LoaderContext(true));
		}
		
		private function dispatch(event:String, id:int, data:String):void {
			ExternalInterface.call('imgproxy._' + event, id, data);
		}
	}
}