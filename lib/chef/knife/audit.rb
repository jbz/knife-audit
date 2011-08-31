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
 
module KnifeAudit
  class Audit < Chef::Knife
 
    deps do
      require 'chef/cookbook_loader'
      require 'chef/environment'
      require 'chef/node'
      require 'chef/run_list'
      require 'chef/json_compat' 
      require 'chef/shef/ext'
    end
 
    banner "knife audit <COOKBOOK COOKBOOK ...>"
 
    option :show_nodelist,
      :short => "-s",
      :long => "--show-nodelist",
      :description => "Show all nodes running each cookbook"

    def run

      unless @name_args.empty? 
        display_cookbooks = @name_args 
      end

      self.config = Chef::Config.merge!(config)
   
      # 1) Get a list (hash, actually, with key of 'name') of cookbooks available on the current server/org
      #    unless we've been given a cookbook/cookbooks on the command line
      env		= config[:environment]
      num_versions 	= config[:all_versions] ? "num_versions=all" : "num_versions=1"
      
      if display_cookbooks.empty?
        api_endpoint	= env ? "/environments/#{env}/cookbooks?#{num_versions}" : "/cookbooks?#{num_versions}"
        cookbook_list	= rest.get_rest(api_endpoint)
      else
        cookbook_list	= {}
        display_cookbooks.each do |cookbook_name|
          api_endpoint	= env ? "/environments/#{env}/cookbooks/#{cookbook_name}" : "cookbooks/#{cookbook_name}"
          cookbook_list.merge!(rest.get_rest(api_endpoint))
        end 
      end

#      puts cookbook_list.inspect

      # add count => 0 to each cookbook hash
      cookbook_list.each do |name,book|
        book["count"] = 0 
        book["nodes"] = []
      end


      # 2) Get an array of Chef::Nodes known to the current server/org

      query = "*:*"  # find all nodes

      Shef::Extensions.extend_context_object(self)
      node_list = nodes.find(query) 

      # 3) Iterate over each node

      node_list.each do |node|

        # 3a) Get node's runlist

        # using expand!.recipes catches multi-level roles (roles with roles with recipes, etc.)
        recipes = node.expand!.recipes.to_a
        node_cookbook_list = recipes.map{ |x| x.match(/[^\:]+/)[0] }.uniq

        # 3b) For each cookbook in the node runlist, if it's in our cookbook array increment its count and
        #     add the node to its running node array

        node_cookbook_list.each do |cookbook|
	  if cookbook_list.has_key?(cookbook)
            # Up the cookbook count
            cookbook_list[cookbook]["count"] += 1
            # Add the node to the cookbook's nodes array 
            cookbook_list[cookbook]["nodes"] << node.name
          end
        end

      end # step 3 iterate end

      # 4) Output total counts for each cookbook in cookbook list

      format_cookbook_audit_list_for_display(cookbook_list).each do |line|
        ui.msg(line)
      end

      # 5) Output complete node/cookbook array

    end # 'run' def end


    def format_cookbook_audit_list_for_display(item)
      key_length = item.empty? ? 0 : item.keys.map {|name| name.size }.max + 2
      if config[:show_nodelist]
        item.sort.map do |name, cookbook|
          "#{name.ljust(key_length)} #{cookbook["count"]}   [ #{cookbook["nodes"].join('  ')} ]"
        end
      else
        item.sort.map do |name, cookbook|
          "#{name.ljust(key_length)} #{cookbook["count"]}"
        end
      end
         
    end # format_cokbook_audit... def end


  end #class end

end #module end
