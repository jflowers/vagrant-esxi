require "open3"

module VagrantPlugins
  module ESXi
    module Action
      class GetState

        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:machine_state_id] = get_state(env[:esxi_connection], env[:machine])

          @app.call env
        end

        private

        def get_state(connection, machine)
          return :not_created  if machine.id.nil?

          config = machine.provider_config

          ssh_util = VagrantPlugins::ESXi::Util::SSH
          
          vm_path_name = ssh_util.get_vm_path(machine.id)

          return :not_created if vm_path_name.nil?

          running = ssh_util.esxi_host.communicate.execute("vim-cmd vmsvc/power.getstate '#{vm_path_name}' | grep -q 'Powered on'")

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
