module NodeHelperChanges
  def self.included(clazz)
    clazz.class_eval do
      def node_title
        %{<span class="title">#{ @current_node.breadcrumb }</span>}
      end
      
      def expanded_rows
        unless @expanded_rows
	        @expanded_rows = case
          when rows = cookies[:expanded_rows]
            rows.split(',').select { |x| /^\d+(_[\d_a-z]+)?$/i === x rescue nil }.compact
          else
            []
          end

	        if homepage and !@expanded_rows.include?(homepage.id.to_s)
	          @expanded_rows << homepage.id.to_s
	        end
	      end
	      @expanded_rows
      end
      
      def expanded
        show_all? || expanded_rows.include?(@current_node.id.to_s)
      end
        
      def children_class
        if has_children?
          if expanded
            " children_visible"
          else
            " children_hidden"
          end
        else
          " no_children"
        end
      end
      
      def expander(level)
        unless !has_children? or level == 0
          image((expanded ? "collapse" : "expand"), 
                :class => "expander", :alt => 'toggle children', 
                :title => '')
        else
          ""
        end
      end      
      
      def has_children?
        if @current_node.respond_to? :tree_children
          @current_node.tree_children.any?
        else
          @current_node.children.any?
        end
      end
      
      def prepare_node(page)
        @current_node = page
        page.extend MenuRenderer
        page.view = self
        if page.additional_menu_features?
          page.extend(*page.menu_renderer_modules)
        end
      end
      
      def render_nodes(pages, locals = {})
        locals.reverse_merge!(:level => 0, :simple => false).merge!(:pages => pages)
        render :partial => 'admin/pages/nodes', :locals =>  locals
      end
    end
  end
end
