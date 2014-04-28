knife-audit
========
A knife plugin for determining which cookbooks are in use on which nodes of your Chef server or Opscode organization.
Allows you to safely maintain a chef cookbook set by determining which cookbooks are currently in use by nodes - either solely via inclusion in node runlists (available from every node) or via runlist *or* include_recipes (for nodes with knife_audit helper cookbook installed).


Installing knife-audit
-------------------

#### Script install

Copy the knife-audit script from https://raw.githubusercontent.com/jbz/knife-audit/master/lib/chef/knife/audit.rb to your .chef/plugins/knife directory.   Note that script-installed knife audit will be unable to install the knife_audit helper cookbook for you.

#### Gem install

knife-audit is available on rubygems.org - if you have that source in your gemrc, you can simply use:

    gem install knife-audit

...if you don't have internet access or just want a local gemfile, you can clone the repo and build/install a working gem from the main repo directory:

    gem build knife-audit.gemspec
    gem install ./knife-audit-<version>.gem

Usage
---------------

    knife audit [-a|-t] [-s] [-i] <COOKBOOK COOKBOOK ...>

If no cookbooks are specified, knife-audit will return a list of *all* cookbooks available on the currently configured Chef server or Opscode Platform organization, along with a count for each of how many nodes in the current Chef server or Opscode Platform organization explicitly reference that cookbook in their expanded runlist. 

Note that this does *not* include nodes that call the cookbook via 'include' and/or 'depends' statements.  The 'complete runlist' for nodes, which includes all cookbooks pulled in due to includes, is kept in Node.run_state.seen_recipes, but this is an ephemeral attribute and is only populated locally on the node during a client run.  It is not saved to the Chef server, therefore knife-audit cannot 'see' it 'unless' you have installed the knife_audit helper cookbook to your nodes (see 'Helper Cookbook' below).

If one or more cookbook names are specified on the command line, knife-audit will return a list of only those cookbooks and their counts.  Specifying a cookbook which is not available on the Chef server will result in an error.

The '-a' or '--all-cookbooks' option will cause knife-audit to check on each node for the attribute [:knife_audit][:seen_recipes] (which the helper cookbook saves there).  If it is present, it will use the contents of that attribute to determine which recipes the node is calling.  If it is not present, it will fall back (for that node) to the regular expanded runlist.  The output of knife-audit will, in this case, be in two parts:  The first will be identical to the default output and will display totals for all those nodes which do *not* have the seen_recipes attribute available.  The second part will be totals for all those nodes which *do* have the attribute available.  They are separated so that if the '-s' option is used, the nodes can be differentiated.

The '-t' or '--totals' option will cause knife-audit to present a single output section containing the merged totals of all nodes with and without the helper cookbook.  This is less accurate, but still useful and easier to read.

The '-s' or '--show-nodelist' option will cause knife-audit to include in its output a list of all nodes which reference each cookbook.

The '-i' or '--install-cookbook' option will cause knife-audit to copy the knife_audit helper cookbook into the currently configured Chef cookbook_path.  If there is already a directory or file there with that name, it will abort.  Note that you will need to 'knife cookbook upload knife_audit' once you have done this in order to push the cookbook to your Chef server; in addition, you will need to add the knife_audit cookbook to your node runlists. See 'Helper Cookbook' below for more information.

**NOTE** knife-audit retrieves an array of *all* nodes present on your chef server for each run.  As a result, it is relatively slow; if you have many ( >= 16) nodes, it will take noticeable wallclock time to complete its run.  In addition. it may use lots of memory to hold those node objects.


Helper Cookbook
---------------

The helper cookbook (knife_audit) consists of a single recipe (default) with a single resource in it - a ruby_block which saves node.run_state.seen_recipes to the attribute node[:knife_audit][:seen_recipes].  This preserves the *complete* runlist information from seen_recipes, which chef-client does not save to the chef server after constructing it in the compile phase.  Since the helper cookbook performs this attribute copy in a ruby_block, it will occur during the execute phase, guaranteeing that seen_recipes is complete (unless your runlist contains a cookbook which modifies the node's runlist!)  As a result, knife_audit can be called at any point in your runlist without affecting its function (again, unless your runlist modifies itself; in this case, best to call it first).


Disclaimer
----------

This is my first knife plugin, and I haven't been using Ruby that long.  Plus, I'm an op, not a software engineer. :-)  If you run into problems with knife-audit, by all means let me know; you can find me via the github page or on irc at freenode #chef, usually.  Thanks.


License terms
-------------
Authors:: J.B. Zimmerman 

Copyright:: Copyright (c) 2009-2011 J.B. Zimmerman

License:: Apache License, Version 2.0


Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

