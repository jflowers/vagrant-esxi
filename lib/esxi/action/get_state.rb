require "open3"
require 'esxi/util/ssh'

module VagrantPlugins
  module ESXi
    module Action
      class GetState

        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:machine_state_id] = get_state(env[:machine])

          @app.call env
        end

        private

        def get_state(machine)
          return :not_created  if machine.id.nil?

          ssh_util = VagrantPlugins::ESXi::Util::SSH
          
          vm_path_name = ssh_util.get_vm_path(machine.id)

          return :not_created if vm_path_name.nil?

          running = false
          ssh_util.esxi_host.communicate.execute("vim-cmd vmsvc/power.getstate '#{vm_path_name}'") do |type, data|
           if [:stderr, :stdout].include?(type)
             ip_addess_match = data.match(/Powered on/)
             ip_addess = true if ip_addess_match
           end
          end

          if running
            :running
          else
            :poweroff
          end
        end
      end
    end
  end
end
