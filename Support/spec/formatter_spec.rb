require File.dirname(__FILE__) + '/spec_helper'


describe Formatter do
    
  before do
    @formatter = Formatter.new
  end
  
  it 'includes a style block in the header' do
    @formatter.header.should include('<style type="text/css">')
    @formatter.header.should include('</style>')
  end
  
  it 'includes a script block in the header' do
    @formatter.header.should include('<script type="text/javascript">')
    @formatter.header.should include('</script>')
  end
        
  it 'formats a generic error correctly' do
    formatted_str = @formatter.format_line('Hello world', :err)
    formatted_str.should eql('<div class="err">Hello world</div>')
  end
  
  it 'formats a low memory warning correctly' do
    str = '2009-09-29 11:56:45,633 [Low Memory Detector] INFO org.apache.pig.impl.util.SpillableMemoryManager - low memory handler called (Usage threshold exceeded) init = 65404928(63872K) used = 851000800(831055K) committed = 853463040(833460K) max = 1004994560(981440K)'
    
    formatted_str = @formatter.format_line(str, :err)
    formatted_str.should include('<script>updateLowMemory(85, 958)</script>')
  end
  
  it 'formats a "result stored" status message with a file path correctly' do
    str = 'INFO org.apache.pig.backend.local.executionengine.LocalPigLauncher - Successfully stored result in: "file:/tmp/temp647037006/tmp-82310346" 2009-09-29 11:56:57,182 [main]'

    formatted_str = @formatter.format_line(str, :err)
    formatted_str.should include('<div class="success">Successfully stored result in: <a href="txmt://open/?url=file:/tmp/temp647037006/tmp-82310346">/tmp/temp647037006/tmp-82310346</a></div>')
  end
  
  it 'formats a "success" status message correctly' do
    str = 'org.apache.pig.backend.local.executionengine.LocalPigLauncher - Success!!'
    
    formatted_str = @formatter.format_line(str, :err)
    formatted_str.should include('<div class="success">Success!</div>')
  end
  
  it 'formats a relation description correctly' do
    str = "metrics_by_name: {date: chararray,ad_id: chararray,api_key: chararray,name: chararray,exposures: long,impressions: long,engagements: long,click_thrus: long,session_time: long,visible_time: long,engagement_time: long}"
  
    formatted_str = @formatter.format_line(str, :out)
    formatted_str.should include('<h1 class="relation-name">metrics_by_name</h1>')
    formatted_str.should include('<dt>date</dt><dd>chararray</dd>')
    formatted_str.should include('<dt>ad_id</dt><dd>chararray</dd>')
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
    formatted_str.should eql('<div>7 records written</div>')
  end
  
  it 'formats a "bytes written" status message correctly' do
    str = '2009-09-29 14:26:08,490 [main] INFO  org.apache.pig.backend.local.executionengine.LocalPigLauncher - Bytes written : 0'
    
    formatted_str = @formatter.format_line(str, :out)
    formatted_str.should eql('<div>0 bytes written</div>')
  end
  
  it 'formats a complete percentage status message correctly' do
    str = '2009-09-29 14:26:08,491 [main] INFO  org.apache.pig.backend.local.executionengine.LocalPigLauncher - 100% complete!'
    
    formatted_str = @formatter.format_line(str, :out)
    formatted_str.should eql('<div>100% complete</div>')
  end
  
end