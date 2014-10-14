module CouchDB
  class Design
    def initialize(server, details, query = nil)
      @server = server
      @details = details
      @id = details[:id] || details[:_id]
      @name = @id.split('/').last if @details
      @query = query || []

      @views = @details[:views].inject({}) do |memo, (name, value)|
        memo[name] = name
        memo[name.to_s.gsub('-', '_').to_sym] = name
        memo
      end

      @lists = @details[:lists].inject({}) do |memo, (name, value)|
        memo[name] = name
        memo[name.to_s.gsub('-', '_').to_sym] = name
        memo
      end
    end

    def clone
      Design.new(@server, @details, @query ? @query.clone : nil)
    end

    def <<(name)
      @query << name
      self
    end

    def run(*args, &block)
      view_name = get_query_view
      list_name = get_query_list

      res = if view_name && list_name
        @server.get("_design/#{@name}/_list/#{list_name}/#{view_name}", *args)
      elsif view_name
        @server.get("_design/#{@name}/_view/#{view_name}", *args)
      end

      return res unless block_given?
      yield res
    end

    private

    def get_query_view
      name = @query.select{|q| @views.has_key? q.to_sym}.first
      name = @views[name] if name
      name
    end

    def get_query_list
      name = @query.select{|q| @lists.has_key? q.to_sym}.first
      name = @lists[name] if name
      name
    end

    def method_missing(name, *args, &block)
      copy = clone << name
      return copy unless block_given?
      yield copy
    end
  end
end
