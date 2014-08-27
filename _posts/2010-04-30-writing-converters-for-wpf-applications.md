---
layout: post
title: Writing Converters for WPF applications
date: 2010-04-30 10:09
author: "Robert Iagar"
comments: true
tags: [WPF]
---
I’m currently writing my own Twitter client (yes, I know, another Twitter client will hit the market. Whoopee!) and I had to create a converter that turns a regular string to some kind of a rich text box with link’s and that kind of stuff. The algorithm is in my head just need to implement. That would be my greatest achievement yet. But let’s not go adrift from the subject. Writing your own converter for your app.

First you need to know is your input and what would be your output (that’s essentially what a converter is: take some input, does some work with and then returns an output). WPF has some very basic converters built-in: String to Color, String to Bool and many more that I have no idea where there are or how they work. I know that the XAML parser uses converters a lot. Some WPF developer I am. But anyway. Let’s get to the point.

<!--more-->

In my application I have a TwitterViewModel that I bind all my data to it. One of the data that I bind to is a string that contains the status of a users tweet. That’s just the string, no hyperlinks or links to the User who wrote just a naked string. I need to write a converter that converts that string to a “rich text box” with hyperlinks, hashtags and al of the other stuff.

I’m going to show how I got to use what I use and then hopefully you’ll understand how I did it. We won't be creating that rich-textbox because the code is fairly long and for new-comers can be a little complicated. I'm just going to show how to convert a string to a textblock and add some quick-tips along the way. So let’s begin:
<h2>Setting up your thing to convert</h2>
At the beginnings I had the following TextBlock that is bind to the status of the TwitterViewModel:
<blockquote>&lt;TextBlock
Grid.Row="1"  Grid.Column="1" Grid.ColumnSpan="2"
TextWrapping=”Wrap”
Text="{Binding Status}"/&gt;</blockquote>
Everything worked out peachy for test purposes but now the gig is up and I need to create the converter to make the status look and work better.

Now it’s time to put your brain to work and think what you need to show and you have. I need to show a TextBlock with links for hyperlinks and hashtags.
Can it be done?
With this setup: No.
Why? Because you cannot set a Text property of a TextBlock to host any content other than a string. Well you can, but not in this format. You need to replace with either a ContentControl or something derived from ContentControl (e.i. a  Button or Label). I replaced the TextBlock with a Label and removed the TextWrapping property (because the Label does not support text wrapping) and changed the Text property to Content:
<blockquote>&lt;Label
Grid.Row="1"  Grid.Column="1" Grid.ColumnSpan="2"
Content="{Binding Status}"/&gt;</blockquote>
Right everything works like before nothing fancy. Because a Label supports anything as a content as long as it’s one ContentItem that can be a ContentContainer (e.i Grid, DockPanel, StackPanel – which can host multiple content) we can now create our converter.
<h2>Setting up your converter</h2>
Go into Visual C# Express 2010 and create a new Class in your project:

<a href="http://robertiagar.files.wordpress.com/2010/04/image.png"><img style="display:inline;margin-left:0;margin-right:0;border-width:0;" title="image" src="http://robertiagar.files.wordpress.com/2010/04/image_thumb.png" border="0" alt="image" width="244" height="139" /></a>

Name it something easy to understand (i.e: TwitterStatusConverter) and not something generic (i.e. Converter). When others look at your code they need to understand what you did there and not ask you every time “Hey what does Convert_2.cs do?”

Visual C# Express will automatically open your new class file. You should have something like this:

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Robert.Converters
{
class TestConverter
{
}
}

Visual C# Express generated namespaces automatically with every source file you add into a folder. Robert is my main namespace and Converters is where I created the Class file. Depending on your setup you can have different results.
Now add the following usings:

using System.Windows.Data;
using System.Windows.Controls;
using System.Windows.Documents;

You’ll see in a moment why we need all those references.

Now we need to derive our class from IValueConverter. IValueConverter is an interface that make creating converters easy:

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Data;
using System.Windows.Controls;
using System.Windows.Documents;

namespace Robert.TwitBy.Converters
{
class TestConverter:IValueConverter
{
}
}

Implement the interface:

<a href="http://robertiagar.files.wordpress.com/2010/04/image1.png"><img style="display:inline;border-width:0;" title="image" src="http://robertiagar.files.wordpress.com/2010/04/image_thumb1.png" border="0" alt="image" width="244" height="139" /></a>

You should have the following methods:

public object Convert(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
{
throw new NotImplementedException();
}

public object ConvertBack(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
{
throw new NotImplementedException();
}

We’ll work with the Convert(…) method. Delete what’s in it and add the following code:

string s = value as string;

var textBlock = new TextBlock()
{
TextWrapping = System.Windows.TextWrapping.Wrap
};

textBlock.Inlines.Add(s); //textblock.Inlines.Add() is powerful method. You can add whatever you want ( hyperlinks for example).

return textBlock;

The first line takes the <strong>value </strong>object and converts it into a string. Why is <strong>value</strong> an object? Simple. The object type is one or the most versatile types in C# (learned this from <a href="http://twitter.com/Pete_Brown">Pete_Brown</a>).
The second line creates a textBlock with it’s TextWrapping Property set to Wrap (System.Windows.TextWrapping.Wrap is the full path to the TextWrapping enum).
The third adds the string to the textBlock inline collection and then returns the textBlock.
Basically we’ve create a String to TextBlock converter. Nothing fancy but you should understand how converters work.
<h2>Adding the converter to your binding expression</h2>
First of all you need to create a reference in your xaml file to your converter.

xmlns:c="clr-namespace:Robert.TwitBy.Converters"

Or depending what namespace is your converter in. Usually you add these references in you Document root (i.e. Window, Application).

Now in your ResourcesDictionary , where you want to use the converter create a key for it.

&lt;c:TestConverter x:Key="TestConverter"/&gt;

Remember when we wrote our label with our binding expression? Let me remind you:

&lt;Label
Grid.Row="1"  Grid.Column="1" Grid.ColumnSpan="2"
Content="{Binding Status}"/&gt;

Change the Content property binding like so:

&lt;Label
Grid.Row="1"  Grid.Column="1" Grid.ColumnSpan="2"
<strong>Content="{Binding Status, Converter={StaticResource TestConverter}}"</strong>/&gt;

That’s about it. Now it should convert your string to a TextBlock.
