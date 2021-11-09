require "yaml"
require 'zlib'
require_relative "./WebRequest"

module Github

    CRC_PATH = File.join(File.dirname(__FILE__), "..", 'crc.bin')
    META_PATH = File.join(File.dirname(__FILE__), "..", 'meta.bin')

    class Metadata
        attr_accessor :actions

        def initialize
            @meta = WebRequest.get('https://api.github.com/meta')
            @actions = @meta["actions"] || [""]
            @cache_actions = []
            deserialize
        end

        def serialize
            File.open(Github::META_PATH, "w+") do |f|
                tmp = Marshal.dump(@actions)
                f.puts tmp
            end
        end

        def deserialize
            return if not File.exist?(Github::META_PATH)
            File.open(Github::META_PATH, "r") do |f|
                tmp = Marshal.load(f)
                @cache_actions = tmp
            end        
            if @cache_actions.eql?(@actions)
                puts "정확히 같습니다."
            end    
        end

        # crc를 만듭니다.
        def create_crc
            crc = Zlib::crc32(@actions.to_s)
            crc_raw = crc.to_s(16)

            # CRC 덤프
            data = {"crc" => crc_raw}
            yaml_dump_bin = YAML.dump(data)

            # CRC 덤프를 루프 경로에 저장
            f = File.open(Github::CRC_PATH, "w+")
            f.puts yaml_dump_bin
            f.close
        end

        def check_crc(callback={:success => Proc.new, :fail => Proc.new, :different => Proc.new})
            is_existed = File.exist?(Github::CRC_PATH)

            # 파일이 존재한다면 CRC를 비교한다.
            if is_existed

                crc_raw = File.read(Github::CRC_PATH)

                # 이전 CRC 값
                prev_crc = YAML.load(crc_raw)["crc"] rescue ""

                # 새로운 CRC 값
                crc = Zlib::crc32(@actions.to_s)
                crc_raw_check = crc.to_s(16)

                if prev_crc == crc_raw_check
                    # 콜백 블럭을 호출한다.
                    callback[:success].call(crc_raw_check)
                else
                    puts "crc is different"
                    callback[:different].call
                end                
            else 
                create_crc
                serialize
                callback[:failed].call
            end

        end
    end
end
