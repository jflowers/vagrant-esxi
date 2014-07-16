require "log4r"
require "pathname"
require "tempfile"

module VagrantPlugins
  module ESXi
    module Util
      class SSH
        class << self
          def esxi_host
            return @esxi_host unless @esxi_host.nil?

            @esxi_host = Class.new{
              def communicate
                return @communicate unless @communicate.nil?

                @communicate = Vagrant.plugin("2").manager.communicators[:ssh].new(self)
              end

              def ssh_info
                return @ssh_info unless @ssh_info.nil?
                
                provider_config = ::VagrantPlugins::ESXi::Config.instance
                
                @ssh_info = {
                  :host => provider_config.host,
                  :port => "22",
                  :username => provider_config.user,
                  :private_key_path => [provider_config.ssh_key_path]
                }
              end

              def config
                return @config unless @config.nil?

                @config = Class.new{
                  def ssh
                    return @ssh unless @ssh.nil?
                
                    @ssh = Class.new{
                      def shell
                        "sh -l"
                      end
                      def pty
                        false
                      end
                      def keep_alive
                        true
                      end
                    }.new
                  end
                }.new
              end
            }.new
          end

          def get_vm_path(id)
            vm_path_name = nil
            esxi_host.communicate.execute("vim-cmd vmsvc/get.summary #{id}") do |type, data|
             if [:stderr, :stdout].include?(type)
               vm_path_name_match = data.match(/vmPathName\s+=\s+"(.*)"/)
               vm_path_name = vm_path_name_match.captures[0].strip if vm_path_name_match
             end
            end
            vm_path_name
          end

          def get_vm_name(id)
            vm_name = nil
            esxi_host.communicate.execute("vim-cmd vmsvc/get.summary #{id}") do |type, data|
             if [:stderr, :stdout].include?(type)
               vm_name_match = data.match(/name\s+=\s+"(.*)"/)
               vm_name = vm_name_match.captures[0].strip if vm_name_match
             end
            end
            vm_name
          end

          def run_script(script, ui)
            upload_path = "/tmp/vagrant-shell"
            command = "chmod +x #{upload_path} && #{upload_path}"

            with_script_file(script) do |path|
              # Upload the script to the esxi_host
              esxi_host.communicate.tap do |comm|

                comm.upload(path.to_s, upload_path)

                ui.info("executing commands over ssh on esxi host...")

                # Execute it with sudo
                comm.execute(command, sudo: false) do |type, data|
                  pp type
                  pp data
                  if [:stderr, :stdout].include?(type)
                    # Output the data with the proper color based on the stream.
                    color = type == :stdout ? :green : :red

                    options = {
                      new_line: false,
                      prefix: false,
                    }
                    options[:color] = color

                    ui.info(data, options)
                  end
                end
              end
            end
          end

          protected

          def with_script_file(script)
            file = Tempfile.new('vagrant-shell')
            file.binmode

            begin
              file.write(script)
              file.fsync
              file.close
              yield file.path
            ensure
              file.close
              file.unlink
            end
          end
        end
      end
    end
  end
end