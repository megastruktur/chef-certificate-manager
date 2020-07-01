property :path,            String,        name_property: true
property :content,         String,        required: true
# Expiration Date example: Jun 29 23:59:59 2022 GMT
property :expiration_date, String
property :is_base64,       [true, false], default: false
property :owner,           String,        default: "root"
property :group,           String,        default: "root"
property :mode,            String,        default: "600"

action :create do
  
  # Validate the expiration date
  if new_resource.expiration_date
    require 'date'
    current_date = Time.now
    # "%b %d %H:%M:%S %Y %Z"
    cert_expiration_date = Time.parse(new_resource.expiration_date)

    if current_date > cert_expiration_date
      raise "Certificate #{new_resource.path} has expired (valid to #{new_resource.expiration_date})"
    end
  end

  dirname = ::File.dirname(new_resource.path)
  temp_certname = "#{new_resource.path}_tmp"

  # Set readable by server
  directory dirname do
    recursive true
    owner new_resource.owner
    group new_resource.group
  end

  file temp_certname do
    content new_resource.content
    user "root"
    group "root"
  end

  # Decode base64 and create cert temp
  execute 'cert_base64_decode' do
    command "base64 -d #{temp_certname} > #{new_resource.path}_decoded && rm #{temp_certname} && mv #{new_resource.path}_decoded #{temp_certname}"
    only_if {new_resource.is_base64}
  end


  # Remove base64 file and set proper permissions.  #
  execute 'cert_install' do
    cwd dirname
    command "cat #{temp_certname} > #{new_resource.path} && rm #{temp_certname} && chmod #{new_resource.mode} #{new_resource.path}"
    user new_resource.owner
    group new_resource.group
    not_if {compare_checksum(new_resource.path, temp_certname)}
  end

end

# Checksum Comparator.
def compare_checksum(filename1, filename2)
  if ::File.exist?(filename1) && ::File.exist?(filename2)
    require 'digest'
    checksum1 = Digest::SHA256.file(filename1).hexdigest
    checksum2 = Digest::SHA256.file(filename2).hexdigest
    return checksum1 == checksum2
  end
  return false
end
