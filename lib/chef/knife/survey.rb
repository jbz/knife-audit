#
## Author:: Jacob Zimmermann (<jzimmerman@mdsol.com>)
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
#

require 'chef/knife'
 
module KnifeSurvey
  class Promote < Chef::Knife
 
    deps do
      require 'chef/cookbook_loader'
      require 'chef/environment'
      require 'chef/knife/core/object_loader'
    end
 
    banner "knife survey <COOKBOOK COOKBOOK ...>"
 
    
    def run

      all_args = parse_name_args!
      cookbooks = all_args
      
      self.config = Chef::Config.merge!(config)
     
   
      # 1) Get a list of cookbooks available on the current server/org

      # 2) Get a list of nodes known to the current server/org

      # 3) Iterate over each node

        # 3a) Get node's runlist

        # 3b) Add the cookbooks/recipes in node's runlist to the node array's 'runlist' hash

        # 3c) For each recognized cookbook in the runlist, add to that cookbook's count variable

      # 4) Output total counts for each cookbook in cookbook list

      # 5) Output complete node/cookbook array


    end # 'run' def end


  end #class end

end #module end