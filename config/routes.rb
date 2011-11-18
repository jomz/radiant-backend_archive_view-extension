ActionController::Routing::Routes.draw do |map|
  map.with_options(:controller => 'admin/pages') do |pages| 
    pages.tree_children 'admin/pages/:page_id/tree_children', :action => "tree_children"
    pages.more_nodes 'admin/pages/:page_id/more_nodes/:offset', :action => "more_nodes"
  end
end