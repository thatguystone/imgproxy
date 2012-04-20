(function() {
	"use strict";
	
	var $el,
		loading = false,
		ready = false,
		id = 0,
		waiting = [],
		callbacks = {};
	
	function loadSwf() {
		if (loading) {
			return;
		}
		loading = true;
		
		var el = document.createElement('div');
		el.setAttribute('id', 'imgproxy');
		document.body.insertBefore(el);
		
		if (window.swfobject) {
			swfobject.embedSWF(imgproxy.SWF, 'imgproxy', '1', '1', '9.0.0');
		} else if (window.jQuery) { //try jQuery SWFObject: http://jquery.thewikies.com/swfobject/
			jQuery(function() {
				if (jQuery.fn.flash) {
					$el = jQuery('#imgproxy');
					$el.flash({
						swf: imgproxy.SWF,
						width: 1,
						height: 1,
						wmode: 'transparent'
					});
				} else {
					console.error('No swf library found.  Cannot load imgproxy');
				}
			});
		}
	}
	
	function swf(callback) {
		if (window.swfobject) {
			callback.call((navigator.appName.indexOf("Microsoft") != -1 ? window.imgproxy : document.imgproxy));
		} else {
			$el.flash(callback);
		}
	}
	
	window.imgproxy = {
		SWF: 'imgproxy.swf',
		
		load: function(url, successCallback, failCallback) {
			if (!ready) {
				waiting.push(Array.prototype.slice.call(arguments));
				loadSwf();
				return;
			}
			
			callbacks[id] = {
				success: successCallback,
				error: failCallback
			};
			
			swf(function() {
				this.load(id++, url);
			});
		},
		_onLoad: function() {
			var i;
			
			ready = true;
			
			if (waiting.length) {
				for (i = 0; i < waiting.length; i++) {
					this.load.apply(this, waiting[i]);
				}
			}
			
			waiting = null;
		},
		_onSuccess: function(id, img) {
			var fn = callbacks[id].success;
			if (fn) {
				fn(img);
			}
			delete callbacks[id];
		},
		_onError: function(id, error) {
			var fn = callbacks[id].error;
			if (fn) {
				fn(error);
			}
			delete callbacks[id];
		}
	};
}());