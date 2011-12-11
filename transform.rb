
header = "<html>
  <head>
    <link href='http://fonts.googleapis.com/css?family=IM+Fell+Great+Primer:400,400italic|IM+Fell+Great+Primer+SC|Crimson+Text:400,400italic' rel='stylesheet' type='text/css'>
    <link rel=\"stylesheet\" href=\"style.css\" type=\"text/css\" media=\"screen\" charset=\"utf-8\">
    <script type='text/x-mathjax-config'>
      MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
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

ARGF.each do |line|
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
  line.sub!(/.*\\end\{\w*\}/, '</div>')
  line.sub!(/\\label\{(\w*):(\w*)\}/, "<a href=\"\\1_\\2\"></a>")
  line.sub!(/\\section\{(.*)\}/, "<h2 class=\'section\'>\\1</h2>")
  line.sub!(/.*\% section \w* \(end\)/, "</div>")
  line.sub!(/(.*)\%.*/, "\\1")  
  puts line
end

puts footer

