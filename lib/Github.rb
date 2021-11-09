require "yaml"
require 'zlib'
require_relative "./WebRequest"

module Github
    class Metadata
        attr_accessor :actions

        def initialize
            @meta = WebRequest.get('https://api.github.com/meta')
            @actions = @meta["actions"] || [""]
            
        end

        # crc를 만듭니다.
        def create_crc
            crc = Zlib::crc32(@actions.to_s)
            crc_raw = crc.to_s(16)

            # CRC 덤프
            data = {"crc" => crc_raw}
            yaml_dump_bin = YAML.dump(data)

            # CRC 덤프의 경로
            crc_file_path = File.join(File.dirname(__FILE__), "..", 'crc.bin')

            # CRC 덤프를 루프 경로에 저장
            f = File.open(crc_file_path, "w+")
            f.puts yaml_dump_bin
            f.close
        end

        def check_crc(callback={:success => Proc.new, :fail => Proc.new})
            crc_file_path = File.join(File.dirname(__FILE__), "..", 'crc.bin')
            is_existed = File.exist?(crc_file_path)

            # 파일이 존재한다면 CRC를 비교한다.
            if is_existed

                crc_raw = File.read(crc_file_path)

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
                end                
            else 
                create_crc
                callback[:failed].call
            end

        end
    end
end
