knife-survey
========
A Chef plugin for determining which cookbooks are in use on which nodes of your Chef server or Opscode organization.
Allows you to safely maintain a chef cookbook set by determining which cookbooks are currently in use by nodes (included in node runlists).

Requirements
---------------

Installing knife-survey
-------------------
Be sure you are running the latest version of Chef.

    gem install knife-flow


Plugins
---------------

### survey 

    knife survey \<COOKBOOK COOKBOOK ...\>



License terms
-------------
Authors:: Jacob Zimmerman 

Copyright:: Copyright (c) 2009-2011 Medidata Solutions Worldwide, Inc.

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

