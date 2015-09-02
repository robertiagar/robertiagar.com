---
excerpt_separator: "<!--more-->"
categories: 
  - pixelation
  - performance
  - parallelization
  - "c#"
image: ""
published: false
title: "Pixelating images, Bitmap performance and parallelization"
---


Before you go on yelling "Where the heck is Part 2 for the Podcasts series?" I'd like to point out a few things:

1. I'm lazy
2. I was on vacation 
3. I have a full time job
4. I'm lazy

Notice how I said that I'm lazy twice? Good. The other reasons don't really count, but you get the idea.

Now that we've gotten this out of the way, let's talk about what this post is really about: pixelating images.

#But why?

![But why?]({{site.baseurl}}/assets/post-images/Ryan_Reynolds_But_Why.gif)

Why would you pixelate an image? Frankly I'm tired of 'standard' wallpapers and I wanted to make something abstract without to much work. So I went form this:
![Original Image]({{site.baseurl}}/assets/post-images/original.jpg)
To this:
![Pixelated with pixel size 300]({{site.baseurl}}/assets/post-images/result300.jpg)

Nothing fancy. The code is fairly simple and I'm going to come clean that I didn't come up with it. It was [Eric Willis](http://notes.ericwillis.com/2009/11/pixelate-an-image-with-csharp/). Nonetheless here's the code:


```
private static Bitmap Pixelate(Bitmap image, Rectangle rectangle, Int32 pixelateSize)
{
    Bitmap pixelated = new System.Drawing.Bitmap(image.Width, image.Height);
 
    // make an exact copy of the bitmap provided
    using (Graphics graphics = System.Drawing.Graphics.FromImage(pixelated))
        graphics.DrawImage(image, new System.Drawing.Rectangle(0, 0, image.Width, image.Height),
            new Rectangle(0, 0, image.Width, image.Height), GraphicsUnit.Pixel);
 
    // look at every pixel in the rectangle while making sure we're within the image bounds
    for (Int32 xx = rectangle.X; xx < rectangle.X + rectangle.Width && xx < image.Width; xx += pixelateSize)
    {
        for (Int32 yy = rectangle.Y; yy < rectangle.Y + rectangle.Height && yy < image.Height; yy += pixelateSize)
        {
            Int32 offsetX = pixelateSize / 2;
            Int32 offsetY = pixelateSize / 2;
 
            // make sure that the offset is within the boundry of the image
            while (xx + offsetX >= image.Width) offsetX--;
            while (yy + offsetY >= image.Height) offsetY--;
 
            // get the pixel color in the center of the soon to be pixelated area
            Color pixel = pixelated.GetPixel(xx + offsetX, yy + offsetY);
 
            // for each pixel in the pixelate size, set it to the center color
            for (Int32 x = xx; x < xx + pixelateSize && x < image.Width; x++)
                for (Int32 y = yy; y < yy + pixelateSize && y < image.Height; y++)
                    pixelated.SetPixel(x, y, pixel);
        }
    }
 
    return pixelated;
}
```

The only problem with this code is that it's very inefficient. It takes about 18-20 seconds to process the image I've shown a earlier. That's a bit way too much. It can go much, much faster.

Optimization was never my strong suit, so after a few google search, some stack overflow questions, I've came to the conclusion: use [`LockBits()`](https://msdn.microsoft.com/en-us/library/system.drawing.bitmap.lockbits%28v=vs.110%29.aspx?f=255&MSPPError=-2147217396). 

What does this do? 

> Locks a Bitmap into system memory.
> <footer><cite>Straight form [MSDN](https://msdn.microsoft.com/en-us/library/system.drawing.bitmap.lockbits%28v=vs.110%29.aspx?f=255&MSPPError=-2147217396).</cite></footer>

What does this mean? 

This method converts the image into a pointer that can be accessed way faster than a normal object. Now here's the problem with pointers: to work with them in C# you need to mark your code with the `unsafe` keyword. Either at the method signature, or a code region:

```
private static unsafe DoSomethingWithPointers(){ // }

private static DoSomethingWithPointers(int overload)
{
	unsafe
    {
    	//work with pointers here
    }
}
```
This is not a a huge deal, but we all know from `C/C++` that bad pointer handling could result in some leaks and security issues.

> In the common language runtime (CLR), unsafe code is referred to as unverifiable code. Unsafe code in C# is not necessarily dangerous; it is just code whose safety cannot be verified by the CLR. The CLR will therefore only execute unsafe code if it is in a fully trusted assembly. If you use unsafe code, it is your responsibility to ensure that your code does not introduce security risks or pointer errors.
> <footer><cite>[MSDN](https://msdn.microsoft.com/en-us/library/t2yzs44b.aspx)</cite><footer>

You can work with pointers without marking you code as `unsafe` by copying the pointer to a byte array using the [`Marshal.Copy`](https://msdn.microsoft.com/en-us/library/system.runtime.interopservices.marshal.copy(v=vs.80).aspx) method. That way the CLR is happy that you don't work with pointers directly and you're not risking anything by accessing system memory.

Now it's been a while since I've used pointers or worked with byte arrays and I'm a bit rusty, but again Google is your friend. I've found a nice wrapper around the whole LockBits and pointer/byte array method of accessing the images pixels on [CodeProject](http://www.codeproject.com/Tips/240428/Work-with-bitmap-faster-with-Csharp).

You cand find the implementation [here](https://github.com/robertiagar/Pixelator/blob/master/Pixelator.Console/LockBitmap.cs). Basically you still have the GetPixel and SetPixel methods so you can leave most of the code unchanged:

```
private static Bitmap PixelateLockBits(Bitmap image, Rectangle rectangle, int pixelateSize)
{
	using (LockBitmap lockBitmap = new LockBitmap(image))
	{
		var width = image.Width;
		var height = image.Height;

		for (Int32 xx = rectangle.X; xx < rectangle.X + rectangle.Width && xx < image.Width; xx += pixelateSize)
		{
			for (Int32 yy = rectangle.Y; yy < rectangle.Y + rectangle.Height && yy < image.Height; yy += pixelateSize)
			{
				Int32 offsetX = pixelateSize / 2;
				Int32 offsetY = pixelateSize / 2;

				// make sure that the offset is within the boundry of the image
				while (xx + offsetX >= image.Width) offsetX--;
				while (yy + offsetY >= image.Height) offsetY--;

				// get the pixel color in the center of the soon to be pixelated area
				Color pixel = lockBitmap.GetPixel(xx + offsetX, yy + offsetY);

				// for each pixel in the pixelate size, set it to the center color
				for (Int32 x = xx; x < xx + pixelateSize && x < image.Width; x++)
					for (Int32 y = yy; y < yy + pixelateSize && y < image.Height; y++)
						lockBitmap.SetPixel(x, y, pixel);
			}
		}
	}
	return image;
}
```

Just by doing that you get a speed increase from 18-20 seconds to just 5 seconds. Now that's what I call fast. But we can go faster. Having a byte arrays means that different threads can access the array at the same time, so no thread locking in required. Thanks to the nice folks at Microsoft we have the [TPL - Task Parallel Library](http://blogs.msdn.com/b/pfxteam/). The inner 2 `for's`, the ones that set the pixels colors, can pe run in parallel:

```
Parallel.For(xx, xx + pixelateSize, x =>
						{
							if (x < width)
							{
								Parallel.For(yy, yy + pixelateSize, y =>
								{
									if (y < height)
									{
										lockBitmap.SetPixel(x, y, pixel);
									}
								});
							}
						});
```                        

