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
  class Survey < Chef::Knife
 
    deps do
      require 'chef/cookbook_loader'
      require 'chef/environment'
#      require 'chef/knife/core/object_loader'
      require 'chef/node'
      require 'chef/run_list'
#      require 'chef/knife/search'
#      require 'chef/search/query'
      require 'chef/json_compat' 
      require 'chef/shef/ext'
   end
 
    banner "knife survey <COOKBOOK COOKBOOK ...>"
 
    option :all_versions,
      :short => "-a",
      :long => "--all-versions",
      :description => "Show all cookbook versions."

    
    def run

#      all_args = parse_name_args!
#      cookbooks = all_args
      
      self.config = Chef::Config.merge!(config)
   
      # 1) Get a list (hash, actually, with key of 'name') of cookbooks available on the current server/org

      env		= config[:environment]
      num_versions 	= config[:all_versions] ? "num_versions=all" : "num_versions=1"
      api_endpoint	= env ? "/environments/#{env}/cookbooks?#{num_versions}" : "/cookbooks?#{num_versions}"
      cookbook_list	= rest.get_rest(api_endpoint)
#      format_cookbook_list_for_display(cookbook_list).each do |line|
#        puts line
#        ui.msg(line)
#      end

      # add count => 0 to each cookbook hash
      cookbook_list.each do |name,book|
        book["count"] = 0 
      #  puts "Found cookbook with name #{name} : #{book.inspect}"
      end


      # 2) Get a list of nodes known to the current server/org

#      node_list		= (env ? Chef::Node.list_by_environment(env) : Chef::Node.list )
#      output(format_list_for_display(node_list))

      query = "*:*"  # find all nodes

      Shef::Extensions.extend_context_object(self)
      node_list = nodes.find(query) 

      # 3) Iterate over each node

      node_list.each do |node|

        # 3a) Get node's runlist

        # using expand!.recipes catches multi-level roles (roles with roles with recipes, etc.)
        recipes = node.expand!.recipes.to_a
        node_cookbook_list = recipes.map{ |x| x.match(/[^\:]+/)[0] }.uniq

        puts node_cookbook_list.inspect
        
        # 3b) Add the cookbooks/recipes in node's runlist to the node array's 'runlist' hash

        # 3c) For each recognized cookbook in the runlist, add to that cookbook's count variable

#      end # step 3 iterate end

      # 4) Output total counts for each cookbook in cookbook list

      # 5) Output complete node/cookbook array


    end # 'run' def end


  end #class end

end #module end
