module VagrantPlugins
  module ESXi
    module Action
      class Destroy

        def initialize(app, env)
          @app = app
        end

        def call(env)
          destroy_vm env
          env[:machine].id = nil

          @app.call env
        end

        private 
        
        def destroy_vm(env)
          config = env[:machine].provider_config

          ssh_util = VagrantPlugins::ESXi::Util::SSH
          vm_path_name = ssh_util.get_vm_path(env[:machine].id)
          vm_name = ssh_util.get_vm_name(env[:machine].id)
          
          env[:ui].info I18n.t("vagrant_esxi.unregistering")
          ssh_util.esxi_host.communicate.execute("vim-cmd vmsvc/unregister '#{vm_path_name}'")
          system("ssh -i #{config.ssh_key_path} #{config.user}@#{config.host} vim-cmd vmsvc/unregister '[#{config.datastore}]\\ #{env[:machine].name}/#{env[:machine].config.vm.box}.vmx'")

          env[:ui].info I18n.t("vagrant_esxi.removing")
          ssh_util.esxi_host.communicate.execute("rm -rf /vmfs/volumes/#{config.datastore}/#{vm_name}")
        end
      end
    end
  end
end
