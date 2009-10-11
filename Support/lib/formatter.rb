class Formatter
  
  DESCRIBE_PATTERN = /^\w[\w\d_]+:\s*\{/
  RESULT_DUMP_PATTERN = /^\(.*\)$/
  LOW_MEMORY_PATTERN = /low memory handler called/
  SUCCESS_PATTERN = /Success!!/
  OUTPUT_EXISTS_PATTERN = /already exists/
  DETAILS_IN_LOG_PATTERN = /Details at logfile/
  
  def initialize
    @headers_sent   = false
    @in_result_dump = false
  end
  
  def format_line(line, type)
    output = ""
    
    unless @headers_sent
      output << header
      
      @headers_sent = true
    end
    
    if line =~ RESULT_DUMP_PATTERN && ! @in_result_dump
      output << "<h1>Dump</h1><table>"
      @in_result_dump = true
    elsif line !~ RESULT_DUMP_PATTERN && @in_result_dump
      output << "</table>"
      @in_result_dump = false
    end
    
    output << format_line_switch(line, type)
    
    if line !~ LOW_MEMORY_PATTERN
      output << hide_low_memory_warning
    end
    
    output
  end
  
private

  def format_line_switch(line, type)
    case line
    when DESCRIBE_PATTERN
      format_describe(line)
    when RESULT_DUMP_PATTERN
      format_result_dump(line)
    when LOW_MEMORY_PATTERN
      format_low_memory_warning(line)
    when /Successfully stored result/
      format_result_stored(line)
    when /Records written/
      format_records_written(line)
    when /Bytes written/
      format_bytes_written(line)
    when /\d+% complete/
      format_percent_complete(line)
    when SUCCESS_PATTERN
      hide_percent_complete
    when OUTPUT_EXISTS_PATTERN
      format_output_exists(line)
    when DETAILS_IN_LOG_PATTERN
      format_details_in_log(line)
    else
      if type == :err
        format_error(line)
      else
        format_other(line)
      end
    end
  end
  
  def header
    <<-HTML
      <style type="text/css">
      #{File.read(File.dirname(__FILE__) + '/../resources/styles.css')}
      </style>
      <script type="text/javascript">
      function lowMemoryWarningNode( ) {
        return document.getElementById("low-memory-warning");
      }
      function percentCompleteNode( ) {
        return document.getElementById("percent-complete");
      }
      function updateLowMemoryWarning(percentUsed, maxMem) {
        lowMemoryWarningNode().innerHTML = "Low memory: using " + percentUsed + "% of " + maxMem + " Mb";
        lowMemoryWarningNode().style.display = "block";
      }
      function updatePercentComplete(percentComplete) {
        percentCompleteNode().innerHTML = percentComplete + "% complete";
        percentCompleteNode().style.display = "block";
      }
      function hideLowMemoryWarning( ) {
        lowMemoryWarningNode().style.display = "none";
      }
      function hidePercentComplete( ) {
        percentCompleteNode().style.display = "none";
      }
      </script>
      <div id="messages">
        <div id="low-memory-warning" class="message">
          Low memory warning
        </div>
        <div id="percent-complete" class="message">
          Percent complete
        </div>
      </div>
    HTML
  end
  
  def hide_low_memory_warning
    "<script>hideLowMemoryWarning()</script>"
  end
  
  def hide_percent_complete
    "<script>hidePercentComplete()</script>"
  end
  
  def format_other(line)
    "<div class=\"other\">#{htmlize(line)}</div>"
  end

  def format_error(str)
    "<div class=\"err\">#{htmlize(str)}</div>"
  end
  
  def format_low_memory_warning(str)
    # 2009-09-29 14:26:02,410 [Low Memory Detector] INFO  org.apache.pig.impl.util.SpillableMemoryManager - low memory handler called (Usage threshold exceeded) init = 65404928(63872K) used = 797528352(778836K) committed = 798785536(780064K) max = 1004994560(981440K)
    
    _, init, used, committed, max = *str.match(/init\s*=\s*(\d+)\(\d+K\)\s+used\s*=\s*(\d+)\(\d+K\)\s+committed\s*=\s*(\d+)\(\d+K\)\s+max\s*=\s*(\d+)\(\d+K\)/)
    
    percentage_used = (used.to_f/max.to_f * 100 + 0.5).to_i
    max_mem = max.to_i/(1024 * 1024)
    
    "<script>updateLowMemoryWarning(#{percentage_used}, #{max_mem})</script>"
  end

  def format_result_stored(str)
    # INFO org.apache.pig.backend.local.executionengine.LocalPigLauncher - Successfully stored result in: "file:/tmp/temp647037006/tmp-82310346" 2009-09-29 11:56:57,182 [main]
  
    if str.match(/(Successfully stored result in): "(\w+):([^"]+)"/)
      "<div class=\"success\">#{$1}: <a href=\"txmt://open/?url=#{$2}:#{$3}\">#{$3}</a></div>"
    else
      "<div class=\"success\">Successfully stored result</div>"
    end
  end
  
  def format_output_exists(str)
    # 2009-09-29 15:53:06,661 [main] ERROR org.apache.pig.tools.grunt.Grunt - ERROR 4000: The output file(s): file:/Users/theo/Documents/Burt/Code/rich_pig/data already exists
    
    _, scheme, url = *str.match(/^.*The output file\(s\): (\w+):(.*?) already exists.*$/)
    
    if File.exists?(url)
      display_url = url
    else
      display_url = scheme + ':' + url
    end
    
    if File.exist?(url) && ! File.directory?(url)
      "<div class=\"err\"><a href=\"txmt://open/?url=#{scheme}:#{url}\">#{display_url}</a> already exists</div>"
    else
      "<div class=\"err\">#{display_url} already exists</div>"
    end
  end
  
  def format_details_in_log(str)
    # Details at logfile: /Users/theo/Documents/Burt/Code/rich_pig/pig_1254232762607.log
    
    path = str.sub(/^.*Details at logfile: (.+)\s*$/, '\1')
    
    random_id = "details#{rand(1000)}"
    
    <<-HTML
      <div id="#{random_id}" style="display:none">
        <pre>#{File.readlines(path)[1..-1].join('')}</pre>
      </div>
      <div id="reveal-#{random_id}">
        <a href="#" onclick="document.getElementById('#{random_id}').style.display = 'block'; document.getElementById('reveal-#{random_id}').style.display = 'none';">More details</a>
      </div>
    HTML
  end

  def format_success(str)
    # org.apache.pig.backend.local.executionengine.LocalPigLauncher - Success!!
  
    "<div class=\"success\">Success!</div>"
  end
  
  def format_records_written(str)
    # 2009-09-29 14:26:08,489 [main] INFO  org.apache.pig.backend.local.executionengine.LocalPigLauncher - Records written : 7
    
    num_records = str.sub(/^.*Records written\s*:\s*(\d+).*$/, '\1')
    
    "<div>#{num_records} records written</div>"
  end
  
  def format_bytes_written(str)
    # 2009-09-29 14:26:08,490 [main] INFO  org.apache.pig.backend.local.executionengine.LocalPigLauncher - Bytes written : 0

    num_bytes = str.sub(/^.*Bytes written\s*:\s*(\d+).*$/, '\1')
    
    "<div>#{num_bytes} bytes written</div>"
  end
  
  def format_percent_complete(str)
    # 2009-09-29 14:26:08,491 [main] INFO  org.apache.pig.backend.local.executionengine.LocalPigLauncher - 100% complete!
    
    percent = str.sub(/^.*?(\d+)% complete.*$/, '\1')
    
    "<script>updatePercentComplete(#{percent})</script>"
  end

  def format_describe(str)
    _, relation_name, fields = *str.match(/^(\w[\w\d_]+):\s*\{(.*)\}$/)

    field_list = ""

    fields.scan(/(\w[\w\d_]+):\s*(\w+),?/) do |name, type|
      field_list += "<dt>#{name}</dt><dd>#{type}</dd>"
    end
  
    "<div class=\"out\"><h1 class=\"relation-name\">#{relation_name}</h1><dl class=\"relation-fields\">#{field_list}</dl></div>"
  end
  
  def format_result_dump(str)
    # (2009-08-04,0a2fcc90281ae6caa138f5a8edc94d77,cpbeurope_ri,ClearBlue Agglossningskalender 980x120,81088L,73541L,2617L,0L,4764283L,4320601L,367864L)
    
    values = str.gsub(/^\((.*)\)$/, '\1').split(',')
    
    cells = values.map do |value|
      formatted_value = format_value(value)
      
      if formatted_value.kind_of? Numeric
        "<td class=\"numeric\">#{formatted_value}</td>"
      else
        "<td>#{htmlize(formatted_value)}</td>"
      end
    end
    
    "<tr>#{cells}</tr>"
  end
  
  def format_value(str)
    case str
    when /^\d+L$/
      str[0..-2].to_i
    else
      str
    end
  end
  
end