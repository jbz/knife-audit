#
## Author:: Jacob Zimmermann (<jbzimmerman91@gmail.com>)
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

    option :all_cookbooks,
      :short => "-a",
      :long => "--all-cookbooks",
      :description => "Show all cookbook references, including those from seen_recipes if available on nodes from helper cookbook"

    option :totals,
      :short => "-t",
      :long => "--totals",
      :description => "Show cookbook count totals for all node types"

    option :install_cookbook,
      :short => "-i",
      :long => "--install-cookbook",
      :description => "Install knife_audit helper cookbook into current chef cookbook directory"

    def run

      if @name_args.empty? 
        display_cookbooks = {}
      else
        display_cookbooks = @name_args 
      end

      self.config = Chef::Config.merge!(config)

      # If :install_cookbook flag is set, just install the cookbook and return (exit).
      if config[:install_cookbook]

        unless config[:cookbook_path]
          ui.msg("No cookbook path set in Chef config, cannot install cookbook.")
          return
        end
      
        source_path = File.dirname(__FILE__) + "/knife_audit_cookbook"
        dest_path = config[:cookbook_path].first + "/knife_audit"

        if File.exist?(dest_path)
          ui.msg("knife_audit cookbook already present in cookbook directory #{config[:cookbook_path].first} - aborting...")
        else
          FileUtils.copy_entry(source_path, dest_path)
          ui.msg("knife-audit cookbook copied to Chef cookbook directory #{config[:cookbook_path].first}")
        end

        return
      end
   
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
          begin
            cookbook_list.merge!(rest.get_rest(api_endpoint))
          rescue
            ui.error("Cookbook #{cookbook_name} could not be found on the server!")
            exit 1
          end 
        end 

      end


      # add count => 0 to each cookbook hash
      cookbook_list.each do |name,book|
        book["count"] = 0
        book["seen_recipe_count"] = 0
        book["nodes"] = []
        book["seen_recipe_nodes"] = []
      end


      # 2) Get an array of Chef::Nodes known to the current server/org

      query = "*:*"  # find all nodes

      Shef::Extensions.extend_context_object(self)
      node_list = nodes.find(query) 

      # 3) Iterate over each node

      node_list.each do |node|

        # 3a) Get node's runlist

        # Check to see if we need the seen_recipes total or not; if no, skip.  
        # If yes use seen_recipes if it's available. If it's not available, fall back 
        # to the node.recipes contents.
        if (config[:all_cookbooks] || config[:totals])
          recipes = (node["knife_audit"] && node["knife_audit"]["seen_recipes"].keys) || node.expand!.recipes.to_a
          if node["knife_audit"] && node["knife_audit"]["seen_recipes"] 
            node_seen_recipe_flag = true
          end
        else
          # If not, use node.recipes. Using expand!.recipes catches multi-level roles 
          # (roles with roles with recipes, etc.)
          recipes = node.expand!.recipes.to_a
        end

        node_cookbook_list = recipes.map{ |x| x.match(/[^\:]+/)[0] }.uniq

        # 3b) For each cookbook in the node runlist, if it's in our cookbook array increment its count and
        #     add the node to its running node array

        node_cookbook_list.each do |cookbook|
	        if cookbook_list.has_key?(cookbook)
            # Up the appropriate ookbook count and add node to appropriate nodes array
            if node_seen_recipe_flag
              cookbook_list[cookbook]["seen_recipe_count"] += 1
              cookbook_list[cookbook]["seen_recipe_nodes"] << node.name
            else
              cookbook_list[cookbook]["count"] += 1
              cookbook_list[cookbook]["nodes"] << node.name
            end
          end
        end
      node_seen_recipe_flag = false

      end # step 3 iterate end

      # 4) Output

      unless config[:totals]
        ui.msg("Cookbook audit from node runlists:")

        format_cookbook_runlist_list_for_display(cookbook_list).each do |line|
          ui.msg(line)
        end
      end

      if config[:all_cookbooks]
        puts("\n")

        ui.msg("Cookbook audit from seen_recipes:")

        format_cookbook_seenlist_list_for_display(cookbook_list).each do |line|
          ui.msg(line)
        end
      end

      if config[:totals]
        puts("\n")

        ui.msg("Cookbook audit totals - runlist-only nodes + seen_recipes:")

        format_cookbook_totallist_list_for_display(cookbook_list).each do |line|
          ui.msg(line)
        end
      end


    end # 'run' def end


    def format_cookbook_runlist_list_for_display(item)
      key_length = item.empty? ? 0 : item.keys.map {|name| name.size }.max + 2
      if config[:show_nodelist]
        item.sort.map do |name, cookbook|
          "#{name.ljust(key_length)} #{cookbook["count"]} [ #{cookbook["nodes"].join('  ')} ]"
        end
      else
        item.sort.map do |name, cookbook|
          "#{name.ljust(key_length)} #{cookbook["count"]}"
        end
      end
         
    end # format_cokbook_runlist... def end

    def format_cookbook_seenlist_list_for_display(item)
      key_length = item.empty? ? 0 : item.keys.map {|name| name.size }.max + 2
      if config[:show_nodelist]
        item.sort.map do |name, cookbook|
          "#{name.ljust(key_length)} #{cookbook["seen_recipe_count"]} [ #{cookbook["seen_recipe_nodes"].join('  ')} ]"
        end
      else
        item.sort.map do |name, cookbook|
          "#{name.ljust(key_length)} #{cookbook["seen_recipe_count"]}"
        end
      end
         
    end # format_cokbook_seenlist... def end

    def format_cookbook_totallist_list_for_display(item)
      key_length = item.empty? ? 0 : item.keys.map {|name| name.size }.max + 2
      if config[:show_nodelist]
        item.sort.map do |name, cookbook|
          cookbook_display = (cookbook["seen_recipe_nodes"] + cookbook["nodes"]).uniq
          cookbook_count = cookbook["seen_recipe_count"] + cookbook["count"]
          "#{name.ljust(key_length)} #{cookbook_count} [ #{cookbook_display.join('  ')} ]"
        end
      else
        item.sort.map do |name, cookbook|
          cookbook_count = cookbook["seen_recipe_count"] + cookbook["count"]
          "#{name.ljust(key_length)} #{cookbook_count}"
        end
      end
         
    end # format_cokbook_seenlist... def end



  end #class end

end #module end
