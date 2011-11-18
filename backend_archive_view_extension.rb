# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'
require 'radiant-backend_archive_view-extension'
class BackendArchiveViewExtension < Radiant::Extension
  version     RadiantBackendArchiveViewExtension::VERSION
  description RadiantBackendArchiveViewExtension::DESCRIPTION
  url         RadiantBackendArchiveViewExtension::URL
  
  def activate
    ArchivePage.send :include, ArchivePageTreeStructure
    Admin::PagesController.send(:include, PagesControllerExtensions)
    Admin::NodeHelper.send(:include, NodeHelperChanges)
  end
end
