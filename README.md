knife-audit
========
A knife plugin for determining which cookbooks are in use on which nodes of your Chef server or Opscode organization.
Allows you to safely maintain a chef cookbook set by determining which cookbooks are currently in use by nodes (included in node runlists).


Installing knife-audit
-------------------
Be sure you are running the latest version of Chef.


#### Script install

Copy the knife-audit script from https://github.com/jbz/knife-audit/blob/master/lib/chef/knife/audit.rb to your .chef/plugins/knife directory.


Usage
---------------

    knife audit <COOKBOOK COOKBOOK ...>

If no cookbooks are specified, knife-audit will return a list of *all* cookbooks available on the currently configured Chef server or Opscode Platform organization, along with a count for each of how many nodes in the current Chef server or Opscode Platform organization explicitly reference that cookbook in their expanded runlist. 

Note that this does *not* include nodes that call the cookbook via 'include' and/or 'depends' statements.  The 'complete runlist' for nodes, which includes all cookbooks pulled in due to includes, is kept in Node.run_state.seen_recipes], but this is an ephemeral attribute and is only populated locally on the node during a client run.  It is not saved to the Chef server, therefore knife-audit cannot 'see' it.

If one or more cookbook names are specified on the command line, knife-audit will return a list of only those cookbooks and their counts.  Specifying a cookbook which is not available on the Chef server will result in an error.

The '-s' or '--show-nodelist' option will cause knife-audit to include in its output a list of all nodes which reference each cookbook.


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

