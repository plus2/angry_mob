AngryMob (AM) is the automated system configuration component of [YesMaster](http://yesmasterapp.com).

It combines:

* convenient configuration data (`the node`)
* idempotent code to ensure the configuration of the parts of a system (`targets`)
* and a method of controlling the flow of the setup (`acts`)

AngryMob values having:

* zero external dependencies.
* a small, simple core.
* Rubiness.

Having *zero external dependencies* means that AM can be used from the very moment that a bare ruby interpreter is installed on a server.

A *small, simple core* means that debugging and testing the code is easy. It also allows AM to be embedded directly into other projects.

Please note that **AngryMob is a reaction to Chef**. Despite this, I really respect the Chef movement and the guys who've built it.

AM purposely omits or eschews the following features you might be familiar with from Chef:

* The client and server and its dependencies. AM operates similarly to "chef-solo" or is combined with other components for network based "chef-client"-like operation.
* A built in, fixed cookbook layout and metadata, and. You can define your own ResourceLocator, or use the basic supplied one.
* A single copy nirvana implementation. Again, define it yourself if you want it.
* The puppet resource/provider separation. I don't have a particular solution to supporting multiple operating systems, but its strongly YAGNI for now.
* Exhaustive system discovery like Ohai. I think Ohai is great, but running it before every AM run to find the hostname and IP is excessive.
* Type-checking of data. This is ruby, where ducks rule the roost.

### Status
AngryMob is young and fluid, but I'm using it a lot in the maintainence of VPSes at plus2.

In particular, AM lacks any unit-level specs or tests so far. The servers it maintains are valid functional testing in my eyes ;)

### Taxonomy

* The `node` is a glob of data representing the thing you're configuring.
* `targets` are things you want to configure.
* `acts` are groups of target invocations. They can also schedule the execution of other acts.
* `mobs` are groups of acts and targets.

#### The Node
The Node is a place to hang your data. In essence its a `Hash` (though more specifically its an [AngryHash](http://github.com/plus2/angry_hash), which is similar to `Hashie::Mash`)

#### Targets
Targets are parts of the server which you want to configure, for example:

* directories
* templates
* users

*Note* the targets interface is likely to change soon. Its overly complicated right now.

Targets perform a similar role to Chef/puppet resource/providers.

**TODO** talk about Target definition dsl and SingletonTargets

#### Acts
Acts are groups of targets. They're conceptually similar to a rake task. Subsequent acts can be scheduled.

#### Mobs
Mobs are groups of target definitions and acts. They can be mixed and matched.

##### common mob

http://github.com/plus2/common_mob

A small toolkit of handy targets:

* dir
* file
* template - ERB
* symlink
* tarball
* fetch
* git
* user
* apt - apt-get package
* gem - a rubygem
* block - a ruby block
* sh - a shell command
* service - a super-class for defining ubuntu service targets

## The mob command

"chef-solo"-like command for setting an AngryMob on your server.

**TODO** write!

## Meta

AngryMob was written by [Lachie Cox](http://github.com/lachie) for [Plus2](http://plus2.com.au) and [YesMaster](http://yesmasterapp.com).

It lives at http://github.com/plus2/angry_mob.

Please try it out and send us feedback via the github page.

## License

Copyright (c) 2010 Plus2

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

