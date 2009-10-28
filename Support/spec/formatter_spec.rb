require File.dirname(__FILE__) + '/spec_helper'


describe Formatter do
    
  before do
    @formatter = Formatter.new
  end
  
  it 'includes a style block in the header' do
    formatted_str = @formatter.format_line('', :out)
    formatted_str.should include('<style type="text/css">')
    formatted_str.should include('</style>')
  end
  
  it 'includes a script block in the header' do
    formatted_str = @formatter.format_line('', :out)
    formatted_str.should include('<script type="text/javascript">')
    formatted_str.should include('</script>')
  end
        
  it 'formats a generic error correctly' do
    formatted_str = @formatter.format_line('Hello world', :err)
    formatted_str.should include('<div class="err">Hello world</div>')
  end
  
  it 'formats a low memory warning correctly' do
    str = '2009-09-29 11:56:45,633 [Low Memory Detector] INFO org.apache.pig.impl.util.SpillableMemoryManager - low memory handler called (Usage threshold exceeded) init = 65404928(63872K) used = 851000800(831055K) committed = 853463040(833460K) max = 1004994560(981440K)'
    
    formatted_str = @formatter.format_line(str, :err)
    formatted_str.should include('<script>updateLowMemoryWarning(85, 958)</script>')
  end
  
  it 'formats a "result stored" status message with a file path correctly' do
    str = 'INFO org.apache.pig.backend.local.executionengine.LocalPigLauncher - Successfully stored result in: "file:/tmp/temp647037006/tmp-82310346" 2009-09-29 11:56:57,182 [main]'

    formatted_str = @formatter.format_line(str, :err)
    formatted_str.should include('<div class="success">Successfully stored result in: <a href="txmt://open/?url=file:/tmp/temp647037006/tmp-82310346">/tmp/temp647037006/tmp-82310346</a></div>')
  end
  
  it 'hides the percent complete display on success' do
    str = 'org.apache.pig.backend.local.executionengine.LocalPigLauncher - Success!!'
    
    formatted_str = @formatter.format_line(str, :err)
    formatted_str.should include('<script>hidePercentComplete()</script>')
  end
  
  it 'formats a relation description correctly' do
    str = "metrics_by_name: {date: chararray,ad_id: chararray,api_key: chararray,name: chararray,exposures: long,impressions: long,engagements: long,click_thrus: long,session_time: long,visible_time: long,engagement_time: long}"
  
    formatted_str = @formatter.format_line(str, :out)
    formatted_str.should include('<h1 class="relation-name">metrics_by_name</h1>')
    formatted_str.should include('<dt>date</dt><dd>chararray</dd>')
    formatted_str.should include('<dt>ad_id</dt><dd>chararray</dd>')
  end
  
  it 'formats a hierarchical relation correctly' do
    str = 'grouped_by_keys: {group: (date: chararray,ad_id: chararray,api_key: chararray,category: chararray,segment: chararray),report_metrics: {date: chararray,ad_id: chararray,api_key: chararray,category: chararray,segment: chararray,exposures: int,impressions: int,engagements: int,click_thrus: int,indeterminate_visibility: int,session_time: int,visible_time: int,engagement_time: int}}'
    
    formatted_str = @formatter.format_line(str, :out)
    formatted_str.should include('<h1 class="relation-name">grouped_by_keys</h1>')
    formatted_str.should include('<h2 class="sub-relation-name">group</h2>')
    formatted_str.should include('<h2 class="sub-relation-name">report_metrics</h2>')
    formatted_str.should include('<dt>date</dt><dd>chararray</dd>')
    formatted_str.should include('<dt>ad_id</dt><dd>chararray</dd>')
    formatted_str.should include('<dt>exposures</dt><dd>int</dd>')
    formatted_str.should include('<dt>session_time</dt><dd>int</dd>')
  end
  
  it 'formats a result dump row as a table row' do
    str = '(2009-08-04,0a2fcc90281ae6caa138f5a8edc94d77,cpbeurope_ri,ClearBlue Agglossningskalender 980x120,81088L,73541L,2617L,0L,4764283L,4320601L,367864L)'
    
    formatted_str = @formatter.format_line(str, :out)
    formatted_str.should include('<tr>')
    formatted_str.should include('</tr>')
    formatted_str.should include('<td>2009-08-04</td>')
    formatted_str.should include('<td>0a2fcc90281ae6caa138f5a8edc94d77</td>')
    formatted_str.should include('<td>cpbeurope_ri</td>')
    formatted_str.should include('<td>ClearBlue Agglossningskalender 980x120</td>')
    formatted_str.should include('<td class="numeric">81088</td>')
    formatted_str.should include('<td class="numeric">73541</td>')
    formatted_str.should include('<td class="numeric">2617</td>')
    formatted_str.should include('<td class="numeric">0</td>')
    formatted_str.should include('<td class="numeric">4764283</td>')
    formatted_str.should include('<td class="numeric">4320601</td>')
    formatted_str.should include('<td class="numeric">367864</td>')
    formatted_str.should include('</tr>')
  end
  
  it 'formats a "records written" status message correctly' do
    str = '2009-09-29 14:26:08,489 [main] INFO  org.apache.pig.backend.local.executionengine.LocalPigLauncher - Records written : 7'
    
    formatted_str = @formatter.format_line(str, :out)
    formatted_str.should include('<div>7 records written</div>')
  end
  
  it 'formats a "bytes written" status message correctly' do
    str = '2009-09-29 14:26:08,490 [main] INFO  org.apache.pig.backend.local.executionengine.LocalPigLauncher - Bytes written : 0'
    
    formatted_str = @formatter.format_line(str, :out)
    formatted_str.should include('<div>0 bytes written</div>')
  end
  
  it 'updates the percent complete display on a percent complete status message' do
    str = '2009-09-29 14:26:08,491 [main] INFO  org.apache.pig.backend.local.executionengine.LocalPigLauncher - 100% complete!'
    
    formatted_str = @formatter.format_line(str, :out)
    formatted_str.should include('<script>updatePercentComplete(100)</script>')
  end
  
end