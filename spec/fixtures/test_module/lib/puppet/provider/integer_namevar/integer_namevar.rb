require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'

# Implementation for the integer_namevar type using the Resource API.
class Puppet::Provider::IntegerNamevar::IntegerNamevar < Puppet::ResourceApi::SimpleProvider
  def initialize
    @current_values ||= [
      { title: "title-100", id: 100, ensure: 'present', prop: 'a' },
      { title: "title-101", id: 101, ensure: 'present', prop: 'b' },
    ]
  end

  def get(_context)
    @current_values
  end

  def create(context, name, should)
    context.notice("Creating #{name.inspect} with #{should.inspect}")
    context.notice("namevar :id value #{should[:id].inspect}")
    context.notice("prop :prop value #{should[:prop].inspect}")
  end

  def update(context, name, should)
    context.notice("Updating #{name.inspect} with #{should.inspect}")
    context.notice("namevar :id value #{should[:id].inspect}")
    context.notice("prop :prop value #{should[:prop].inspect}")
  end

  def delete(context, name)
    context.notice("Deleting #{name.inspect}")
  end
end
