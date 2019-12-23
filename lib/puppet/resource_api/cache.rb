class Puppet::ResourceApi::Cache
  attr_reader :type

  def initialize(type_definition)
    @type = type_definition
    @cache = {}
    @complete = false
  end

  def build_key(resource_hash)
    if type.namevars.size > 1
      Hash[type.namevars.map { |attr| [attr, resource_hash[attr]] }]
    else
      resource_hash[type.namevars[0]]
    end
  end

  def key?(key)
    @cache.key?(key)
  end

  def store(resource_hash)
    @cache[build_key(resource_hash)] = resource_hash
  end

  def get(key)
    raise("No data cached for #{key}") unless @cache.key?(key)
    @cache[key].dup
  end

  def remove(key)
    raise("No data cached for #{key}") unless @cache.key?(key)
    @cache.delete(key)
  end

  def complete
    @complete = true
  end

  def complete?
    @complete
  end

  def all
    raise("Cannot call 'all' on cache unless cache is complete") unless complete?
    @cache.values
  end
end