---
layout: post
title: Working with ICollection/List/IEnumerable that contain custom classes
date: 2010-06-03 23:37
author: robertiagar
comments: true
categories: [.NET General, C#]
---
Again, about my <a href="http://xbladegraphix.co.cc/TwitBy">Twitter Client</a>. I’ve made a custom class show the tweet and then a ICollection for the public property of the Tweets in the TwitterViewModel.

<!--more-->

Problem: Each I time I get new tweets I have to empty the Collection. I tried to use the Contains method every time I added a new Tweet, but as <a href="http://10rem.net">Pete Brown</a> said that will always return false.

Solution: Implement ```IEquatable<Tweet>``` on my ```Tweet``` class. Now when ```Contains``` checks if the tweet exists in the list it will work.

Other example.

Say you have this custom class:

```csharp
class User
{
      public string Name { get; set; }
      public long ID { get; set; }
}
```
Not going to bother to implement ```INotifyPropertyChanged```. This will be only about the ```IEquatable``` interface.

Create a ```ICollection<User>``` and add some data:

```csharp
ICollection<Use&> list = new List<User>();
list.Add(new User { Name = “Robert”, ID = 123409 });
list.Add(new User { Name = “Pete”, ID = 23410 });
```

Now. Say you have some form that creates a new User, check if it exists and then tries to add it. For sake of simplicity I won’t use a form:

```csharp
var user = new User { Name = “Pete”, ID= 23410 });
if(!list.Contains(user))
     list.Add(user);
```

This won’t work. It’ll add it even you know that it contains it. Simply put “Two instances of a class representing the same tweet (or in this case user) are two different things.” (<a href="http://twitter.com/Pete_Brown/status/15341247123">@Pete_Brown on Twitter</a>)

Implement the IEquatable class and your class should look like this:

```csharp
class User: IEquatable<User>
{
      public string Name { get; set; }
      public long ID { get; set; }

      public bool Equals(User other)
      {
            if(other.ID == this.ID)
                  return true;
            else
                  return false;
      }
}
```
Now ```Contains()``` will work properly and your List manipulations will work like a charm.

Hope you found this post useful. It’s been a pain of figuring it out. Had help from Pete Brown.
Subscribe to his blog: <a href="http://10rem.net">http://10rem.net</a>
Follow him on Twitter: <a href="http://twitter.com/Pete_Brown">http://twitter.com/Pete_Brown</a>

Me? You can find my blog at <a href="http://robertiagar.com/">http://robertiagar.com/</a> ~~(mouthful I know)~~ and Twitter: <a href="http://twitter.com/RobertIagar">http://twitter.com/RobertIagar</a>

Stay tuned for more interesting finds…
