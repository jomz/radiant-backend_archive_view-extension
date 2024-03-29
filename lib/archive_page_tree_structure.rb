module ArchivePageTreeStructure
  def tree_children
    tree_children = []
    last = edge_date(false)
    if last
      first = edge_date(true)
      current = first
      while(current <= last)
        tree_children.unshift ArchiveYearTreePage.new(self, current, last)
        current = current.next_year.beginning_of_year
      end
    end
    tree_children #+ children.find(:all, :conditions => ['virtual = ?', true])
  end

  def edge_date(first)
    if !first && children.find(:first, :conditions => 'updated_at is null')
      return Time.now
    end
    order = first ? 'asc' : 'desc'
    child = children.find(:first, :order => "published_at #{order}", :conditions => 'not(published_at is null)')
    edge = child.published_at if child
    child = children.find(:first, :order => "updated_at #{order}", :conditions => 'pages.published_at is null and not(pages.updated_at is null)')
    if child
      if first
        edge = child.updated_at if !edge || child.updated_at < edge
      else
        edge = child.updated_at if !edge || child.updated_at > edge
      end
    end
    edge
  end

  def tree_child(slug)
    first = [edge_date(true),Time.utc(slug.to_i)].max
    last = edge_date(false)
    ArchiveYearTreePage.new(self, first, last)
  end

  class ArchiveTreePage
    def virtual?
      true
    end
    def self.display_name
      'Page'
    end
    def class_name
      'Page'
    end
    def allowed_children_cache
      ""
    end
    def children
      tree_children
    end
    def sheet?
      false
    end
    def url
      "#{@parent.url}#{title}"
    end
    def status
      Status.new(:name => ' ')
    end
  end

  class ArchiveYearTreePage < ArchiveTreePage
    def initialize(parent, start_time, end_time=nil)
      @parent = parent
      @start_time = start_time
      @end_time = end_time
    end
    def id
      @start_time.strftime("#{@parent.id}_%Y")
    end
    def title
      @start_time.strftime("%Y")
    end
    def breadcrumb
      title
    end
    def tree_children
      start_month = @start_time.month
      end_month = 12
      end_month = @end_time.month if @end_time && @end_time.year <= @start_time.year
      (@start_time.month..end_month).map do |m|
        tree_child(m)
      end.reverse
    end
    def tree_child(slug)
      ArchiveMonthTreePage.new(@parent, @start_time.beginning_of_year.months_since(slug.to_i - 1))
    end
  end

  class ArchiveMonthTreePage < ArchiveTreePage
    def initialize(parent, start_time)
      @parent = parent
      @start_time = start_time
    end
    def id
      @start_time.strftime("#{@parent.id}_%Y_%m")
    end
    def title
      I18n.l @start_time, :format => "%B"
    end
    def breadcrumb
      title
    end
    def tree_children
      end_time = @start_time.next_month.beginning_of_month
      condition_string = 'pages.virtual = ? and (pages.published_at >= ? and pages.published_at < ? or (pages.published_at is null and ('
      condition_string += 'pages.updated_at is null or ' if Time.now.utc.beginning_of_month == @start_time.beginning_of_month
      condition_string += '(pages.updated_at >= ? and pages.updated_at < ?))))'
      @parent.children.find(:all,
        :conditions => [
          condition_string,
          false,
          @start_time,
          end_time,
          @start_time,
          end_time,
          ],
        :order => 'published_at desc, updated_at desc'
      )
    end
  end
end
