module Differ
  class DiffService
    def initialize(fpath1, fpath2)
      @fpath1 = fpath1
      @fpath2 = fpath2
      @result = []
    end

    def call
      @f1_lines   = File.read(@fpath1).split("\n")
      @f2_lines   = File.read(@fpath2).split("\n")
      f2_cur = 0

      @matched_lines = []

      @f1_lines.each_with_index do |f1_line, i1|
        @f2_lines[f2_cur..-1].each_with_index do |f2_line, i2|
          if f1_line == f2_line
            @matched_lines << {sign: " ", line: f1_line, f1_id: i1, f2_id: i2 + f2_cur}
            f2_cur += 1

            break
          end
        end
      end

      process_start_range

      if @matched_lines
        last_result = @result.last

        @matched_lines.each_with_index do |mline, i|
          if i + 1 != @matched_lines.length
            next_line = @matched_lines[i + 1]

            if next_line && (mline[:f1_id] - next_line[:f1_id] > 1) && (mline[:f2_id] - next_line[:f2_id] > 1) 
              process_range mline[:f1_id] + 1, mline[:f2_id] + 1, next_line[:f1_id], next_line[:f2_id]
            end
          end
          @result << mline
        end

        process_end_range
      end

      number_column_len = @result.length.to_s.length
      sign_column_len   = 2
      line_column_len   = @result.sort_by { |l| l[:line].length  }.first[:line].length

      @result.map.with_index do |line, i|
        n = i + 1
        number = "#{" " * (number_column_len - n.to_s.length)}#{n}"
        sign   = " #{line[:sign]} "

        "#{number}#{sign}#{line[:line]}"
      end.join("\n") << "\n"
    end

    def process_start_range
      f1_line_id = 0
      f2_line_id = 0

      if mline = @matched_lines.first
        max_f1_line_id = mline[:f1_id] - 1
        max_f2_line_id = mline[:f2_id] - 1
      else
        max_f1_line_id = @f1_lines.length - 1
        max_f2_line_id = @f2_lines.length - 1
      end

      return if f1_line_id >= max_f1_line_id && f2_line_id >= max_f2_line_id

      process_range f1_line_id, f2_line_id, max_f1_line_id, max_f2_line_id
    end

    def process_end_range
      mline = @matched_lines.last
      f1_line_id = mline[:f1_id] + 1
      f2_line_id = mline[:f2_id] + 1

      max_f1_line_id = @f1_lines.length - 1
      max_f2_line_id = @f2_lines.length - 1

      return if f1_line_id >= max_f1_line_id && f2_line_id >= max_f2_line_id

      process_range f1_line_id, f2_line_id, max_f1_line_id, max_f2_line_id
    end

    def process_range(f1_line_id, f2_line_id, max_f1_line_id, max_f2_line_id)
      f1_changes_range = (f1_line_id ... max_f1_line_id - (max_f2_line_id - f2_line_id))

      @f1_lines[f1_changes_range].each_with_index do |line, id|
        @result << {sign: "*", line: "#{line}|#{@f2_lines[f2_line_id .. max_f2_line_id][id]}"}
      end

      if (max_f1_line_id - f1_line_id) > (max_f2_line_id - f2_line_id)
        f1_removements_range = ((max_f1_line_id - (max_f2_line_id - f2_line_id)) .. max_f1_line_id)

        @f1_lines[f1_removements_range].each do |line|
          @result << {sign: "-", line: line}
        end
      else
        f2_additions_range = ((max_f2_line_id - (max_f1_line_id - f1_line_id) - f2_line_id) .. max_f2_line_id)
        
        @f2_lines[f2_additions_range].each do |line|
          @result << {sign: "+", line: line}
        end
      end
    end
  end
end
