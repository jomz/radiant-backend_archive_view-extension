module PagesControllerExtensions
  def self.included(clazz)
    clazz.class_eval do
      def index_with_tree_children
        if params[:page_id] && (Page.find(params[:page_id]).respond_to?(:tree_children)) || params[:page_id] =~ /_/
          id, *tree_children = params[:page_id].split('_')
          @parent = tree_children.inject(Page.find(id)) {|current, slug| current.tree_child(slug) }
          @level = params[:level].to_i
#          @template_name = 'index'
          response.headers['Content-Type'] = 'text/html;charset=utf-8'
          render :action => 'children.html.haml', :layout => false, :locals => {:simple => true}
        else
          index_without_tree_children
        end
      end
      alias_method_chain :index, :tree_children
      
      def tree_children
        id, *tree_children = params[:page_id].split('_')
        @parent = tree_children.inject(Page.find(id)) {|current, slug| current.tree_child(slug) }
        @level = params[:level].to_i
        @template_name = 'index'
        response.headers['Content-Type'] = 'text/html;charset=utf-8'
        render :action => 'children.html.haml', :layout => false
      end
      
      def more_nodes
        id, *tree_children = params[:page_id].split('_')
        if tree_children.nil? # regular page
          @parent = Page.find id
        else
          @parent = tree_children.inject(Page.find(id)) {|current, slug| current.tree_child(slug) }
        end

        @level = params[:level].to_i
        @offset = params[:offset].to_i
        @end = @offset + 10
        @template_name = 'index'
        response.headers['Content-Type'] = 'text/html;charset=utf-8'
        render :action => 'children.html.haml', :layout => false
      end
      
      before_filter :include_admin_tree_javascript, :only => :index
      private
        def include_admin_tree_javascript
          @content_for_page_scripts ||= ''
          @content_for_page_scripts <<(<<-EOF)
	    Object.extend(SiteMapBehavior.prototype, {
	      onclick: function(event) {
          if (this.isExpander(event.target)) {
            var row = event.findElement('tr');
            if (this.hasChildren(row)) {
              this.toggleBranch(row, event.target);
            }
          }
      		if (this.isMoreNodeFetcher(event.target)) {
      			var row = event.findElement('tr')
      			this.getMoreNodes(row, event.target);
      			return false;
      		}
        },
	      extractPageId: function(row) {
	        if (/page_([\\d]+(_[\\d_A-Z]+)?)/i.test(row.id)) {
	          return RegExp.$1;
		      }
	        else {
	          return row.id;
	        }
	      },
        extractOffset: function(row) {
          var level = this.extractLevel(row.previous(1))
          var counter = 10
          var found = 0
          while(found == 0){
            if(this.extractLevel(row.previous(counter)) == level)
              counter += 1
            else
              found = 1
          }
          return counter
        },        
        isMoreNodeFetcher: function(element) {
          return element.match('a.more_node_fetcher');
        },
	      getBranch: function(row) {
	        var id = this.extractPageId(row);
          var level = this.extractLevel(row);
          var spinner = $('busy_' + id);
          
          if(id.include("_")){
      			new Ajax.Updater(
      				row,
      				'/admin/pages/' + id + '/tree_children?level=' + level,
      				{
      					insertion: "after",
      					onLoading:  function() { spinner.show(); this.updating = true  }.bind(this),
      	        onComplete: function() { spinner.fade(); this.updating = false }.bind(this),
      	        method: 'get'
      				}
      			);
      		}
          else{
            new Ajax.Updater(
            	row,
      	      '/admin/pages/' + id + '/children?level=' + level,
      	      {
      	        insertion: "after",
      	        onLoading:  function() { spinner.show(); this.updating = true  }.bind(this),
      	        onComplete: function() { spinner.fade(); this.updating = false }.bind(this),
      	        method: 'get'
      	      }
      	    );
      		}
        },
        getMoreNodes: function(row) {
          var offset = this.extractOffset(row);
          var level = this.extractLevel(row.previous(offset));
          var id = this.extractPageId(row.previous(offset));
          var spinner = $('node_fetcher_' + id + '_spinner');
          new Ajax.Updater(
    				row,
    				'/admin/pages/' + id + '/more_nodes/' + offset + '?level=' + level,
    				{
    					insertion: "before",
    					onLoading:  function() { spinner.show(); this.updating = true  }.bind(this),
    	        onComplete: function() { spinner.fade(); this.updating = false }.bind(this),
    	        method: 'get'
    				}
    			);
        }
	    });
	  EOF
        end
    end
  end
end
