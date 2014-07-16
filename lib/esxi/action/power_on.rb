module VagrantPlugins
  module ESXi
    module Action
      class PowerOn

        def initialize(app, env)
          @app = app
        end

        def call(env)

          config = env[:machine].provider_config

          env[:ui].info I18n.t("vagrant_esxi.powering_on")
          ssh_util = VagrantPlugins::ESXi::Util::SSH
          vm_path_name = ssh_util.get_vm_path(env[:machine].id)
          ssh_util.esxi_host.communicate.execute("vim-cmd vmsvc/power.on '#{vm_path_name}'")

          # wait for SSH to be available 
          env[:ui].info(I18n.t("vagrant_esxi.waiting_for_ssh"))
          while true
            break if env[:interrupted]                       
            break if env[:machine].communicate.ready?
            sleep 5
          end  
          
          @app.call env
        end
      end
    end
  end
end
