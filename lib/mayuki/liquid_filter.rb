module LiquidFilter
  
  def source(input, lang)
    system("pygmentize -f html -l #{lang} -O linenos=1 "\
      "-o #{File.join($dir_o, input)}.html #{File.join($dir_i, input)}")
    text = IO.read(File.join($dir_o, "#{input}.html"))
    File.delete(File.join($dir_o, "#{input}.html"))
    
    "<blockquote>\n"\
    "<div class='pygments'>\n"\
    "#{text}"\
    "\n</div>"\
    "\n</blockquote>"
  end
  
  def src(input, lang)
    source(input, lang)
  end
  
  def code(input)
    system("pygmentize -f html -O linenos=1 "\
      "-o #{File.join($dir_o, input)}.html #{File.join($dir_i, input)}")
    text = IO.read(File.join($dir_o, "#{input}.html"))
    File.delete(File.join($dir_o, "#{input}.html"))
    
    "<blockquote>\n"\
    "<div class='pygments'>\n"\
    "#{text}"\
    "\n</div>"\
    "\n</blockquote>"
  end
  
end
