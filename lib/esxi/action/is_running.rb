require 'esxi/util/ssh'

module VagrantPlugins
  module ESXi
    module Action
      class IsRunning
        
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:result] = get_state(env[:machine]) == :running
          @app.call env
        end

        def get_state(machine)
          return :not_created  if machine.id.nil?

          ssh_util = VagrantPlugins::ESXi::Util::SSH
          
          vm_path_name = ssh_util.get_vm_path(machine.id)

          return :not_created if vm_path_name.nil?

          running = false
          ssh_util.esxi_host.communicate.execute("vim-cmd vmsvc/power.getstate '#{vm_path_name}'") do |type, data|
           if [:stderr, :stdout].include?(type)
             running_match = data.match(/.*Powered\s+on.*/)
             running = true if running_match
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
