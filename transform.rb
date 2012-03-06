HERE = File.expand_path(File.dirname(__FILE__))
STYLESHEET = File.join(HERE, 'style.css')
MACROS = File.join(HERE, 'macros.tex')

header = "<html>
  <head>
    <link href='http://fonts.googleapis.com/css?family=IM+Fell+Great+Primer:400,400italic|IM+Fell+Great+Primer+SC|Crimson+Text:400,400italic' rel='stylesheet' type='text/css'>
    <link rel=\"stylesheet\" href=\"#{STYLESHEET}\" type=\"text/css\" media=\"screen\" charset=\"utf-8\">
    <script type='text/x-mathjax-config'>
      MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\\\(','\\\\)']]}});
    </script>
    <script src='http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML' type='text/javascript'></script>
  </head>
  <body>
    <div id='page'>"
    
footer = "
        </div>
      </body>
    </html>"    

puts header

counters = Hash.new(0)
macros = []
paragraph_state = :none

IO.foreach(MACROS) do |line|
  md = line.match(/newcommand\{(\\[a-zA-Z]*)\}\{(.*)\}/)
  if md
    macros << [md[1], md[2]]
    # macros << [/(#{"\\" + md[1]})[^a-zA-Z]/, md[1], md[2]]
    line = ''
  end
end

ARGF.each do |line|
  
  # Do replacements for macros
  macros.each do |m|
    while (md = line.match(/(#{"\\" + m[0]})[^a-zA-Z]/))
      if md
        line.sub!(m[0],m[1])
      end
    end
  end

  line.sub!('\begin{itemize}','<ul>')
  line.sub!('\end{itemize}','</ul>')
  line.sub!('\begin{enumerate}','<ol>')
  line.sub!('\end{enumerate}','</ol>')
  line.sub!('\item','<li>')
  

  # Check for numbered entities like theorems.
  md = line.match(/.*\\begin\{(\w*)\}/)
  if md
    div_class = md[1]
    if div_class =~ (/theorem|lemma|corollary|definition/)
    counters[div_class] += 1 
      line.sub!(/.*\\begin\{(\w*)\}/, "<div class=\'#{div_class}\'><h3>#{div_class.capitalize} #{counters[div_class]}.</h3>")
    else
      line.sub!(/.*\\begin\{(\w*)\}/, "<div class=\'#{div_class}\'><h3>#{div_class.capitalize}.</h3>")      
    end
  end
  line.sub!(/``/, "&#8220;")
  line.sub!(/''/, "&#8221;")
  line.sub!(/\\\s/, " ")
  line.sub!(/.*\\end\{\w*\}/, '</div>')
  line.sub!(/\\label\{(\w*):(\w*)\}/, "<a href=\"\\1_\\2\"></a>")
  line.sub!(/\\section\*?\{(.*)\}/, "<h2 class=\'section\'>\\1</h2>")
  line.sub!(/\\subsection\*?\{(.*)\}/, "<h2 class=\'subsection\'>\\1</h2>")
  line.sub!(/.*\% section \w* \(end\)/, "</div>")
  line.sub!(/(.*)\%.*/, "\\1")
  line.gsub!(/\\textbf\{([^\}]*)\}/, "<span class='textbf'>\\1</span>")
  line.gsub!(/\\texttt\{([^\}]*)\}/, "<span class='texttt'>\\1</span>")
  line.gsub!(/\\textsc\{([^\}]*)\}/, "<span class='textsc'>\\1</span>")
  line.gsub!(/\\emph\{([^\}]*)\}/, "<span class='emph'>\\1</span>")
  
  # Paragraphs
  if line.match(/^\s*$/)
    case paragraph_state
    when :none
      paragraph_state = :starting
    when :during
      line = '</p>'
    end
  else
    case paragraph_state
    when :starting
      paragraph_state = :during
      puts '<p>'
    end
  end

  # Create new macros with newcommand
  # md = line.match(/newcommand\{(.*)\}\{(.*)\}/)
  # if md
  #   macros << [md[1], md[2]]
  #   line = ''
  # end

  puts line
end

puts footer

