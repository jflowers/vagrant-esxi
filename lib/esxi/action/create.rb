require "i18n"
require "open3"
require "vagrant/util/subprocess"

module VagrantPlugins
  module ESXi
    module Action
      class Create

        def initialize(app, env)
          @app = app
          require_relative('../util/ssh.rb')
        end

        def call(env)
          config = env[:machine].provider_config

          box = env[:machine].box
          box = env[:global_config].box if box.nil?
          vmx_file = Dir.glob(box.directory.join('*.vmx')).sort!.fetch(0)

          box_name = env[:machine].config.vm.box
          unique_machine_name = "#{env[:machine].name}-#{SecureRandom.uuid}"

          unless system("ssh -i #{config.ssh_key_path} #{config.user}@#{config.host} test -e /vmfs/volumes/#{config.datastore}/#{box_name}")
            env[:ui].info(I18n.t("vagrant_esxi.copying"))

            esxi_import_command = [
              "/Applications/VMware Fusion.app/Contents/Library/VMware OVF Tool/ovftool",
              "--diskMode=sparse",
              "--name=#{box_name}",
              "--net:'External=VM Network'",
              "--noSSLVerify",
              "--overwrite",
              "--privateKey=#{config.ssh_key_path}",
              vmx_file,
              "vi://#{config.user}:#{config.password}@#{config.host}"
            ]

            esxi_import = Vagrant::Util::Subprocess.execute(*esxi_import_command)
            
            if esxi_import.exit_code != 0
              raise esxi_import.stderr
            end
          end

          env[:ui].info(I18n.t("vagrant_esxi.creating"))
          raise "#{unique_machine_name} exists!" if system("ssh -i #{config.ssh_key_path} #{config.user}@#{config.host} test -e /vmfs/volumes/#{config.datastore}/#{unique_machine_name}")

          ssh_util = VagrantPlugins::ESXi::Util::SSH

          script = <<-EOS
            mkdir -p /vmfs/volumes/#{config.datastore}/#{unique_machine_name}
            find /vmfs/volumes/#{config.datastore}/#{box_name} -type f \\! -name \\*.iso -exec cp \\{\\} /vmfs/volumes/#{config.datastore}/#{unique_machine_name}/ \\;
            cd /vmfs/volumes/#{config.datastore}/#{unique_machine_name}
            find /vmfs/volumes/#{config.datastore}/#{box_name} -type f -name \\*.iso -exec ln -s \\{\\} \\;
            mv /vmfs/volumes/#{config.datastore}/#{unique_machine_name}/#{box_name}.vmx /vmfs/volumes/#{config.datastore}/#{unique_machine_name}/#{box_name}.vmx.bak
            grep -v -e '^uuid.location' -e '^uuid.bios' -e '^vc.uuid' /vmfs/volumes/#{config.datastore}/#{unique_machine_name}/#{box_name}.vmx.bak > /vmfs/volumes/#{config.datastore}/#{unique_machine_name}/#{box_name}.vmx
            rm /vmfs/volumes/#{config.datastore}/#{unique_machine_name}/#{box_name}.vmx.bak
            chmod +x /vmfs/volumes/#{config.datastore}/#{unique_machine_name}/#{box_name}.vmx
          EOS

          ssh_util.run_script(script, env[:ui])

          env[:ui].info(I18n.t("vagrant_esxi.registering"))
          id = nil
          ssh_util.esxi_host.communicate.execute("vim-cmd solo/registervm '/vmfs/volumes/#{config.datastore}/#{unique_machine_name}/#{box_name}.vmx' #{unique_machine_name}") do |type, data|
           if [:stderr, :stdout].include?(type)
             id = data.chomp
           end
          end

          env[:machine].id = id
            
          @app.call env
        end
      end
    end
  end
end
