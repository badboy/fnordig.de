extends: post.liquid
title: Fixing a Vagrant "hostonlyif" error
date: 20 Jan 2014 13:24:00 +0100
path: /:year/:month/:day/fixing-a-vagrant-hostonlyif-error
route: blog
---

------

**tl;dr:** Load the correct module: `sudo modprobe vboxnetadp`

------

I recently came across an article about LXC, [Exploring LXC Networking][1],
which used [Vagrant][2] to get a development machine up and running.

I wanted to try it, but stumbled across a problem for which I mostly found the OS X solution:

~~~bash
sudo /Library/StartupItems/VirtualBox/VirtualBox restart
~~~

But this does not work on Linux. I finally found the working solution in the
post [Resolve a hostonlyif create error with vagrant][3]. So for full documentation I repeat it here again.

I used the following Vagrant file:

~~~ruby
Vagrant.configure(2) do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.provision :shell, :inline => pkg_cmd

  # Create a private network
  config.vm.network :private_network, ip: "10.0.4.2"

  # Create a public network
  config.vm.network :public_network
end
~~~

After `vagrant up` I got the following error:

~~~bash
$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
[default] Clearing any previously set forwarded ports...
[default] Clearing any previously set network interfaces...
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["hostonlyif", "create"]

Stderr: 0%...
Progress state: NS_ERROR_FAILURE
VBoxManage: error: Failed to create the host-only adapter
VBoxManage: error: VBoxNetAdpCtl: Error while adding new interface: failed to open /dev/vboxnetctl:
  No such file or directory

VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component HostNetworkInterface,
  interface IHostNetworkInterface
VBoxManage: error: Context: "int handleCreate(HandlerArg*, int, int*)" at line 68 of file VBoxManageHostonly.cpp
~~~

Loading the right kernel module helped:

~~~bash
sudo modprobe vboxnetadp
~~~

After that `vagrant up` worked as expected and the machine was accessible via SSH:

~~~bash
Bringing machine 'default' up with 'virtualbox' provider...
[default] Clearing any previously set forwarded ports...
[default] Clearing any previously set network interfaces...
[default] Available bridged network interfaces:
1) wlan0
2) eth0
What interface should the network bridge to? 1
[default] Preparing network interfaces based on configuration...
[default] Forwarding ports...
[default] -- 22 => 2222 (adapter 1)
[default] Booting VM...
[default] Waiting for machine to boot. This may take a few minutes...
[default] Machine booted and ready!
[default] Configuring and enabling network interfaces...
[default] Mounting shared folders...
[default] -- /vagrant
[default] VM already provisioned. Run `vagrant provision` or use `--provision` to force it
~~~

[1]: http://containerops.org/2013/11/19/lxc-networking/
[2]: http://www.vagrantup.com/
[3]: https://coderwall.com/p/ydma0q
