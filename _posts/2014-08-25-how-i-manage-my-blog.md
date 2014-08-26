---
title: "How I Manage My Blog"
layout: post
date: 2014-08-25 11:07:33
category: jekyll
tags: jekyll update how-to git powershell
---
 
Before I get into the details, I'm going to say on what I run [jekyll][jekyllrb] locally and then how I made small `powershell` script to manage my posts. Well, actually I wanted to handle the `YML` header generation.

### My setup

I've got a computer running a 64-bit version of Windows 8.1. Nothing fancy, I just re-installed a few days back &mdash; the whole update fiasco, kinda ruined my PC. I've installed the jekyll prerequisites following this guide: [http://jekyll-windows.juthilo.com/][jekyll-windows]

Then I installed the `github-pages` gem from [GitHub][git-hub]. That's pretty much everything I did for jekyll. Again nothing fancy.

A little of [Twitter Bootstrap][bootstrap], a bit of [Bootswatch Cosmo][cosmo] and I have the current setup. It's not much, but I managed to finish it in a couple of days. The interesting part was to try and also integrate a CI (continuous-integration) server. I've made a [Codeship.io][codeship] account a few months back. I trying to make a CI for an old ASP.NET app I was working on. Turns out it didn't accept .NET projects.

### Setting up the CI environment
Setting up the environment is pretty easy. Once you've made your project on GitHub, head over to [Codeship.io][codeship] and login with your GitHub credentials.

From there, create a new project:

![A new project from codeship.io](/assets/images/posts/image01.PNG)

Select your repository.

Use the following __Setup Commands__:
{% highlight ruby %}
rvm use 2.1.0 --install
bundle install
bundle update
export RAILS_ENV=test
{% highlight %}

Use the following __Test Commands__
{% highlight ruby %}
bundle exec jekyll build
{% endhighlight %}

> NOTE: Always make sure you have a gemfile in your repository. Otherwise the  `bundle install bundle update` commands won't work!

Once you've setup your project in Codeship, you're done with it, because it automatically pushes into the `commit status api` of [GitHub][statusapi]. This looks something like this:

![A list of builds from commits into a merge request](/assets/images/posts/image02.PNG)

As you can see, I've had only one build failed. It automatically links back to codeship.io where you can view what went wrong.

The build log for commit [ed06c61](https://github.com/robertiagar/robertiagar-website/commit/ed06c61f798b2e6b4d514dd835d03b8a62833fb5) is:
{% highlight console %}
Notice: for 10x faster LSI support, please install http://rb-gsl.rubyforge.org/
Configuration file: /home/rof/src/github.com/robertiagar/robertiagar-website/_config.yml
Source: /home/rof/src/github.com/robertiagar/robertiagar-website
Destination: /home/rof/src/github.com/robertiagar/robertiagar-website/_site
Generating... 
Error reading file /home/rof/src/github.com/robertiagar/robertiagar-website/_posts/2014-08-25-how-i-manage-my-blog.md: invalid byte sequence in UTF-8 
  Liquid Exception: invalid byte sequence in UTF-8 in _posts/2014-08-25-how-i-manage-my-blog.md/#excerpt
jekyll 2.2.0 | Error:  invalid byte sequence in UTF-8
{% endhighlight %}

Apparently when I was testing out my new post generator I forgot to `UTF-8` encode the output. That caused some issues, but nothing too big.

### Powershell to the rescue

When using jekyll, each post must have `YAML Front Matter`. It's a sort of header that tells jekyll some basic information like title, date-posted, categories, tags (or any other information you want to embed into your post). The fact that I need to give `yyyy-MM-dd-title.md` filename, having to manually write the `Front Matter` was a bit of pain &mdash; granted, I have a few posts, for now, but I knew it would turn out to be a pain later on.

So I put my developer hardhat on and started figuring something out. 

Knowing C# I thought that a simple Console app with a few arguments would do the trick. Making it was pretty easy. In a few minutes I've got a working prototype, but then I thought:

> Man, it would be easier if I could commit it and push without having to type a git commands or opening a GUI git client.
> <footer>Robert Iagar in <cite title="The Heat of August">The Heat of August</cite></footer>

So then I wanted to add git powers to the app. Enter [`libgit2sharp`][libgit2]. Yes, `C#` classes for `git`. What can a dev ask for more?

Apparently I've thrown that idea of the window the minute I've read an article on how to make git cool in powershell using [posh-git][poshgit]. The [article](http://haacked.com/archive/2011/12/13/better-git-with-powershell.aspx/) was from `GitHub's staff` [Phil Haack][haacked] himself. That's how I've discovered `powershell` and the utility is has to offer.

I've started to work on a ~~small~~ [module][jekyll-new-post].

### Post `commit` workflow

I've made a small workflow on how I commit new posts to my blog. To keep everything isolated, I keep every new post on a separate branch, and to use the power of Codeship.io on the first draft I create a pull request, so I can view the progress.

When all is set and done, I merge and close the pull request and my website refreshes. It's pretty awesome if you think about it.

Now surely there are better ways out there. I'm not sure how people that use jekyll manage their posts or organize their branches or commits, but this is a workflow that I find to work.

If you have any other thoughts, leave a comment.

Cheers!

[git-hub]:         https://help.github.com/articles/using-jekyll-with-pages
[jekyll-windows]:  http://jekyll-windows.juthilo.com/
[jekyllrb]:        http://jekyllrb.com
[bootstrap]:       http://getbootstrap.com
[cosmo]:           http://bootswatch.com/cosmo/
[codeship]:        http://codeship.io
[statusapi]:       https://github.com/blog/1227-commit-status-api
[libgit2]:         https://github.com/libgit2/libgit2sharp
[poshgit]:         https://github.com/dahlbyk/posh-git
[haacked]:         http://haacked.com
[jekyll-new-post]: https://github.com/robertiagar/jekyll-new-post 
