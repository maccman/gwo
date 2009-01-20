module GWO
  module Helper
    def gwo_start(id)
      javascript_tag(%{
        function utmx_section(){}function utmx(){}
        (function(){var k='#{id}',d=document,l=d.location,c=d.cookie;function f(n){
        if(c){var i=c.indexOf(n+'=');if(i>-1){var j=c.indexOf(';',i);return c.substring(i+n.
        length+1,j<0?c.length:j)}}}var x=f('__utmx'),xx=f('__utmxx'),h=l.hash;
        d.write('<sc'+'ript src="'+
        'http'+(l.protocol=='https:'?'s://ssl':'://www')+'.google-analytics.com'
        +'/siteopt.js?v=1&utmxkey='+k+'&utmx='+(x?x:'')+'&utmxx='+(xx?xx:'')+'&utmxtime='
        +new Date().valueOf()+(h?'&utmxhash='+escape(h.substr(1)):'')+
        '" type="text/javascript" charset="utf-8"></sc'+'ript>')})();
      })
    end
    
    def gwo_end(uacct, id)
      javascript_tag(%{
        if(typeof(urchinTracker)!='function')document.write('<sc'+'ript src="'+
        'http'+(document.location.protocol=='https:'?'s://ssl':'://www')+
        '.google-analytics.com/urchin.js'+'"></sc'+'ript>')
        </script>
        <script>
        try {
        _uacct = #{uacct.inspect};
        urchinTracker("/#{id}/test");
        } catch (err) { }
      })
    end
    
    def gwo_conversion(uacct, id)
      javascript_tag(%{
        if(typeof(urchinTracker)!='function')document.write('<sc'+'ript src="'+
        'http'+(document.location.protocol=='https:'?'s://ssl':'://www')+
        '.google-analytics.com/urchin.js'+'"></sc'+'ript>')
        </script>
        <script>
        try {
        _uacct = #{uacct.inspect};
        urchinTracker("/#{id}/goal");
        } catch (err) { }
      })
    end
    
    def gwo_static_section(name, &block)
      concat(script(name) { capture(&block) })
    end
    
    def gwo_section(name, html_options = {}, &block)
      concat(
        content_tag(:div, 
          capture(&block), 
          html_options.merge({
            :id    => "gwo_#{name.to_s}",
            :style => "display:none"
          })
        )
      )
    end
    
    def gwo_dynamic_end(default, uacct, id)
      javascript_tag(%{
        function GWO(name){
          document.getElementById("gwo_" + name).style.display = 'block';
        }
      }) + 
      script(default) { 
        javascript_tag("GWO(#{default.to_s.inspect})")
      } + 
      gwo_end(uacct, id)
    end
    
    def gwo(default, uacct, id)
      gwo_start(id) + gwo_dynamic_end(default, uacct, id)
    end
    
    private
    
      # I'm overriding this since GWO doesn't like the CDATA section for some reason...
      def javascript_tag(content_or_options_with_block = nil, html_options = {}, &block)
        content =
          if block_given?
            html_options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
            capture(&block)
          else
            content_or_options_with_block
          end
        tag = content_tag(:script, content, html_options.merge(:type => Mime::JS))
        if block_called_from_erb?(block)
          concat(tag)
        else
          tag
        end
      end
    
      def script(name, &block)
        javascript_tag("utmx_section(#{name.to_s.inspect})") + yield + "</noscript>"
      end
  end
end
