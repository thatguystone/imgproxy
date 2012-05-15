/*
 *	Copyright (c) 2012 Andrew Stone
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
	import flash.external.ExternalInterface;
	
	internal class Log {
		public static function log(msg:String):void {
			ExternalInterface.call('console.log', msg);
		}
		
		public static function error(msg:String):void {
			ExternalInterface.call('console.error', msg);
		}
	}
}