begin test_name "puppet module install (without dependencies)"

step 'Setup'
require 'resolv'; ip = Resolv.getaddress('forge-dev.puppetlabs.com')
apply_manifest_on master, "host { 'forge.puppetlabs.com': ip => '#{ip}' }"
apply_manifest_on master, "file { ['/etc/puppet/modules', '/usr/share/puppet/modules']: recurse => true, purge => true, force => true }"

step "Install a module with dependencies"
on master, puppet("module install pmtacceptance-java") do
  assert_equal '', stderr
  assert_equal <<-STDOUT, stdout
Preparing to install into /etc/puppet/modules ...
Downloading from http://forge.puppetlabs.com ...
Installing -- do not interrupt ...
/etc/puppet/modules
└─┬ pmtacceptance-java (v1.7.1)
  └── pmtacceptance-stdlib (v0.0.1)
STDOUT
end
on master, '[ -d /etc/puppet/modules/java ]'
on master, '[ -d /etc/puppet/modules/stdlib ]'

ensure step "Teardown"
apply_manifest_on master, "host { 'forge.puppetlabs.com': ensure => absent }"
apply_manifest_on master, "file { ['/etc/puppet/modules', '/usr/share/puppet/modules']: recurse => true, purge => true, force => true }"
end
