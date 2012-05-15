/*
 *	Copyright (c) 2011 Andrew Stone
 *	This file is part of imgproxy.
 *
 *	imgproxy is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	imgproxy is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with imgproxy.  If not, see <http://www.gnu.org/licenses/>.
 */
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.system.LoaderContext;
	
	public class ImgProxy extends Sprite {
		public static const ERROR:String = 'onError';
		public static const LOAD:String = 'onLoad';
		public static const SUCCESS:String = 'onSuccess';
		
		public function ImgProxy() {
			if (!ExternalInterface.available) {
				throw new Error("ExternalInterface must be enabled.")
			}
			
			if (stage.loaderInfo.parameters['local']) {
				local(stage.loaderInfo.parameters['id']);
			} else {
				ExternalInterface.addCallback('load', load);
				dispatch(LOAD, 0, null);
			} 
		}
		
		private function load(id:int, url:String):void {
			var imageLoader:Loader = new Loader();
			
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
				try {
					sendImage(id, e.target.content as Bitmap);
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
		
		private function local(id:int):void {
			stage.addEventListener(MouseEvent.CLICK, function():void {
				var file:FileReference = new FileReference();
				
				file.addEventListener(Event.SELECT, function():void {
					file.load();
				});
				
				file.addEventListener(Event.COMPLETE, function():void {
					var l:Loader = new Loader();
					
					l.contentLoaderInfo.addEventListener(Event.COMPLETE, function():void {
						sendImage(id, l.content as Bitmap);
					});
					
					l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function():void {
						dispatch(ERROR, id, 'IO Error');
					});
					
					l.contentLoaderInfo.addEventListener(AsyncErrorEvent.ASYNC_ERROR, function():void {
						dispatch(ERROR, id, 'AsyncErrorEvent');
					});
					
					l.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function():void {
						dispatch(ERROR, id, 'Security Error');
					});
					
					l.loadBytes(file.data);
				});
				
				file.browse([new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png")]);
			});
		}
		
		private function sendImage(id:int, data:Bitmap):void {
			dispatch(SUCCESS, id, Base64.encode(PNGEncoder.encode(data.bitmapData)));
		}
		
		private function dispatch(event:String, id:int, data:String):void {
			ExternalInterface.call('imgproxy._' + event, id, data);
		}
	}
}