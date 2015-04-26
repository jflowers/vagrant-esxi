require 'esxi/util/ssh'

module VagrantPlugins
  module ESXi
    module Action
      class PowerOff

        def initialize(app, env)
          @app = app
        end

        def call(env)
          config = env[:machine].provider_config

          env[:ui].info I18n.t("vagrant_esxi.powering_off")

          ssh_util = VagrantPlugins::ESXi::Util::SSH
          vm_path_name = ssh_util.get_vm_path(env[:machine].id)
          ssh_util.esxi_host.communicate.execute("vim-cmd vmsvc/power.off '#{vm_path_name}'")

          @app.call env
        end
      end
    end
  end
end
