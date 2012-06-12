require 'liquid'
require 'rdiscount'
require 'yaml'

require 'mayuki/liquid_filter.rb'

module Mayuki
  
  def self.mayuki(input_dir = ".")
    
    # Set default configuration
    conf_global = {
      "_output" => File.join(input_dir, "_output"),
      "_render" => ["liquid"],
      "_export" => [],
      "_pygments" => false
      }
    
    # Load global configuration
    Dir[File.join(input_dir, "_conf*/*"),
      File.join(input_dir, "_conf*.yaml"),
      File.join(input_dir, "_conf*.yml")
      ].each do |f|
        begin
          conf_global.merge!(YAML.load_file(f))
          rescue
        end
      end
    
    # Prepare global output directory
    Dir.mkdir(conf_global["_output"]) unless Dir.exist?(conf_global["_output"])
    
    # Recurse each directory
    Dir[File.join(input_dir, "/"), File.join(input_dir, "**/*/")].each do |d|
      
      # Strip relative path
      rel = d.split(File.join(input_dir, "/"))[1]
      rel = "." unless rel
      
      # Skip if the directory is intended to be ignored
      next if not d.split("/").reduce(true) { |result, elem| result and elem[0] != "_" }
      
      # Get global configuration
      conf = Hash[conf_global]
      
      # Load local configuration
      Dir[File.join(d, "_conf*/*"),
        File.join(d, "_conf*.yaml"),
        File.join(d, "_conf*.yml")
        ].each do |f|
        begin
          conf.merge!(YAML.load_file(f))
          rescue
        end
      end
      
      # Prepare local output directory
      Dir.mkdir(conf["_output"]) unless Dir.exist?(conf["_output"])
      Dir.mkdir(File.join(conf["_output"], rel)) unless Dir.exist?(File.join(conf["_output"], rel))
      
      # Process each file
      Dir[File.join(d, "*")].each do |f|
        
        # Skip if it is a directory
        next if not File.file?(f)
        
        # Skip if the file is intended to be ignored
        next if File.basename(f).start_with?("_")
        
        # Get local configuration
        conf_infile = Hash[conf]
        
        # Markdown / HTML file (parsing)
        if [".markdown", ".md",
          ".htm", ".html"
          ].index(File.extname(f))
          
          # Read text and metadata
          part1, sep, part2 = IO.read(f).partition("\n---")
          if sep == ""
            text = part1
          else
            yaml, text = [part1, part2]
            
            # Load in-file configuration
            begin
              conf_infile.merge!(YAML.load(yaml))
              rescue
            end
          end
          
          # Set environment variables for filter module
          $dir_i = d
          $dir_o = File.join(conf_infile["_output"], rel)
          
          # Render text
          ["liquid", "markdown"].each do |r|
            if conf_infile["_render"].index(r)
              text = method("render_" + r).call(text)
            end
          end
          
          # Export text
          if conf_infile["_export"].index("html")
            
            text = export_html(text, conf_infile)
            IO.write(File.join(conf_infile["_output"], rel, File.basename(f, File.extname(f)) + ".html"), text)
            
          elsif conf_infile["_export"].index("html_article")
            
            text = export_html_article(text, conf_infile)
            IO.write(File.join(conf_infile["_output"], rel, File.basename(f, File.extname(f)) + ".html"), text)
            
          elsif conf_infile["_export"].index("html_full")
            
            text = export_html_full(text, conf_infile)
            IO.write(File.join(conf_infile["_output"], rel, File.basename(f, File.extname(f)) + ".html"), text)
            
          else
            
            text = yaml + "\n---\n" + text if sep != ""
            IO.write(File.join(conf_infile["_output"], rel, File.basename(f)), text)
            
          end
          
          # Export pygments stylesheet (_pygments.css)
          if conf_infile["_pygments"]
            IO.write(File.join(conf_infile["_output"], rel, "_pygments.css"),
              ".pygments td.linenos { background-color: #f0f0f0; padding-right: 10px; }\n"\
              ".pygments span.lineno { background-color: #f0f0f0; padding: 0 5px 0 5px; }\n"\
              ".pygments pre { line-height: 125%; }\n")
            
            system("pygmentize -f html -S default -a .pygments "\
              ">> #{File.join(conf_infile["_output"], rel, "_pygments.css")}")
          end
          
        # Other file (copying)
        else
          
          # Read text
          text = IO.read(f)
          
          # Export text
          IO.write(File.join(conf_infile["_output"], rel, File.basename(f)), text)
          
        end
        
      end
      
    end
    
    conf_global["_output"]
    
  end
  
  def self.render_liquid(text)
    Liquid::Template.parse(text).render({}, :filters => [LiquidFilter])
  end
  
  def self.render_markdown(text)
    RDiscount.new(text).to_html
  end
  
  def self.export_html(text, conf)
    (conf["_pygments"] ? "<link href='_pygments.css' rel='stylesheet'>\n" : "") +
    "#{text}"
  end
  
  def self.export_html_article(text, conf)
    (conf["_pygments"] ? "<link href='_pygments.css' rel='stylesheet'>\n" : "") +
    "<article>\n"\
    "#{text}"\
    "\n</article>"
  end
  
  def self.export_html_full(text, conf)
    "<!DOCTYPE html>\n"\
    "<html>\n"\
    "<head>\n" +
    (conf["_pygments"] ? "<link href='_pygments.css' rel='stylesheet'>\n" : "") +
    "</head>\n"\
    "<body>\n<article>\n"\
    "#{text}"\
    "\n</article>\n</body>"\
    "\n</html>"
  end
  
end
