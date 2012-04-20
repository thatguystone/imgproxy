# A flash image proxy

For when you really just need to get an image loaded into your canvas without flipping the origin-clean tag (and [CORS](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing) isn't an option).

Security description: https://developer.mozilla.org/en/Canvas_tutorial/Using_images#Using_images_from_other_domains

**Honestly, you should never need this.  And if you do, find a way not to.**

Example:

```javascript
	
	imgproxy.load('http://someserver/image.jpg', function(b64img) {
		$img = $('<img />');
		
		$img.load(function() {
			var img = $img[0],
				ctx = $('<canvas width="' + img.width + '" height="' + img.height + '" />')[0].getContext('2d');
			ctx.drawImage(img, 0, 0);
			
			//global pixels
			pixels = ctx.getImageData(0, 0, img.width, img.height);
		});
		
		$img.attr('src', 'data:image/png;base64,' + b64img);
	}, errorCallback);
```