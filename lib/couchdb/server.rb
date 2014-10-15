require 'json'
require 'rest-client'


module Throw
  class Server
    attr_reader :db_name
    attr_reader :host

    def initialize(db_name, host = nil)
      @db_name = db_name
      @host = host || 'localhost:5984'
      @_designs = load_designs
    end

    def update_design(name, details = {})
      details = begin
        get("_design/#{name}").merge(details)
      rescue RestClient::ResourceNotFound
        details
      end

      put("_design/#{name}", details)

      @_designs[name.to_sym] = Design.new(self, details)
    end

    def find(id)
      get id
    end

    def save(doc, opts = {})
      doc.has_key?(:_id) ? put(doc[:_id], doc) : post('', doc)
    end

    def exists?(id)
      !!head(id)
    rescue RestClient::ResourceNotFound
      false
    end

    def uuids(count: 10)
      request(:get, '_uuids', count: count)[:uuids]
    end

    def delete(path)
      current = get(path)
      data = {_rev: current[:_rev]} if current
      db_request(:delete, path, data)
    end

    def head(path)
      db_request(:head, path)
    end

    def get(path, params = {})
      db_request(:get, path, params)
    end

    def put(path, data = {})
      db_request(:put, path, data)
    end

    def post(path, data = {})
      db_request(:post, path, data)
    end

    def reset!
      request(:delete, @db_name)
      request(:put, @db_name)
    end

    private

    def method_missing(name, *args, &block)
      @_designs[name.to_sym] || super
    end

    def db_request(method, path, params = {})
      request(method, "#{@db_name}/#{path}", params)
    end

    def request(method, path, params = {})
      url = "http://#{@host}/#{path}"

      response = case method
      when :get
        params = quote_params(params)
        RestClient.get(url, params: params, accept: :json, content_type: :json)
      when :post
        RestClient.post(url, JSON.dump(params), accept: :json, content_type: :json)
      when :put
        RestClient.put(url, JSON.dump(params), accept: :json, content_type: :json)
      when :delete
        RestClient.delete(url, params: JSON.dump(params), accept: :json)
      when :head
        RestClient.head(url, accept: :json)
      end

      JSON.parse(response, symbolize_names: true) unless response.nil? || response.empty?
    end

    def load_designs
      designs = get('_all_docs', startkey: '_design/', endkey: '_design0')
      designs[:rows].inject({}) do |memo, row|
        id = row[:id] || row[:_id]
        memo[id.split('/').last.to_sym] = Design.new(self, get(id))
        memo
      end
    end

    def quote_params(params)
      params[:startkey] = JSON.dump(params[:startkey]) if params.has_key? :startkey
      params[:endkey] = JSON.dump(params[:endkey]) if params.has_key? :endkey
      params
    end
  end
end
