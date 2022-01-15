# frozen_string_literal: true

require 'spec_helper'
require 'open3'

RSpec.describe 'a type with an integer namevar' do
  let(:common_args) { '--verbose --trace --strict=error --modulepath spec/fixtures' }

  describe 'using `puppet resource`' do
    it 'is returns the values correctly' do
      stdout_str, status = Open3.capture2e("puppet resource #{common_args} integer_namevar")
      expect(stdout_str.strip).to match %r{^integer_namevar}
      expect(status).to eq 0
    end
    it 'returns the required resource correctly' do
      stdout_str, status = Open3.capture2e("puppet resource #{common_args} integer_namevar 100")
      expect(stdout_str.strip).to match %r{^integer_namevar \{ \'100\'}
      expect(stdout_str.strip).to match %r{ensure\s*=> \'present\'}
      expect(stdout_str.strip).to match %r{prop\s*=> \'a\'}
      expect(status).to eq 0
    end
    it 'creates a previously absent resource' do
      stdout_str, status = Open3.capture2e("puppet resource #{common_args} integer_namevar 200 prop=foo")
      expect(stdout_str.strip).to match %r{^integer_namevar \{ \'200\'}
      expect(stdout_str.strip).to match %r{ensure\s*=> \'present\'}
      expect(stdout_str.strip).to match %r{prop\s*=> \'foo\'}
      expect(status).to eq 0
    end
    it 'updates an existing resource' do
      stdout_str, status = Open3.capture2e("puppet resource #{common_args} integer_namevar 100 prop=foo")
      expect(stdout_str.strip).to match %r{^integer_namevar \{ \'100\'}
      expect(stdout_str.strip).to match %r{ensure\s*=> \'present\'}
      expect(stdout_str.strip).to match %r{prop\s*=> \'foo\'}
      expect(status).to eq 0
    end
    it 'will remove an existing resource' do
      stdout_str, status = Open3.capture2e("puppet resource #{common_args} integer_namevar 100 ensure=absent")
      expect(stdout_str.strip).to match %r{^integer_namevar \{ \'100\'}
      expect(stdout_str.strip).to match %r{ensure\s*=> \'absent\'}
      expect(status).to eq 0
    end
    it 'will ignore the title if namevar is provided' do
      stdout_str, status = Open3.capture2e("puppet resource #{common_args} integer_namevar whatever id=100")
      expect(stdout_str.strip).to match %r{^integer_namevar \{ \'whatever\'}
      expect(stdout_str.strip).to match %r{prop\s*=> \'a\'}
      expect(stdout_str.strip).to match %r{ensure\s*=> \'present\'}
      expect(status).to eq 0
    end
  end

  describe 'using `puppet apply`' do
    require 'tempfile'

    let(:common_args) { super() + ' --detailed-exitcodes' }

    # run Open3.capture2e only once to get both output, and exitcode # rubocop:disable RSpec/InstanceVariable
    before(:each) do
      Tempfile.create('acceptance') do |f|
        f.write(manifest)
        f.close
        @stdout_str, @status = Open3.capture2e("puppet apply #{common_args} #{f.path}")
      end
    end

    context 'when managing a present instance' do
      let(:manifest) { 'integer_namevar { atitle: id => 100, prop => "a" }' }

      it { expect(@stdout_str).not_to match %r{integer_namevar} }
      it { expect(@status.exitstatus).to eq 0 }
    end

    context 'when creating a previously absent instance' do
      let(:manifest) { 'integer_namevar { atitle: id => 200, prop => "foo" }' }

      it { expect(@stdout_str).to match %r{Integer_namevar\[atitle\]/ensure: defined 'ensure' as 'present'} }
      it { expect(@status.exitstatus).to eq 2 }
    end

    context 'when managing an absent instance' do
      let(:manifest) { 'integer_namevar { atitle: id => 200, ensure => absent }' }

      it { expect(@stdout_str).not_to match %r{integer_namevar} }
      it { expect(@status.exitstatus).to eq 0 }
    end

    context 'when updating a present instance' do
      let(:manifest) { 'integer_namevar { atitle: id => 100, prop => "foo" }' }

      it { expect(@stdout_str).to match %r{integer_namevar\[100\]: Updating: namevar :id value 100} }
      it { expect(@stdout_str).to match %r{integer_namevar\[100\]: Updating: prop :prop value "foo"} }
      it { expect(@status.exitstatus).to eq 2 }
    end

    context 'when removing a previously present instance' do
      let(:manifest) { 'integer_namevar { sometitle: id => 100, ensure => absent }' }

      it { expect(@stdout_str).to match %r{Integer_namevar\[sometitle\]/ensure: undefined 'ensure' from 'present'} }
      it { expect(@status.exitstatus).to eq 2 }
    end

    context 'when using resource purging' do
      let(:manifest) { 'resources { integer_namevar: purge => true }' }

      it { expect(@stdout_str).to match %r{Integer_namevar\[sometitle\]/ensure: undefined 'ensure' from 'present'} }
      it { expect(@status.exitstatus).to eq 2 }
    end
    # rubocop:enable RSpec/InstanceVariable
  end
end
