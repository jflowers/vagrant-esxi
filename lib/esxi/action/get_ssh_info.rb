require "open3"
require 'esxi/util/ssh'

module VagrantPlugins
  module ESXi
    module Action
      class GetSshInfo

        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:machine_ssh_info] = get_ssh_info(env[:esxi_connection], env[:machine])

          @app.call env
        end

        private

        def get_ssh_info(connection, machine)
          config = machine.provider_config

          ssh_util = VagrantPlugins::ESXi::Util::SSH
          vm_path_name = ssh_util.get_vm_path(machine.id)
          ip_addess = nil
          ssh_util.esxi_host.communicate.execute("vim-cmd vmsvc/get.guest '#{vm_path_name}'") do |type, data|
           if [:stderr, :stdout].include?(type)
             ip_addess_match = data.match(/^\s+ipAddress\s+=\s+"(.*?)"/m)
             ip_addess = ip_addess_match.captures[0].strip if ip_addess_match
           end
          end

          return nil if ip_addess.nil?

          return {
              :host => ip_addess,
              :port => 22
          }
        end
      end
    end
  end
end
