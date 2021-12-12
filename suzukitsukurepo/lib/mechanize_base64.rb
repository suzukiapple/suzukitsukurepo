# coding: utf-8
# ページの外部リソースをbase64で埋め込みする

module Mechanize_base64
  class Mechanize::Page

    def embed_body
      self.embed_style
      self.embed_script
      self.embed_images
      self.search("/").to_s
    end

    def embed_script(page=nil,base_uri=nil)
      page = @mech.page unless page
      base_uri = @mech.page.uri unless base_uri
      page.search("script[src]").each{|e|
        pp e
        begin
          uri =  URI.join(base_uri, e.attr("src"))
          @mech.get uri
          e.remove
          script_text = @mech.page.body.toutf8
          head = page.search("head").first
          head.add_child("\n<script type='text/javascript'>\n\n#{script_text}\n\n</script>\n\n")
          @mech.history.pop
        rescue => e
          $stderr.puts "uri err occured. => '#{u}'" if $DEBUG 
          $stderr.puts e.backtrace if $DEBUG 
        end          
      }
    end
    def remove_script(page=nil)
      page = @mech.page unless page
      base_uri = @mech.page.uri unless base_uri
      page.search("script").each{|e| e.remove}
      page.search("a").each{|e|
        e["href"] = "#noscript" if e.attr("href") =~ /script/i
        e.attributes.keys.each{|name| e.remove_attribute(name) if name =~ /^on/i }
      }
    end
    def embed_css_url(css_text)
      page = @mech.page 
      base_uri = page.uri
      css = css_text 
      css = css.lines.map{|line|
        if  line =~ %r|url\s*\(| then 
          line =~ %r|url\(([^\)]+)\)|
          ret = $1
          ret = ret.gsub( /"|'/, "" ) if ret
          next if ret =~/^data/
          href =  URI.join(base_uri.to_s, ret.to_s)
          begin 
            page.get href
            contents = page.body.toutf8
            content_type = page.header["content-type"]
            contents = Base64.encode64(contents).gsub(/\n|\r/, "")
            line = line.gsub( ret.to_s, "data:#{content_type};base64,#{contents}" )
            @mech.history.pop
          rescue => e
            $stderr.puts "uri err occured. => '#{href}'"  if $DEBUG
            $stderr.puts e.backtrace if $DEBUG 
          end
        end
        
        line

      }
      css = css.join
      css
    end
    def embed_style_import(css,page=nil,base_uri=nil)
      page = @mech.page unless page
      base_uri = page.uri unless base_uri # import 呼び出し元のCSSのURLが必要
      css = css.lines.map{|line|
        if line=~/@import/i
            line = line.gsub( /@import/, "")
            line = line.gsub( /'|"|;/  , "")
            line = line.strip
            line = line.gsub(%r|url\(([^\)]+)\)|){ $1 }
            line = line.strip
            u = URI.join( base_uri, line )
            begin 
              @mech.get u
              line = @mech.page.body.toutf8
              line = self.embed_css_url(line)
              line += "\n"
              @mech.history.pop
            rescue => e
              $stderr.puts "uri err occured. => '#{u}'"
              $stderr.puts e.backtrace
            end
        end
        line
      }.join.toutf8
    end
    def embed_style(page=nil,base_uri=nil)
      page = @mech.page unless page
      base_uri = @mech.page.uri unless base_uri
      page.search("style").each{|e|
        css = e.text
        css = self.embed_css_url(css)
        e.content = css
      }
      page.search("link[rel*=stylesheet][href]").each{|e| 
        begin
          u = URI.join(base_uri, e.attr("href"))
          @mech.get u
          e.remove
          head = page.search("head").first
          css = @mech.page.body.lines.reject{|line| line=~/@charset/i }.join.toutf8
          css = css.gsub( /\/\*(?:(?!\*\/).)*\*\//m , "");
          css = self.embed_style_import(css)
          css = self.embed_css_url(css)
          head.add_child("\n<style type='text/css'>\n\n#{css}\n\n</style>\n")
          @mech.history.pop
        rescue => e
          $stderr.puts "uri err occured. => '#{u}'" if $DEBUG 
          $stderr.puts e.backtrace if $DEBUG 
        end
      }
    end
    def embed_images(page=nil,base_uri=nil)
      page = @mech.page unless page
      base_uri = @mech.page.uri unless base_uri
      page.search("img[src],input[src]").each{|e|
        next unless e.attr("src")
        u = e.attr("src").start_with?("http") ? e.attr("src") : URI.join(base_uri, e.attr("src"))
        begin 
          @mech.get u
          #line = @mech.page.body.toutf8
          e["src"] = "data:#{@mech.page['content-type']};base64,#{Base64.encode64(@mech.page.body)}"
          @mech.history.pop
        rescue => e
          $stderr.puts "uri err occured. => '#{u}'" if $DEBUG  
          $stderr.puts e.backtrace if $DEBUG 
        end
      }
    end

  end


end
