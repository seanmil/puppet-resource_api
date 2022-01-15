require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'integer_namevar',
  docs: <<-EOS,
    This type provides Puppet with the capabilities to manage ...
  EOS
  attributes:   {
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    id: {
      type: 'Init[Integer]',
      desc: 'The ID of the resource.',
      behaviour: :namevar,
    },
    prop: {
      type: 'Optional[String]',
      desc: 'Other prop',
    },
  },
)
