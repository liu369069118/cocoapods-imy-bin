require 'yaml'
require 'cocoapods-imy-bin/config/config'

module CBin
  class Build

    class Utils

      def Utils.is_framework(spec)
        if Utils.uses_frameworks?
          return true
        end

        return Utils.is_swift_module(spec)
      end

      def Utils.spec_header_dir(spec)
        spec_header_dir = "./Headers/Public/#{spec.name}"

        unless File.exist?(spec_header_dir)
          spec_header_dir = "./Pods/Headers/Public/#{spec.name}"
        end

        unless File.exist?(spec_header_dir)
          # 一些库名称中使用了中划线如AAA-BBB，public header中库名称会默认处理成下划线AAA_BBB
          module_name = spec.name.gsub("-", "_")
          spec_header_dir = "./Pods/Headers/Public/#{module_name}"
        end

        spec_header_dir
      end

      def Utils.is_swift_module(spec)

        is_framework = false
        dir = File.join(CBin::Config::Builder.instance.gen_dir, CBin::Config::Builder.instance.target_name)
        #auto 走这里
        if File.exist?(dir)
          Dir.chdir(dir) do
            spec_header_dir = Utils.spec_header_dir(spec)
            return false unless File.exist?(spec_header_dir)

            is_framework = File.exist?(File.join(spec_header_dir, "#{spec.name}-umbrella.h"))
          end
        end

        if $ARGV[1] == "local"
          is_framework = File.exist?(File.join(CBin::Config::Builder.instance.xcode_build_dir, "#{spec.name}.framework"))
          unless is_framework
            is_framework = File.exist?(File.join(CBin::Config::Builder.instance.xcode_BuildProductsPath_dir, "#{spec.name}","Swift Compatibility Header"))
          end
        end

        is_framework
      end

      def Utils.uses_frameworks?
        uses_frameworks = false
        Pod::Config.instance.podfile.target_definitions.each do |key,value|
          if key != "Pods"
            uses_frameworks = value.uses_frameworks?
            if uses_frameworks
              break ;
            end
          end
        end

        return uses_frameworks
      end

    end

  end
end
