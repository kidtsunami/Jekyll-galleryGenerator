Overview
========
A jekyll plugin that allows you to define image galleries.

- Images accessible as static files
- Galleries accessible through site payload
- Images can have resized thumbs
- Galleries named after post accessible through post payload

Dependencies
============
- jekyll >= 2.0
- [ImageMagick](http://www.imagemagick.org/) for resizing images
- RMagick

How To Use
==========

Basic Setup
-----------
1. Copy galleryGenerator.rb into your `_plugins` folder within your Jekyll project.
2. Create folder `_galleries` within your Jekyll project.

Add A Gallery
-------------
1. Create a folder with a reference name for your gallery (e.g. `sample_gallery`) under the `_galleries` folder.
2. Add images to the gallery under `_galleries/sample_gallery/`
3. Re-generate your site using `jekyll` [Basic Usage](http://jekyllrb.com/docs/usage/)

Access Galleries From Site Payload
----------------------------------
Each gallery is accessible through the site payload. So in the case of the gallery `sample_gallery` to display the images in the gallery, use the following liquid template code.
```html
{% for gallery_image in site.galleries['sample_gallery'] %}
	<img src = "{{ gallery_image.path }}" />
{% endfor %}
```

Generate Thumbs
---------------
1. Add `gallery_thumbs` to your config file `_config.yml` with an array of thumb sizes represented as two integers separated by anything other than integers.
```yaml
gallery_thumbs:
	- 150x150
	- 200 by 200
	- 100 50
	- 50basicallyanything20
```
2. Re-generate your site using `jekyll` [Basic Usage](http://jekyllrb.com/docs/usage/)

Access Thumbs From Gallery Image
--------------------------------
Each gallery image has an additional attribute `thumbs` which is a hash of thumbnails generated for each image where the key is the thumb size as configured in your config file. 

Continuing with the above example, you would display a thumb with size _150x150_ with the following liquid template code.
```html
{% for gallery_image in site.galleries['sample_gallery'] %}
	<img src = "{{ gallery_image.thumbs['150x150'].path }}" />
{% endfor %}
```

Associate A Gallery With A Post
-----------------------------
If you name a gallery after a post (e.g. a post file `2014-06-01-Sample post.md` and gallery named `2014-06-01-Sample post`) then when in liquid where a post is `post` then the gallery is accessible through `post.gallery` in the same way the gallery is accessible through `site.galleries['2014-06-01-Sample post']`

For example here's an example of a liquid template referencing a post's gallery.
```html
{% for gallery_image in post.gallery %}
    <div class="col-lg-3">
        <a class="fancybox" rel="{{ post.title }} {{ post.date | date: "%B %Y" }}" href="{{ gallery_image.path }}">
            <img src="{{ gallery_image.thumbs['150x150'].path }}">
        </a>
    </div>
{% endfor %}
```

Inspired By
===========
The more time I spend coding, the more I value the amazing efforts of others. I now first look to see if someone has done what I'm trying to do better before diving into my own implementation. In the end I didn't find other plugins satisfying the above requirements, but I was thoroughly inspired by two plugins.
* [JekyllGalleryTag](https://github.com/redwallhp/JekyllGalleryTag) inspired my use of static files for my images and use of ImageMagick to resize images into thumbs.
* [jekyll-postfiles](https://github.com/indirect/jekyll-postfiles) helped me wrap my head around processing posts and associating things with them.